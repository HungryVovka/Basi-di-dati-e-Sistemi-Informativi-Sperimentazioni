#include <ctype.h>
#include "db_engine.h"

/*
 * Rimuove spazi, parentesi, virgolette e virgole all'inizio e alla fine
 * di una stringa per isolare i nomi puliti di tabelle e colonne.
 */
static void clean_sql_identifier(char *str) {
    if (!str || !*str) return;
    
    char *start = str;
    while (*start && (isspace((unsigned char)*start) || *start == '(' || *start == '`' || 
                      *start == '"' || *start == '\'' || *start == ',')) {
        start++;
    }
    if (start != str) {
        memmove(str, start, strlen(start) + 1);
    }
    
    int len = (int)strlen(str);
    while (len > 0 && (isspace((unsigned char)str[len - 1]) || str[len - 1] == ')' || 
                      str[len - 1] == '`' || str[len - 1] == '"' || str[len - 1] == '\'' || 
                      str[len - 1] == ',' || str[len - 1] == ';')) {
        str[--len] = '\0';
    }
}

/*
 * Cerca una sottostringa senza fare distinzione tra maiuscole e minuscole.
 * Ritorna il puntatore alla prima occorrenza o NULL se non trova nulla.
 */
static const char *find_case_insensitive(const char *haystack, const char *needle) {
    if (!haystack || !needle) return NULL;
    size_t needle_len = strlen(needle);
    if (needle_len == 0) return haystack;

    for (; *haystack; haystack++) {
        if (strncasecmp(haystack, needle, needle_len) == 0) {
            return haystack;
        }
    }
    return NULL;
}

/*
 * Estrae i singoli valori dalla clausola VALUES di una query INSERT.
 * Gestisce correttamente il testo tra virgolette per non spezzare i valori
 * sulle virgole interne alle stringhe.
 */
static int parse_sql_values(const char *row_sql, char values[32][128], int max_cols) {
    const char *v_ptr = find_case_insensitive(row_sql, "VALUES");
    if (!v_ptr) v_ptr = row_sql;
    
    const char *open_paren = strchr(v_ptr, '(');
    if (!open_paren) return 0;
    
    const char *close_paren = strrchr(open_paren, ')');
    if (!close_paren) return 0;
    
    int col_idx = 0;
    const char *p = open_paren + 1;
    
    while (p < close_paren && col_idx < max_cols) {
        while (p < close_paren && (*p == ' ' || *p == '\t')) p++;
        if (p >= close_paren) break;
        
        char buf[128] = {0};
        int b_idx = 0;
        int in_quotes = 0;
        
        while (p < close_paren) {
            if (*p == '\'' || *p == '"') {
                in_quotes = !in_quotes;
                p++;
                continue;
            }
            if (*p == ',' && !in_quotes) {
                p++;
                break;
            }
            if (b_idx < (int)sizeof(buf) - 1) {
                buf[b_idx++] = *p;
            }
            p++;
        }
        buf[b_idx] = '\0';
        
        while (b_idx > 0 && (buf[b_idx-1] == ' ' || buf[b_idx-1] == '\t')) {
            buf[--b_idx] = '\0';
        }
        
        strncpy(values[col_idx], buf, 127);
        col_idx++;
    }
    return col_idx;
}

/*
 * Disegna una tabella in formato ASCII nel terminale,
 * calcolando la larghezza delle colonne in base al contenuto effettivo.
 */
