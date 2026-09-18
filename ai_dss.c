/*
 * ai_dss.c - Motore del Sistema di Supporto alle Decisioni Cliniche (AI DSS).
 *
 * Gestisce il caricamento del grafo di conoscenza (diagnosi, sintomi e pesi),
 * l'inserimento di nuove patologie e l'algoritmo diagnostico con Softmax.
 */

#include "ai_dss.h"

/*
 * Inserisce una nuova diagnosi in testa alla lista.
 * Se il codice ICD-9 e gia presente, ignora l'inserimento per evitare duplicati.
 */
static void add_diagnosis(DiagnosisNode **head, const char *code, const char *it, const char *en) {
    DiagnosisNode *curr = *head;
    while (curr) {
        if (strcmp(curr->icd_code, code) == 0) return;
        curr = curr->next;
    }
    DiagnosisNode *new_node = (DiagnosisNode *)calloc(1, sizeof(DiagnosisNode));
    if (!new_node) return;
    strncpy(new_node->icd_code, code, sizeof(new_node->icd_code) - 1);
    strncpy(new_node->name_it, it, sizeof(new_node->name_it) - 1);
    strncpy(new_node->name_en, en, sizeof(new_node->name_en) - 1);
    new_node->next = *head;
    *head = new_node;
}

/*
 * Collega un peso di correlazione tra un sintomo e un codice ICD-9.
 */
static void add_weight(WeightNode **head, const char *icd_code, double weight) {
    WeightNode *new_node = (WeightNode *)calloc(1, sizeof(WeightNode));
    if (!new_node) return;
    strncpy(new_node->icd_code, icd_code, sizeof(new_node->icd_code) - 1);
    new_node->weight = weight;
    new_node->next = *head;
    *head = new_node;
}

/*
 * Alloca e aggiunge un nuovo nodo sintomo in testa alla lista.
 */
static SymptomNode* add_symptom(SymptomNode **head, int id, const char *code, const char *it, const char *en) {
    SymptomNode *new_node = (SymptomNode *)calloc(1, sizeof(SymptomNode));
    if (!new_node) return NULL;
    new_node->sintomo_id = id;
    strncpy(new_node->codice, code, sizeof(new_node->codice) - 1);
    strncpy(new_node->prompt_it, it, sizeof(new_node->prompt_it) - 1);
    strncpy(new_node->prompt_en, en, sizeof(new_node->prompt_en) - 1);
    new_node->next = *head;
    *head = new_node;
    return new_node;
}

/*
 * Grafo di conoscenza di riserva cablato in memoria.
 * Viene usato se i file del database non sono reperibili su disco.
 */
static void load_fallback_knowledge_graph(DiagnosisNode **diag_head, SymptomNode **sym_head) {
    add_diagnosis(diag_head, "401.9",  "Ipertensione arteriosa essenziale", "Essential Hypertension");
    add_diagnosis(diag_head, "250.00", "Diabete mellito tipo 2", "Type 2 Diabetes Mellitus");
    add_diagnosis(diag_head, "486",    "Polmonite batterica", "Bacterial Pneumonia");
    add_diagnosis(diag_head, "780.60", "Febbre non specificata", "Fever of unknown origin");
    add_diagnosis(diag_head, "786.50", "Dolore toracico non specificato", "Chest pain unspecified");
    add_diagnosis(diag_head, "784.0",  "Cefalea e dolore facciale", "Headache and Facial Pain");
    add_diagnosis(diag_head, "530.81", "Reflusso gastroesofageo (MRGE)", "Gastroesophageal Reflux (GERD)");

    SymptomNode *s1 = add_symptom(sym_head, 1, "SYM_CHEST_PRESS", "Avverti senso di oppressione al petto?", "Do you experience severe chest tightness?");
    add_weight(&(s1->weights_head), "401.9", 0.4250);
    add_weight(&(s1->weights_head), "530.81", 0.2800);

    SymptomNode *s2 = add_symptom(sym_head, 2, "SYM_FEVER", "Hai febbre alta (>38.5 C) o brividi?", "Do you have high fever (>38.5 C) or chills?");
    add_weight(&(s2->weights_head), "486", 0.4850);
    add_weight(&(s2->weights_head), "784.0", 0.1200);

    SymptomNode *s3 = add_symptom(sym_head, 3, "SYM_COUGH", "Presenti tosse persistente?", "Do you suffer from a persistent cough?");
    add_weight(&(s3->weights_head), "486", 0.4500);

    SymptomNode *s4 = add_symptom(sym_head, 4, "SYM_HEADACHE", "Soffri di dolore pulsante al capo?", "Do you feel throbbing head pain?");
    add_weight(&(s4->weights_head), "784.0", 0.5200);

    SymptomNode *s5 = add_symptom(sym_head, 5, "SYM_REFLUX", "Avverti bruciore retrosternale?", "Do you notice acid reflux or burning?");
    add_weight(&(s5->weights_head), "530.81", 0.5800);
}

