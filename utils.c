/*
 * utils.c - Funzioni di utilita generale per l'applicazione
 * (logging, formattazione grafica e supporto ANSI per Windows).
 */

#include "utils.h"

#if defined(_WIN32) || defined(_WIN64)
    #include <windows.h> /* API Windows per la gestione del terminale */
#endif

/*
 * Abilita l'elaborazione dei codici di escape ANSI nella console di Windows.
 * Permette la gestione dei colori e della pulizia dello schermo nel terminale.
 */
void enable_windows_vt_mode(void) {
#if defined(_WIN32) || defined(_WIN64)
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hOut == INVALID_HANDLE_VALUE) return;
    DWORD dwMode = 0;
    if (!GetConsoleMode(hOut, &dwMode)) return;
    dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    SetConsoleMode(hOut, dwMode);
#endif
}

/*
 * Stampa il pie' di pagina standard dell'interfaccia
 * con le informazioni sull'autore e l'ateneo.
 */
void print_footer(void) {
    printf("\n----------------------------------------------------------------------\n");
    printf("%sUPO%s %sDISIT%s Vladimir Rukavishnikov Matr. 20063686\n", 
           COLOR_RED, COLOR_RESET, 
           COLOR_ORANGE, COLOR_RESET);
    printf("----------------------------------------------------------------------\n");
}

/*
 * Scrive un messaggio nel file di log ("Rukavishnikov_history.txt") 
 * aggiungendo automaticamente la data e l'ora correnti.
 */
void log_to_file(const char *action_text) {
    FILE *f = fopen("Rukavishnikov_history.txt", "a");
    if (!f) return;
    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    fprintf(f, "[%04d-%02d-%02d %02d:%02d:%02d] %s\n", 
            t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, 
            t->tm_hour, t->tm_min, t->tm_sec, action_text);
    fclose(f);
}

/*
 * Aggiunge un'istruzione DDL in fondo al file di testo del database ("Rukavishnikov_db_data.txt").
 */
void append_ddl_to_txt_file(const char *ddl_statement) {
    FILE *f = fopen("Rukavishnikov_db_data.txt", "a");
    if (!f) return;
    fprintf(f, "-- DDL Statement Exported\n%s;\n\n", ddl_statement);
    fclose(f);
}