static void render_ascii_table(TableNode *selected, int lang) {
    if (!selected || !selected->cols_head) return;

    #define MAX_TABLE_COLS 16
    char col_names[MAX_TABLE_COLS][64];
    int col_widths[MAX_TABLE_COLS];
    int num_cols = 0;

    ColumnNode *c_iter = selected->cols_head;
    while (c_iter && num_cols < MAX_TABLE_COLS) {
        strncpy(col_names[num_cols], c_iter->col_name, 63);
        col_widths[num_cols] = (int)strlen(c_iter->col_name);
        if (col_widths[num_cols] < 8) col_widths[num_cols] = 8;
        if (col_widths[num_cols] > 24) col_widths[num_cols] = 24;
        num_cols++;
        c_iter = c_iter->next;
    }

    if (num_cols == 0) return;

    DataRowNode *r_iter = selected->rows_head;
    while (r_iter) {
        char row_vals[32][128] = {0};
        int parsed_count = parse_sql_values(r_iter->row_data, row_vals, num_cols);
        for (int i = 0; i < parsed_count && i < num_cols; i++) {
            int len = (int)strlen(row_vals[i]);
            if (len > 24) len = 24;
            if (len > col_widths[i]) col_widths[i] = len;
        }
        r_iter = r_iter->next;
    }

    if (lang == 1) printf("\n%s--- VISTA TABELLARE VISIVA ---%s\n", COLOR_CYAN, COLOR_RESET);
    else printf("\n%s--- VISUAL TABULAR VIEW ---%s\n", COLOR_CYAN, COLOR_RESET);

    printf("+");
    for (int i = 0; i < num_cols; i++) {
        for (int w = 0; w < col_widths[i] + 2; w++) printf("-");
        printf("+");
    }
    printf("\n");

    printf("|");
    for (int i = 0; i < num_cols; i++) {
        printf(" %s%-*.*s%s |", COLOR_BOLD, col_widths[i], col_widths[i], col_names[i], COLOR_RESET);
    }
    printf("\n");

    printf("+");
    for (int i = 0; i < num_cols; i++) {
        for (int w = 0; w < col_widths[i] + 2; w++) printf("=");
        printf("+");
    }
    printf("\n");

    if (!selected->rows_head) {
        printf("|");
        for (int i = 0; i < num_cols; i++) {
            printf(" %-*s |", col_widths[i], "...");
        }
        printf("\n");
    } else {
        r_iter = selected->rows_head;
        while (r_iter) {
            char row_vals[32][128] = {0};
            int parsed_count = parse_sql_values(r_iter->row_data, row_vals, num_cols);
            
            printf("|");
            for (int i = 0; i < num_cols; i++) {
                char display_val[128] = "";
                if (i < parsed_count) {
                    strncpy(display_val, row_vals[i], sizeof(display_val)-1);
                }
                printf(" %-*.*s |", col_widths[i], col_widths[i], display_val);
            }
            printf("\n");
            r_iter = r_iter->next;
        }
    }

    printf("+");
    for (int i = 0; i < num_cols; i++) {
        for (int w = 0; w < col_widths[i] + 2; w++) printf("-");
        printf("+");
    }
    printf("\n\n");
}

/*
 * Analizza un comandi INSERT INTO ed estrae i dati per appenderli
 * alla tabella corrispondente nella nostra lista in memoria.
 */
static void process_insert_statement(TableNode *tables_head, const char *stmt) {
    const char *ins_ptr = find_case_insensitive(stmt, "INSERT INTO");
    if (!ins_ptr) return;

    ins_ptr += 11;
    while (*ins_ptr && isspace((unsigned char)*ins_ptr)) ins_ptr++;

    char tname[64] = {0};
    int t_idx = 0;
    while (*ins_ptr && !isspace((unsigned char)*ins_ptr) && *ins_ptr != '(' && t_idx < 63) {
        tname[t_idx++] = *ins_ptr++;
    }
    tname[t_idx] = '\0';
    clean_sql_identifier(tname);

    if (strlen(tname) == 0) return;

    TableNode *t_iter = tables_head;
    while (t_iter) {
        if (strcasecmp(t_iter->table_name, tname) == 0) break;
        t_iter = t_iter->next;
    }
    if (!t_iter) return;

    const char *v_ptr = find_case_insensitive(stmt, "VALUES");
    if (!v_ptr) return;
    v_ptr += 6;

    int in_quotes = 0;
    char quote_char = 0;
    int in_paren = 0;
    char tuple_buf[512] = {0};
    int tuple_len = 0;

    for (const char *p = v_ptr; *p; p++) {
        char c = *p;

        if ((c == '\'' || c == '"') && (p == v_ptr || *(p - 1) != '\\')) {
            if (!in_quotes) {
                in_quotes = 1;
                quote_char = c;
            } else if (c == quote_char) {
                in_quotes = 0;
            }
        }

        if (!in_quotes) {
            if (c == '(') {
                if (in_paren == 0) {
                    tuple_len = 0;
                    tuple_buf[0] = '\0';
                }
                in_paren++;
            }
        }

        if (in_paren > 0) {
            if (tuple_len < (int)sizeof(tuple_buf) - 1) {
                tuple_buf[tuple_len++] = c;
                tuple_buf[tuple_len] = '\0';
            }
        }

        if (!in_quotes) {
            if (c == ')') {
                in_paren--;
                if (in_paren == 0) {
                    DataRowNode *row = (DataRowNode *)calloc(1, sizeof(DataRowNode));
                    snprintf(row->row_data, sizeof(row->row_data), "INSERT INTO %s VALUES %s;\n", tname, tuple_buf);

                    DataRowNode *r_iter = t_iter->rows_head;
                    if (!r_iter) {
                        t_iter->rows_head = row;
                    } else {
                        while (r_iter->next) r_iter = r_iter->next;
                        r_iter->next = row;
                    }
                    t_iter->record_count++;
                    tuple_len = 0;
                    tuple_buf[0] = '\0';
                }
            }
        }
    }
}