/*
 * Carica la base di conoscenza (diagnosi, sintomi e relazioni pesate)
 * leggendo dai file SQL DML o dal file di testo locale.
 */
static void load_knowledge_graph_from_text(DiagnosisNode **diag_head, SymptomNode **sym_head) {
    FILE *f = fopen("Rukavishnikov_DMLPOP.sql", "r");
    if (!f) f = fopen("Rukavishnikov_DMLPOP_11.sql", "r");
    if (!f) f = fopen("Rukavishnikov_db_data.txt", "r");

    if (!f) {
        load_fallback_knowledge_graph(diag_head, sym_head);
        return;
    }

    char line[1024];
    int section = 0;

    while (fgets(line, sizeof(line), f)) {
        if (strstr(line, "DIZIONARIO_DIAGNOSI")) { section = 1; continue; }
        if (strstr(line, "SINTOMO (sintomo_id")) { section = 2; continue; }
        if (strstr(line, "MAPPA_SINTOMO_DIAGNOSI")) { section = 3; continue; }

        if (section == 1 && line[0] == '(') {
            char code[16] = {0}, it[128] = {0}, en[128] = {0};
            if (sscanf(line, " ('%15[^']', '%127[^']', '%127[^']'", code, it, en) == 3) {
                add_diagnosis(diag_head, code, it, en);
            }
        } else if (section == 2 && line[0] == '(') {
            int id, parte;
            char code[64] = {0}, it[256] = {0}, en[256] = {0};
            if (sscanf(line, " (%d, '%63[^']', %d, '%255[^']', '%255[^']'", &id, code, &parte, it, en) == 5) {
                add_symptom(sym_head, id, code, it, en);
            }
        } else if (section == 3 && line[0] == '(') {
            int s_id;
            char icd[16] = {0};
            double w;
            if (sscanf(line, " (%d, '%15[^']', %lf)", &s_id, icd, &w) == 3) {
                SymptomNode *curr = *sym_head;
                while (curr) {
                    if (curr->sintomo_id == s_id) {
                        add_weight(&(curr->weights_head), icd, w);
                        break;
                    }
                    curr = curr->next;
                }
            }
        }
    }
    fclose(f);

    if (!(*diag_head) || !(*sym_head)) {
        load_fallback_knowledge_graph(diag_head, sym_head);
    }
}

/*
 * Libera tutta la memoria dinamica occupata dal grafo di conoscenza.
 */
static void free_knowledge_graph(DiagnosisNode *diag_head, SymptomNode *sym_head) {
    DiagnosisNode *d_tmp;
    SymptomNode *s_tmp;
    WeightNode *w_tmp;

    while (diag_head) {
        d_tmp = diag_head;
        diag_head = diag_head->next;
        free(d_tmp);
    }

    while (sym_head) {
        s_tmp = sym_head;
        while (s_tmp->weights_head) {
            w_tmp = s_tmp->weights_head;
            s_tmp->weights_head = s_tmp->weights_head->next;
            free(w_tmp);
        }
        sym_head = sym_head->next;
        free(s_tmp);
    }
}

/*
 * Permette l'inserimento interattivo di una nuova patologia nel DB.
 * Scrive la query INSERT INTO sia nel file di testo che nello script DML.
 */
