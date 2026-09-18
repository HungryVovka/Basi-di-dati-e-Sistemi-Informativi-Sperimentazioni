/*
 * db_engine.h - Strutture dati e prototipi per la gestione del database in memoria.
 */

#ifndef DB_ENGINE_H
#define DB_ENGINE_H

#include "utils.h"

/* Colonna di una tabella SQL */
typedef struct ColumnNode {
    char col_name[64];       /* Nome della colonna */
    char col_type[32];       /* Tipo SQL (es. VARCHAR, INT, DATE) */
    int is_pk;               /* 1 se e chiave primaria, 0 altrimenti */
    int is_fk;               /* 1 se e chiave esterna, 0 altrimenti */
    char fk_target[64];      /* Tabella e colonna di destinazione se Foreign Key */
    struct ColumnNode *next; /* Prossima colonna nella lista */
} ColumnNode;

/* Singola riga di dati (record) della tabella */
typedef struct DataRowNode {
    char row_data[1024];     /* Stringa con la riga di dati o la query di inserimento */
    struct DataRowNode *next;/* Prossima riga nella lista */
} DataRowNode;

/* Tabella del database contenente schema, record e vincoli */
typedef struct TableNode {
    char table_name[64];     /* Nome della tabella SQL */
    int record_count;        /* Numero di record caricati */
    char dependencies[256];  /* Descrizione delle dipendenze/FK da altre tabelle */
    ColumnNode *cols_head;   /* Lista delle colonne */
    DataRowNode *rows_head;  /* Lista dei dati */
    struct TableNode *next;  /* Prossima tabella nella lista */
} TableNode;

/*
 * Legge i file SQL (DDL e DML) e carica le tabelle in memoria.
 * Ritorna il puntatore alla testa della lista o NULL se non trova i file.
 */
TableNode* load_tables_from_sql_files(void);

/*
 * Libera tutta la memoria allocata per la lista delle tabelle (comprese colonne e righe).
 */
void free_table_linked_list(TableNode *head);

/*
 * Interfaccia da terminale per esplorare lo schema e il contenuto delle tabelle.
 * lang: 1 = Italiano, altro = Inglese.
 */
void display_tables_gui(int lang);

/*
 * Legge ed esegue uno script SQL da file di testo.
 * lang: 1 = Italiano, altro = Inglese.
 */
void execute_sql_file(int lang);

/*
 * Esegue un comando SQL manuale da riga di comando.
 * Se viene creata una tabella, aggiorna anche il file DDL su disco.
 * lang: 1 = Italiano, altro = Inglese.
 */
void execute_custom_sql_query(int lang);

#endif