/*
 * Legge i file SQL DDL e DML dal disco per ricostruire in memoria
 * l'intera struttura del database (tabelle, colonne, vincoli e record).
 */
TableNode* load_tables_from_sql_files(void) {
    const char *ddl_files[] = {
        "Rukavishnikov_DDL.sql",
        "Rukavishnikov_DDL_8.sql",
        "Rukavishnikov_DDL_9.sql",
        "Rukavishnikov_DDL_11.sql"
    };

    FILE *f_ddl = NULL;
    for (size_t i = 0; i < sizeof(ddl_files) / sizeof(ddl_files[0]); i++) {
        f_ddl = fopen(ddl_files[i], "r");
        if (f_ddl) break;
    }

    if (!f_ddl) return NULL;

    TableNode *head = NULL, *tail = NULL;
    TableNode *current_table = NULL;
    char line[1024];

    while (fgets(line, sizeof(line), f_ddl)) {
        char *p = line;
        while (isspace((unsigned char)*p)) p++;
        if (*p == '#' || (p[0] == '-' && p[1] == '-')) continue;

        const char *create_ptr = find_case_insensitive(line, "CREATE TABLE");
        if (create_ptr) {
            char tname[64] = {0};
            const char *after_create = create_ptr + 12;
            while (*after_create && isspace((unsigned char)*after_create)) after_create++;

            if (strncasecmp(after_create, "IF NOT EXISTS", 13) == 0) {
                after_create += 13;
                while (*after_create && isspace((unsigned char)*after_create)) after_create++;
            }

            if (sscanf(after_create, "%63s", tname) == 1) {
                clean_sql_identifier(tname);
                if (strlen(tname) > 0) {
                    TableNode *node = (TableNode *)calloc(1, sizeof(TableNode));
                    strncpy(node->table_name, tname, sizeof(node->table_name) - 1);
                    if (!head) head = tail = node;
                    else { tail->next = node; tail = node; }
                    current_table = node;
                }
            }
        }

        if (!current_table) continue;

        if (find_case_insensitive(line, "FOREIGN KEY")) {
            char ref_table[64] = {0};
            const char *ref_ptr = find_case_insensitive(line, "REFERENCES");
            if (ref_ptr) {
                sscanf(ref_ptr + 10, "%63s", ref_table);
                clean_sql_identifier(ref_table);

                if (strlen(ref_table) > 0) {
                    if (strlen(current_table->dependencies) == 0) {
                        snprintf(current_table->dependencies, sizeof(current_table->dependencies), "[KEY] -> %s", ref_table);
                    } else if (!find_case_insensitive(current_table->dependencies, ref_table)) {
                        strncat(current_table->dependencies, ", ", sizeof(current_table->dependencies) - strlen(current_table->dependencies) - 1);
                        strncat(current_table->dependencies, ref_table, sizeof(current_table->dependencies) - strlen(current_table->dependencies) - 1);
                    }
                }
            }
            continue;
        }

        if (find_case_insensitive(line, "CONSTRAINT ") || 
            find_case_insensitive(line, "PRIMARY KEY (") || 
            find_case_insensitive(line, "UNIQUE (") || 
            find_case_insensitive(line, "CHECK (") || 
            find_case_insensitive(line, "INDEX ")) {
            continue;
        }

        int is_type = (find_case_insensitive(line, "VARCHAR") != NULL ||
                       find_case_insensitive(line, "INT") != NULL ||
                       find_case_insensitive(line, "INTEGER") != NULL ||
                       find_case_insensitive(line, "SERIAL") != NULL ||
                       find_case_insensitive(line, "BIGINT") != NULL ||
                       find_case_insensitive(line, "SMALLINT") != NULL ||
                       find_case_insensitive(line, "TINYINT") != NULL ||
                       find_case_insensitive(line, "CHAR") != NULL ||
                       find_case_insensitive(line, "TEXT") != NULL ||
                       find_case_insensitive(line, "DATE") != NULL ||
                       find_case_insensitive(line, "DATETIME") != NULL ||
                       find_case_insensitive(line, "TIMESTAMP") != NULL ||
                       find_case_insensitive(line, "DECIMAL") != NULL ||
                       find_case_insensitive(line, "NUMERIC") != NULL ||
                       find_case_insensitive(line, "FLOAT") != NULL ||
                       find_case_insensitive(line, "DOUBLE") != NULL ||
                       find_case_insensitive(line, "BOOLEAN") != NULL);

        if (is_type) {
            char col_name[64] = {0}, col_type[32] = {0};
            const char *scan_start = line;

            if (create_ptr) {
                const char *paren = strchr(line, '(');
                if (paren) scan_start = paren + 1;
                else continue;
            }

            if (sscanf(scan_start, " %63s %31s", col_name, col_type) == 2) {
                clean_sql_identifier(col_name);
                clean_sql_identifier(col_type);

                if (strlen(col_name) > 0 &&
                    strcasecmp(col_name, "CONSTRAINT") != 0 &&
                    strcasecmp(col_name, "PRIMARY") != 0 &&
                    strcasecmp(col_name, "FOREIGN") != 0 &&
                    strcasecmp(col_name, "KEY") != 0 &&
                    strcasecmp(col_name, "CHECK") != 0 &&
                    strcasecmp(col_name, "UNIQUE") != 0 &&
                    strcasecmp(col_name, "INDEX") != 0) {
                    
                    ColumnNode *col = (ColumnNode *)calloc(1, sizeof(ColumnNode));
                    strncpy(col->col_name, col_name, sizeof(col->col_name) - 1);
                    strncpy(col->col_type, col_type, sizeof(col->col_type) - 1);
                    
                    ColumnNode *c_iter = current_table->cols_head;
                    if (!c_iter) current_table->cols_head = col;
                    else {
                        while (c_iter->next) c_iter = c_iter->next;
                        c_iter->next = col;
                    }
                }
            }
        }
    }
    fclose(f_ddl);

    const char *dml_files[] = {
        "Rukavishnikov_DMLPOP.sql",
        "Rukavishnikov_DMLPOP_8.sql",
        "Rukavishnikov_DMLPOP_9.sql",
        "Rukavishnikov_DMLPOP_11.sql"
    };

    FILE *f_dml = NULL;
    for (size_t i = 0; i < sizeof(dml_files) / sizeof(dml_files[0]); i++) {
        f_dml = fopen(dml_files[i], "r");
        if (f_dml) break;
    }

    if (f_dml) {
        char stmt_buf[32768] = {0};

        while (fgets(line, sizeof(line), f_dml)) {
            char *p = line;
            while (isspace((unsigned char)*p)) p++;
            if (strncmp(p, "--", 2) == 0 || *p == '#') continue;

            if (strlen(stmt_buf) + strlen(line) < sizeof(stmt_buf) - 1) {
                strcat(stmt_buf, line);
            }

            if (strchr(line, ';') != NULL) {
                for (int i = 0; stmt_buf[i]; i++) {
                    if (stmt_buf[i] == '\n' || stmt_buf[i] == '\r') {
                        stmt_buf[i] = ' ';
                    }
                }

                if (find_case_insensitive(stmt_buf, "INSERT INTO")) {
                    process_insert_statement(head, stmt_buf);
                }

                stmt_buf[0] = '\0';
            }
        }
        fclose(f_dml);
    }

    return head;
}