void add_new_disease_standalone(int lang) {
    DiagnosisNode *diag_list = NULL;
    SymptomNode *sym_list = NULL;
    load_knowledge_graph_from_text(&diag_list, &sym_list);

    char code[16] = {0}, name_it[128] = {0}, name_en[128] = {0};
    char buf[256];

    CLEAR_SCREEN();
    printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
    if (lang == 1) {
        printf("%s===               AGGIUNGI NUOVA PATOLOGIA AL DATABASE             ===%s\n", COLOR_CYAN, COLOR_RESET);
    } else {
        printf("%s===               ADD NEW DISEASE TO DATABASE                      ===%s\n", COLOR_CYAN, COLOR_RESET);
    }
    printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);

    if (lang == 1) printf("Inserisci Codice ICD-9 (es. 780.99) [0 per annullare]: ");
    else printf("Enter ICD-9 Code (e.g., 780.99) [0 to cancel]: ");
    fflush(stdout);
    if (!fgets(buf, sizeof(buf), stdin)) return;
    sscanf(buf, "%15s", code);

    if (strcmp(code, "0") == 0) {
        free_knowledge_graph(diag_list, sym_list);
        return;
    }

    if (lang == 1) printf("Inserisci Nome Patologia (Italiano): ");
    else printf("Enter Pathology Name (Italian): ");
    fflush(stdout);
    if (!fgets(buf, sizeof(buf), stdin)) return;
    buf[strcspn(buf, "\r\n")] = 0;
    strncpy(name_it, buf, sizeof(name_it) - 1);

    if (lang == 1) printf("Inserisci Nome Patologia (Inglese): ");
    else printf("Enter Pathology Name (English): ");
    fflush(stdout);
    if (!fgets(buf, sizeof(buf), stdin)) return;
    buf[strcspn(buf, "\r\n")] = 0;
    strncpy(name_en, buf, sizeof(name_en) - 1);

    if (strlen(code) > 0 && strlen(name_it) > 0) {
        add_diagnosis(&diag_list, code, name_it, name_en);

        FILE *f = fopen("Rukavishnikov_db_data.txt", "a");
        if (f) {
            fprintf(f, "INSERT INTO DIZIONARIO_DIAGNOSI (codice, descrizione_it, descrizione_en, sistema, attivo) VALUES ('%s', '%s', '%s', 'ICD-9', 'Y');\n", code, name_it, name_en);
            fclose(f);
        }
        FILE *f_sql = fopen("Rukavishnikov_DMLPOP.sql", "a");
        if (f_sql) {
            fprintf(f_sql, "\n-- Dynamic User Added Disease\nINSERT INTO DIZIONARIO_DIAGNOSI (codice, descrizione_it, descrizione_en, sistema, attivo) VALUES ('%s', '%s', '%s', 'ICD-9', 'Y');\n", code, name_it, name_en);
            fclose(f_sql);
        }

        if (lang == 1) printf("\n%s[SUCCESSO] Patologia '%s' (%s) aggiunta con successo al DB!%s\n", COLOR_GREEN, name_it, code, COLOR_RESET);
        else printf("\n%s[SUCCESS] Pathology '%s' (%s) successfully added to DB!%s\n", COLOR_GREEN, name_it, code, COLOR_RESET);
        log_to_file("Nuova patologia aggiunta manualmente al DB.");
    } else {
        if (lang == 1) printf("\n%s[ERRORE] Dati non validi.%s\n", COLOR_RED, COLOR_RESET);
        else printf("\n%s[ERROR] Invalid data.%s\n", COLOR_RED, COLOR_RESET);
    }
    
    free_knowledge_graph(diag_list, sym_list);
    if (lang == 1) printf("  Premere Invio per continuare...");
    else printf("  Press Enter to continue...");
    print_footer();
    printf("\033[4A\033[35C");
    fflush(stdout);
    fgets(buf, sizeof(buf), stdin);
}

/*
 * Ciclo interattivo della diagnosi clinica (Motore AI DSS).
 *
 * Utilizza la funzione Softmax per calcolare le probabilita delle varie diagnosi,
 * sceglie la domanda migliore in base all'utilita informativa e aggiorna i punteggi.
 */
