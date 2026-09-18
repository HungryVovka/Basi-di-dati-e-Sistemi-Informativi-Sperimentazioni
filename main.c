/*
 * main.c - Punto d'ingresso dell'applicazione.
 *
 * Gestisce l'interfaccia utente CLI, il rilevamento della lingua di sistema
 * e il ciclo principale di navigazione tra i moduli del programma.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "utils.h"
#include "db_engine.h"
#include "ai_dss.h"

#if defined(_WIN32) || defined(_WIN64)
    #include <windows.h> /* Header Windows per impostazioni locali e colori console */
#endif

/* Lingue supportate dall'interfaccia */
typedef enum { LANG_EN = 0, LANG_IT = 1 } Language;

/* Lingua attiva nell'applicazione (di default Inglese) */
static Language current_lang = LANG_EN;

/*
 * Controlla la lingua predefinita del sistema operativo.
 * Su Windows legge l'ID lingua dalle API Win32, su Linux/macOS controlla
 * le variabili d'ambiente LANG e LC_*.
 *
 * Ritorna LANG_IT se rileva l'italiano, altrimenti LANG_EN.
 */
static Language detect_system_language(void) {
#if defined(_WIN32) || defined(_WIN64)
    /* Rilevamento locale su Windows */
    LANGID langId = GetUserDefaultUILanguage();
    if ((langId & 0xFF) == 0x10) { /* 0x10 = lingua italiana */
        return LANG_IT;
    }
#endif
    /* Rilevamento su sistemi POSIX (Linux e macOS) */
    const char *lang = getenv("LANG");
    if (!lang) lang = getenv("LC_ALL");
    if (!lang) lang = getenv("LC_MESSAGES");

    if (lang && (strncmp(lang, "it", 2) == 0 || strncmp(lang, "IT", 2) == 0)) {
        return LANG_IT;
    }
    return LANG_EN;
}

/*
 * Pulisce lo schermo e disegna il menu principale traducendolo
 * in base alla lingua impostata al momento.
 */
void print_main_menu(void) {
    CLEAR_SCREEN();
    printf("%s======================================================================%s\n", COLOR_CYAN, COLOR_RESET);
    
    if (current_lang == LANG_IT) {
        printf("%s===      PIATTAFORMA OSPEDALIERA & AI DSS (INTERFACCIA SQL & CLI)  ===%s\n", COLOR_CYAN, COLOR_RESET);
        printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);
        printf("Stato Database: %s[MOTORE TESTUALE DB ATTIVO]%s\n\n", COLOR_GREEN, COLOR_RESET);
        
        printf("  %s[1]%s  Avvia Diagnosi Interattiva Motore IA DSS (AI DSS Engine)\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[2]%s  Aggiungi Nuova Patologia nel Database (Modulo IA DSS)\n\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[3]%s  Ispeziona tabelle DB (Visualizzatore Struttura/Dati e Dipendenze)\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[4]%s  Esegui script SQL completo da file (.sql)\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[5]%s  Esegui query SQL personalizzata (Console SQL)\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[6]%s  Cambia lingua / Change Language (English / Italiano)\n\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[0]%s  Uscita\n\n", COLOR_RED, COLOR_RESET);
        printf("  %sSeleziona un opzione > %s", COLOR_GREEN, COLOR_RESET);
    } else {
        printf("%s===     HOSPITAL PLATFORM & AI DSS (SQL & CLI INTERFACE)     ===%s\n", COLOR_CYAN, COLOR_RESET);
        printf("%s======================================================================%s\n\n", COLOR_CYAN, COLOR_RESET);
        printf("Database Status: %s[TEXT DB ENGINE ACTIVE]%s\n\n", COLOR_GREEN, COLOR_RESET);
        
        printf("  %s[1]%s  Run Interactive AI DSS Diagnostic Engine\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[2]%s  Add New Disease / Pathology to Database (AI DSS Knowledge Base)\n\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[3]%s  Inspect DB Tables (Structure, Data & Dependencies Viewer)\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[4]%s  Execute full SQL script from file (.sql)\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[5]%s  Execute custom SQL query (SQL Console)\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[6]%s  Change Language / Cambia lingua (English / Italiano)\n\n", COLOR_YELLOW, COLOR_RESET);
        printf("  %s[0]%s  Exit\n\n", COLOR_RED, COLOR_RESET);
        printf("  %sSelect option > %s", COLOR_GREEN, COLOR_RESET);
    }
    
    print_footer();
    /* Sequenza ANSI per riposizionare il cursore sul campo di input */
    printf("\033[4A\033[25C");
    fflush(stdout);
}

/*
 * Entry point del programma.
 * Configura la console, rileva la lingua del sistema ed esegue
 * il ciclo principale del menu ricevendo l'input dell'utente.
 */
int main(void) {
    int choice = -1;
    int running = 1;
    char input_buf[64];

    /* Attiva i codici colore ANSI se in esecuzione su terminale Windows */
    enable_windows_vt_mode();
    
    /* Identifica la lingua all'avvio */
    current_lang = detect_system_language();
    log_to_file("Applicazione avviata con rilevamento automatico della lingua del SO.");

    /* Ciclo interattivo dell'applicazione */
    while (running) {
        print_main_menu();

        /* Lettura dell'input dell'utente */
        if (!fgets(input_buf, sizeof(input_buf), stdin)) {
            continue;
        }

        /* Estrazione del numero di opzione selezionato */
        if (sscanf(input_buf, "%d", &choice) != 1) {
            continue;
        }

        /* Smistamento del comando selezionato */
        switch (choice) {
            case 1:
                run_ai_dss_diagnosis((int)current_lang);
                break;
            case 2:
                add_new_disease_standalone((int)current_lang);
                break;
            case 3:
                display_tables_gui((int)current_lang);
                break;
            case 4:
                execute_sql_file((int)current_lang);
                break;
            case 5:
                execute_custom_sql_query((int)current_lang);
                break;
            case 6:
                /* Inverte la lingua corrente (IT <-> EN) */
                current_lang = (current_lang == LANG_IT) ? LANG_EN : LANG_IT;
                break;
            case 0:
                running = 0;
                break;
            default:
                break;
        }
    }

    CLEAR_SCREEN();
    log_to_file("Applicazione chiusa correttamente.");
    printf("%s[SISTEMA]%s Arrivederci!\n\n", COLOR_CYAN, COLOR_RESET);
    return 0;
}