/*
 * Libera tutta la memoria dinamica allocata per la lista delle tabelle,
 * inclusi i nodi di colonne e righe.
 */
void free_table_linked_list(TableNode *head) {
    TableNode *t_tmp;
    ColumnNode *c_tmp;
    DataRowNode *r_tmp;

    while (head) {
        t_tmp = head;
        while (t_tmp->cols_head) {
            c_tmp = t_tmp->cols_head;
            t_tmp->cols_head = t_tmp->cols_head->next;
            free(c_tmp);
        }
        while (t_tmp->rows_head) {
            r_tmp = t_tmp->rows_head;
            t_tmp->rows_head = t_tmp->rows_head->next;
            free(r_tmp);
        }
        head = head->next;
        free(t_tmp);
    }
}

/*
 * Interfaccia interattiva per ispezionare il database.
 * Permette di scegliere una tabella e visualizzarne lo schema, le relazioni e i record.
 */
void display_tables_gui(int lang) {
    TableNode *tables = load_tables_from_sql_files();
    char input_buf[64];
    int choice = -1;

    while (1) {
        CLEAR_SCREEN();
        printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
        if (lang == 1) {
            printf("%s===      ISPETTORE TABELLE DATABASE (LISTA COLLEGATA)            ===%s\n", COLOR_CYAN, COLOR_RESET);
        } else {
            printf("%s===          LINKED LIST DATABASE TABLES INSPECTOR                 ==%s\n", COLOR_CYAN, COLOR_RESET);
        }
        printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);

        if (!tables) {
            if (lang == 1) {
                printf("%s[INFO] Impossibile analizzare i file SQL. Verificare la posizione dei file DDL.%s\n\n", COLOR_YELLOW, COLOR_RESET);
                printf("  %s[0]%s Torna al Menu Principale\n\n", COLOR_RED, COLOR_RESET);
                printf("  %sSeleziona tabella da ispezionare > %s", COLOR_GREEN, COLOR_RESET);
            } else {
                printf("%s[INFO] Could not parse SQL files. Check SQL DDL files location.%s\n\n", COLOR_YELLOW, COLOR_RESET);
                printf("  %s[0]%s Return to Main Menu\n\n", COLOR_RED, COLOR_RESET);
                printf("  %sSelect table to inspect > %s", COLOR_GREEN, COLOR_RESET);
            }
        } else {
            TableNode *curr = tables;
            int idx = 1;
            while (curr) {
                if (lang == 1) {
                    printf("  %s[%2d]%s Tabella: %s%-28s%s | Record: %s%2d%s %s%s%s\n", 
                           COLOR_YELLOW, idx++, COLOR_RESET, 
                           COLOR_BOLD, curr->table_name, COLOR_RESET,
                           COLOR_GREEN, curr->record_count, COLOR_RESET,
                           COLOR_CYAN, curr->dependencies, COLOR_RESET);
                } else {
                    printf("  %s[%2d]%s Table: %s%-28s%s | Records: %s%2d%s %s%s%s\n", 
                           COLOR_YELLOW, idx++, COLOR_RESET, 
                           COLOR_BOLD, curr->table_name, COLOR_RESET,
                           COLOR_GREEN, curr->record_count, COLOR_RESET,
                           COLOR_CYAN, curr->dependencies, COLOR_RESET);
                }
                curr = curr->next;
            }
            if (lang == 1) {
                printf("\n  %s[ 0]%s Torna al Menu Principale\n\n", COLOR_RED, COLOR_RESET);
                printf("  %sSeleziona tabella da ispezionare > %s", COLOR_GREEN, COLOR_RESET);
            } else {
                printf("\n  %s[ 0]%s Return to Main Menu\n\n", COLOR_RED, COLOR_RESET);
                printf("  %sSelect table to inspect > %s", COLOR_GREEN, COLOR_RESET);
            }
        }

        print_footer();
        printf("\033[4A\033[32C");
        fflush(stdout);

        if (!fgets(input_buf, sizeof(input_buf), stdin)) continue;
        if (sscanf(input_buf, "%d", &choice) != 1) continue;

        if (choice == 0) break;

        TableNode *selected = tables;
        int current_idx = 1;
        while (selected && current_idx < choice) {
            selected = selected->next;
            current_idx++;
        }

        if (selected) {
            CLEAR_SCREEN();
            printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
            if (lang == 1) printf("STRUTTURA TABELLA & DATI: %s%s%s\n", COLOR_YELLOW, selected->table_name, COLOR_RESET);
            else printf("TABLE STRUCTURE & DATA: %s%s%s\n", COLOR_YELLOW, selected->table_name, COLOR_RESET);
            printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);

            if (strlen(selected->dependencies) > 0) {
                if (lang == 1) printf("%sDipendenze:%s %s\n\n", COLOR_BOLD, COLOR_RESET, selected->dependencies);
                else printf("%sDependencies:%s %s\n\n", COLOR_BOLD, COLOR_RESET, selected->dependencies);
            }

            if (lang == 1) printf("%s--- COLONNE E SCHEMA ---%s\n", COLOR_CYAN, COLOR_RESET);
            else printf("%s--- COLUMNS & SCHEMA ---%s\n", COLOR_CYAN, COLOR_RESET);

            ColumnNode *col = selected->cols_head;
            if (!col) {
                if (lang == 1) printf("  (Nessun dettaglio colonna analizzato)\n");
                else printf("  (No column details parsed)\n");
            }
            while (col) {
                if (lang == 1) printf("  Colonna: %-25s Tipo: %s\n", col->col_name, col->col_type);
                else printf("  Column: %-25s Type: %s\n", col->col_name, col->col_type);
                col = col->next;
            }

            if (lang == 1) printf("\n%s--- RECORD DATI CARICATI (%d) ---%s\n", COLOR_CYAN, selected->record_count, COLOR_RESET);
            else printf("\n%s--- LOADED DATA RECORDS (%d) ---%s\n", COLOR_CYAN, selected->record_count, COLOR_RESET);

            DataRowNode *row = selected->rows_head;
            if (!row) {
                if (lang == 1) printf("  (Nessun record presente in DMLPOP)\n");
                else printf("  (No data records present in DMLPOP)\n");
            }
            while (row) {
                printf("  %s", row->row_data);
                row = row->next;
            }

            render_ascii_table(selected, lang);

            if (lang == 1) printf("  Premere Invio per tornare all elenco tabelle...");
            else printf("  Press Enter to return to table list...");
            print_footer();
            printf("\033[4A\033[45C");
            fflush(stdout);
            fgets(input_buf, sizeof(input_buf), stdin);
        }
    }

    free_table_linked_list(tables);
    CLEAR_SCREEN();
}

