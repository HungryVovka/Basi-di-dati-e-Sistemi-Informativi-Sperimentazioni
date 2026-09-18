/*
 * utils.h - Funzioni di utilita, macro per i colori ANSI e compatibilita terminale.
 */

#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* Codici ANSI per la formattazione e i colori nel terminale */
#define COLOR_RESET   "\033[0m"
#define COLOR_BOLD    "\033[1m"
#define COLOR_RED     "\033[1;31m"
#define COLOR_ORANGE  "\033[38;5;208m"
#define COLOR_YELLOW  "\033[1;33m"
#define COLOR_GREEN   "\033[1;32m"
#define COLOR_CYAN    "\033[1;36m"
#define COLOR_BLUE    "\033[1;34m"

/* Gestione pulizia schermo e stringhe in base al sistema operativo */
#if defined(_WIN32) || defined(_WIN64)
    #define CLEAR_SCREEN() system("cls")
    #define strncasecmp _strnicmp
    #define strcasecmp _stricmp
#else
    #define CLEAR_SCREEN() system("clear")
#endif

/* Abilita il supporto ai colori ANSI su console Windows */
void enable_windows_vt_mode(void);

/* Stampa la barra o il pie di pagina di cortesia nella GUI */
void print_footer(void);

/* Scrive una riga di log con timestamp su file */
void log_to_file(const char *action_text);

/* Salva una nuova istruzione DDL in coda al file di testo del database */
void append_ddl_to_txt_file(const char *ddl_statement);

#endif