void run_ai_dss_diagnosis(int lang) {
    DiagnosisNode *diag_list = NULL;
    SymptomNode *sym_list = NULL;
    DiagnosisNode *d_curr = NULL;
    DiagnosisNode *best_diag = NULL;
    DiagnosisNode *second_diag = NULL;
    DiagnosisNode *final_confirmed_diag = NULL;
    WeightNode *w_curr = NULL;

    int choice, confirm;
    double multiplier, sum_exp;
    int loop_active = 1;
    int q_counter = 1;
    char input_buf[64];

    load_knowledge_graph_from_text(&diag_list, &sym_list);

    while (loop_active) {
        /* 1. Calcolo della distribuzione di probabilita Softmax sulle diagnosi attive */
        sum_exp = 0.0;
        d_curr = diag_list;
        while (d_curr) {
            if (!d_curr->rejected) {
                sum_exp += exp(d_curr->score);
            }
            d_curr = d_curr->next;
        }

        best_diag = NULL;
        second_diag = NULL;
        d_curr = diag_list;
        while (d_curr) {
            if (!d_curr->rejected && sum_exp > 0.0) {
                d_curr->confidence = exp(d_curr->score) / sum_exp;
                if (!best_diag || d_curr->confidence > best_diag->confidence) {
                    second_diag = best_diag;
                    best_diag = d_curr;
                } else if (!second_diag || d_curr->confidence > second_diag->confidence) {
                    second_diag = d_curr;
                }
            } else {
                d_curr->confidence = 0.0;
            }
            d_curr = d_curr->next;
        }

        /* 2. Verifica se la diagnosi principale ha raggiunto la soglia di confidenza */
        int threshold_reached = 0;
        if (best_diag) {
            double second_conf = second_diag ? second_diag->confidence : 0.0;
            double margin_ratio = (second_conf > 0.0001) ? (best_diag->confidence / second_conf) : 10.0;

            if ((q_counter >= 2 && best_diag->confidence >= 0.45) || 
                (best_diag->score >= 1.20 && margin_ratio >= 1.50) || 
                (q_counter >= 8 && best_diag->confidence >= 0.30)) {
                threshold_reached = 1;
            }
        }

        /* Propone l'ipotesi al medico se la confidenza e sufficiente */
        if (best_diag && threshold_reached) {
            CLEAR_SCREEN();
            printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
            if (lang == 1) {
                printf("%s===              IPOTESI DIAGNOSTICA AI DSS CLINICO                 ===%s\n", COLOR_CYAN, COLOR_RESET);
            } else {
                printf("%s===              AI CLINICAL DSS DIAGNOSTIC HYPOTHESIS             ===%s\n", COLOR_CYAN, COLOR_RESET);
            }
            printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);

            if (lang == 1) {
                printf("Ipotesi Diagnostica AI (%s%.1f%%%s confidenza):\n\n", 
                       COLOR_GREEN, best_diag->confidence * 100.0, COLOR_RESET);
                printf("  Codice ICD-9: %s%s%s\n", COLOR_YELLOW, best_diag->icd_code, COLOR_RESET);
                printf("  Patologia:    %s%s%s\n\n", COLOR_BOLD, best_diag->name_it, COLOR_RESET);
                printf("E corretta questa diagnosi?\n");
                printf("  %s[1]%s Si, conferma diagnosi e chiudi\n", COLOR_YELLOW, COLOR_RESET);
                printf("  %s[2]%s No, malattia errata (continua indagine senza resettare)\n", COLOR_YELLOW, COLOR_RESET);
                printf("  %s[0]%s Interrompi diagnosi e torna al menu principale\n\n", COLOR_RED, COLOR_RESET);
                printf("  Seleziona opzione > ");
            } else {
                printf("AI Diagnostic Hypothesis (%s%.1f%%%s confidence):\n\n", 
                       COLOR_GREEN, best_diag->confidence * 100.0, COLOR_RESET);
                printf("  ICD-9 Code: %s%s%s\n", COLOR_YELLOW, best_diag->icd_code, COLOR_RESET);
                printf("  Disease:    %s%s%s\n\n", COLOR_BOLD, best_diag->name_en, COLOR_RESET);
                printf("Is this diagnosis correct?\n");
                printf("  %s[1]%s Yes, confirm diagnosis\n", COLOR_YELLOW, COLOR_RESET);
                printf("  %s[2]%s No, incorrect disease (continue symptoms evaluation)\n", COLOR_YELLOW, COLOR_RESET);
                printf("  %s[0]%s Stop diagnosis and return to main menu\n\n", COLOR_RED, COLOR_RESET);
                printf("  Select option > ");
            }

            print_footer();
            printf("\033[4A\033[20C");
            fflush(stdout);

            if (fgets(input_buf, sizeof(input_buf), stdin) && sscanf(input_buf, "%d", &confirm) == 1) {
                if (confirm == 1) {
                    final_confirmed_diag = best_diag;
                    loop_active = 0;
                    break;
                } else if (confirm == 0) {
                    loop_active = 0;
                    break;
                } else {
                    best_diag->rejected = 1;
                    continue;
                }
            }
        }

        /* 3. Selezione del sintomo piu utile da chiedere */
        SymptomNode *next_sym = NULL;
        double max_utility = -1.0;
        SymptomNode *s_iter = sym_list;

        while (s_iter) {
            if (!s_iter->asked) {
                double utility = 0.0;
                w_curr = s_iter->weights_head;
                while (w_curr) {
                    DiagnosisNode *d_match = diag_list;
                    while (d_match) {
                        if (!d_match->rejected && strcmp(d_match->icd_code, w_curr->icd_code) == 0) {
                            utility += d_match->confidence * w_curr->weight;
                            break;
                        }
                        d_match = d_match->next;
                    }
                    w_curr = w_curr->next;
                }

                if (utility > max_utility) {
                    max_utility = utility;
                    next_sym = s_iter;
                }
            }
            s_iter = s_iter->next;
        }

        /* Se nessun sintomo ha utilita diretta, ne sceglie uno qualsiasi non ancora chiesto */
        if (!next_sym || max_utility <= 0.0) {
            s_iter = sym_list;
            while (s_iter) {
                if (!s_iter->asked) {
                    next_sym = s_iter;
                    break;
                }
                s_iter = s_iter->next;
            }
        }

        /* Se non ci sono piu sintomi disponibili */
        if (!next_sym) {
            CLEAR_SCREEN();
            printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
            if (lang == 1) printf("%s===              NESSUNA DIAGNOSI CORRISPONDENTE TROVATA           ===%s\n", COLOR_CYAN, COLOR_RESET);
            else printf("%s===                   NO MATCHING DIAGNOSIS FOUND                  ===%s\n", COLOR_CYAN, COLOR_RESET);
            printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);

            if (lang == 1) {
                printf("Tutte le ipotesi valutate sono state respinte o non ci sono sintomi sufficienti.\n\n");
                printf("  Premere Invio per tornare al menu principale...");
            } else {
                printf("All hypotheses were rejected or insufficient symptoms.\n\n");
                printf("  Press Enter to return to main menu...");
            }

            print_footer();
            printf("\033[4A\033[35C");
            fflush(stdout);
            fgets(input_buf, sizeof(input_buf), stdin);
            break;
        }

        /* 4. Stampa la domanda sul sintomo selezionato e legge la risposta */
        CLEAR_SCREEN();
        printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
        if (lang == 1) printf("%s===               MOTORE AI DSS CLINICO - VALUTAZIONE              ===%s\n", COLOR_CYAN, COLOR_RESET);
        else printf("%s===               AI CLINICAL DSS ENGINE - EVALUATION              ===%s\n", COLOR_CYAN, COLOR_RESET);
        printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);

        if (lang == 1) {
            printf("%s[Domanda %d]%s %s%s%s\n\n", COLOR_YELLOW, q_counter, COLOR_RESET, 
                   COLOR_BOLD, next_sym->prompt_it, COLOR_RESET);
            printf("  %s[1]%s Fortemente d accordo (+1.0)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[2]%s D accordo (+0.5)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[3]%s Neutro / Non so (0.0)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[4]%s In disaccordo (-0.5)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[5]%s Fortemente in disaccordo (-1.0)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[6]%s Sintomo irrilevante (Torna al menu principale)\n", COLOR_ORANGE, COLOR_RESET);
            printf("  %s[0]%s Interrompi processo diagnostico\n\n", COLOR_RED, COLOR_RESET);
            printf("  Seleziona opzione > ");
        } else {
            printf("%s[Question %d]%s %s%s%s\n\n", COLOR_YELLOW, q_counter, COLOR_RESET, 
                   COLOR_BOLD, next_sym->prompt_en, COLOR_RESET);
            printf("  %s[1]%s Strongly Agree (+1.0)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[2]%s Agree (+0.5)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[3]%s Neutral / Don't Know (0.0)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[4]%s Disagree (-0.5)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[5]%s Strongly Disagree (-1.0)\n", COLOR_YELLOW, COLOR_RESET);
            printf("  %s[6]%s Insignificant symptom (Return to Main Menu)\n", COLOR_ORANGE, COLOR_RESET);
            printf("  %s[0]%s Stop diagnostic process\n\n", COLOR_RED, COLOR_RESET);
            printf("  Select option > ");
        }

        print_footer();
        printf("\033[4A\033[20C");
        fflush(stdout);

        if (!fgets(input_buf, sizeof(input_buf), stdin) || sscanf(input_buf, "%d", &choice) != 1) {
            continue;
        }

        if (choice == 0 || choice == 6) {
            loop_active = 0;
            break;
        }

        /* Mappa la scelta dell'utente in un valore moltiplicatore */
        switch (choice) {
            case 1: multiplier = 1.0; break;
            case 2: multiplier = 0.5; break;
            case 3: multiplier = 0.0; break;
            case 4: multiplier = -0.5; break;
            case 5: multiplier = -1.0; break;
            default: continue;
        }

        next_sym->asked = 1;
        q_counter++;

        /* 5. Aggiorna i punteggi delle patologie in base al peso del sintomo */
        d_curr = diag_list;
        while (d_curr) {
            if (d_curr->rejected) {
                d_curr = d_curr->next;
                continue;
            }

            int linked = 0;
            w_curr = next_sym->weights_head;
            while (w_curr) {
                if (strcmp(d_curr->icd_code, w_curr->icd_code) == 0) {
                    d_curr->score += w_curr->weight * multiplier;
                    linked = 1;
                    break;
                }
                w_curr = w_curr->next;
            }

            /* Penalita se la patologia non e legata al sintomo ma la risposta era positiva */
            if (!linked && multiplier > 0.0) {
                d_curr->score -= 0.25 * multiplier;
            }
            d_curr = d_curr->next;
        }
    }

    /* Schermata di riepilogo in caso di diagnosi confermata */
    if (final_confirmed_diag) {
        CLEAR_SCREEN();
        printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
        if (lang == 1) printf("%s===                RISULTATO VALUTAZIONE DSS CLINICO               ===%s\n", COLOR_CYAN, COLOR_RESET);
        else printf("%s===                CLINICAL DSS EVALUATION RESULT                  ===%s\n", COLOR_CYAN, COLOR_RESET);
        printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);

        if (lang == 1) {
            printf("Stato:       %sCONFERMATO DAL CLINICO%s\n", COLOR_GREEN, COLOR_RESET);
            printf("Codice ICD-9:%s%s%s\n", COLOR_YELLOW, final_confirmed_diag->icd_code, COLOR_RESET);
            printf("Diagnosi:    %s%s%s\n", COLOR_BOLD, final_confirmed_diag->name_it, COLOR_RESET);
            printf("Confidenza:  %s%.2f%%%s\n\n", COLOR_GREEN, final_confirmed_diag->confidence * 100.0, COLOR_RESET);
            printf("  Premere Invio per tornare al menu principale... ");
        } else {
            printf("Status:      %sCONFIRMED BY CLINICIAN%s\n", COLOR_GREEN, COLOR_RESET);
            printf("ICD-9 Code:  %s%s%s\n", COLOR_YELLOW, final_confirmed_diag->icd_code, COLOR_RESET);
            printf("Diagnosis:   %s%s%s\n", COLOR_BOLD, final_confirmed_diag->name_en, COLOR_RESET);
            printf("Confidence:  %s%.2f%%%s\n\n", COLOR_GREEN, final_confirmed_diag->confidence * 100.0, COLOR_RESET);
            printf("  Press Enter to return to main menu... ");
        }

        fflush(stdout);
        fgets(input_buf, sizeof(input_buf), stdin);
    }

    free_knowledge_graph(diag_list, sym_list);
}