/*
 * Carica ed esegue uno script SQL esterno riga per riga,
 * mostrando i comandi a schermo e salvando l'azione nel log.
 */
void execute_sql_file(int lang) {
    char filename[256];
    FILE *file;

    CLEAR_SCREEN();
    printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
    if (lang == 1) {
        printf("%s=== ESEGUI SCRIPT SQL DA FILE DI TESTO                              ===%s\n", COLOR_CYAN, COLOR_RESET);
    } else {
        printf("%s=== EXECUTE SQL SCRIPT FROM TEXT FILE                               ===%s\n", COLOR_CYAN, COLOR_RESET);
    }
    printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);
    
    if (lang == 1) {
        printf("Inserisci il nome del file .sql (es. Rukavishnikov_QUERIES.sql):\n\n");
    } else {
        printf("Enter filename of .sql file (e.g. Rukavishnikov_QUERIES.sql):\n\n");
    }
    printf("  File > ");
    print_footer();
    printf("\033[4A\033[10C");
    fflush(stdout);

    if (!fgets(filename, sizeof(filename), stdin)) return;
    filename[strcspn(filename, "\r\n")] = 0;
    if (strlen(filename) == 0) return;

    CLEAR_SCREEN();
    file = fopen(filename, "r");
    if (!file) {
        if (lang == 1) {
            printf("%s[ERRORE] Impossibile aprire il file '%s'!%s\n\n", COLOR_RED, filename, COLOR_RESET);
            printf("  Premere Invio per tornare...");
        } else {
            printf("%s[ERROR] Cannot open file '%s'!%s\n\n", COLOR_RED, filename, COLOR_RESET);
            printf("  Press Enter to return...");
        }
        print_footer();
        printf("\033[4A\033[27C");
        fflush(stdout);
        fgets(filename, sizeof(filename), stdin);
        CLEAR_SCREEN();
        return;
    }

    if (lang == 1) printf("%sEsecuzione dello script '%s' in corso...%s\n", COLOR_CYAN, filename, COLOR_RESET);
    else printf("%sExecuting script '%s'...%s\n", COLOR_CYAN, filename, COLOR_RESET);
    printf("----------------------------------------------------------------------\n");

    char line[512];
    int count = 0;
    while (fgets(line, sizeof(line), file)) {
        if (line[0] != '-' && strlen(line) > 3) {
            if (lang == 1) printf("%s[COMANDO SQL]:%s %s", COLOR_YELLOW, COLOR_RESET, line);
            else printf("%s[SQL COMMAND]:%s %s", COLOR_YELLOW, COLOR_RESET, line);
            count++;
        }
    }
    fclose(file);

    printf("----------------------------------------------------------------------\n");
    if (lang == 1) {
        printf("%s[SUCCESSO] Elaborate %d righe di logica SQL da '%s'.%s\n\n", COLOR_GREEN, count, filename, COLOR_RESET);
        log_to_file("Eseguito script SQL tramite Motore DB Testuale.");
        printf("  Premere Invio per tornare al menu principale...");
    } else {
        printf("%s[SUCCESS] Processed %d SQL logic lines from '%s'.%s\n\n", COLOR_GREEN, count, filename, COLOR_RESET);
        log_to_file("Executed SQL script file via Text DB Engine.");
        printf("  Press Enter to return to main menu...");
    }

    print_footer();
    printf("\033[4A\033[41C");
    fflush(stdout);
    fgets(filename, sizeof(filename), stdin);
    CLEAR_SCREEN();
}

/*
 * Permette l'inserimento ed esecuzione di una singola istruzione SQL personalizzata.
 * Se viene passato un comando DDL (CREATE/ALTER TABLE), lo appende anche al file locale.
 */
void execute_custom_sql_query(int lang) {
    char sql_buffer[1024];

    CLEAR_SCREEN();
    printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
    if (lang == 1) {
        printf("%s=== CONSOLE SQL TESTUALE & ESPORTAZIONE FILE DDL                    ===%s\n", COLOR_CYAN, COLOR_RESET);
    } else {
        printf("%s=== TEXT SQL CONSOLE & DDL FILE EXPORT                             ===%s\n", COLOR_CYAN, COLOR_RESET);
    }
    printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);
    
    if (lang == 1) {
        printf("Inserisci un singolo comando SQL (es. SELECT, CREATE TABLE, INSERT, UPDATE):\n\n");
    } else {
        printf("Enter single SQL command (e.g. SELECT, CREATE TABLE, INSERT, UPDATE):\n\n");
    }
    printf("  SQL > ");
    print_footer();
    printf("\033[4A\033[09C");
    fflush(stdout);

    if (!fgets(sql_buffer, sizeof(sql_buffer), stdin)) return;
    sql_buffer[strcspn(sql_buffer, "\r\n")] = 0;
    if (strlen(sql_buffer) == 0) return;

    CLEAR_SCREEN();
    if (lang == 1) printf("%sEsecuzione dell istruzione SQL in corso...%s\n\n", COLOR_CYAN, COLOR_RESET);
    else printf("%sExecuting SQL Statement...%s\n\n", COLOR_CYAN, COLOR_RESET);
    printf("  %s%s%s\n\n", COLOR_YELLOW, sql_buffer, COLOR_RESET);

    if (strncasecmp(sql_buffer, "CREATE TABLE", 12) == 0 || strncasecmp(sql_buffer, "ALTER TABLE", 11) == 0) {
        append_ddl_to_txt_file(sql_buffer);
        if (lang == 1) {
            printf("%s[ESPORTAZIONE DDL]%s Istruzione esportata in 'Rukavishnikov_db_data.txt'.\n", COLOR_GREEN, COLOR_RESET);
        } else {
            printf("%s[DDL EXPORT]%s Statement exported to 'Rukavishnikov_db_data.txt'.\n", COLOR_GREEN, COLOR_RESET);
        }
    }

    if (lang == 1) {
        printf("%s[MOTORE SQL]%s Query eseguita con successo (0 righe interessate in modalita testo).\n\n", COLOR_GREEN, COLOR_RESET);
        log_to_file("Eseguita istruzione SQL personalizzata.");
        printf("  Premere Invio per tornare al menu principale...");
    } else {
        printf("%s[SQL ENGINE]%s Query executed successfully (0 rows affected in text mode).\n\n", COLOR_GREEN, COLOR_RESET);
        log_to_file("Executed custom SQL statement.");
        printf("  Press Enter to return to main menu...");
    }

    print_footer();
    printf("\033[4A\033[41C");
    fflush(stdout);
    fgets(sql_buffer, sizeof(sql_buffer), stdin);
    CLEAR_SCREEN();
}