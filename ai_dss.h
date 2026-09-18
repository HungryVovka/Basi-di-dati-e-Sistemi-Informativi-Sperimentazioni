/*
 * ai_dss.h - Strutture e prototipi per il motore diagnostico (AI DSS).
 */

#ifndef AI_DSS_H
#define AI_DSS_H

#include <math.h>
#include "utils.h"

/* Soglia minima di confidenza per proporre un'ipotesi diagnostica */
#define CONFIDENCE_HYPOTHESIS_THRESHOLD 0.60

/* Nodo per la lista dei pesi: collega un sintomo a una patologia */
typedef struct WeightNode {
    char icd_code[16];       /* Codice patologia di riferimento (ICD-9) */
    double weight;           /* Peso/rilevanza clinica del sintomo */
    struct WeightNode *next; /* Prossimo peso nella lista */
} WeightNode;

/* Nodo per i sintomi (domande da porre durante la diagnosi) */
typedef struct SymptomNode {
    int sintomo_id;          /* ID univoco del sintomo nel DB */
    char codice[64];         /* Codice identificativo (es. SYM_CHEST_PRESS) */
    char prompt_it[256];     /* Testo della domanda in italiano */
    char prompt_en[256];     /* Testo della domanda in inglese */
    int asked;               /* 1 se la domanda e gia stata fatta, 0 altrimenti */
    WeightNode *weights_head;/* Lista dei pesi associati alle diagnosi */
    struct SymptomNode *next;/* Prossimo sintomo nella lista */
} SymptomNode;

/* Nodo per l'ipotesi diagnostica (patologia) */
typedef struct DiagnosisNode {
    char icd_code[16];          /* Codice ICD-9 */
    char name_it[128];          /* Nome patologia in italiano */
    char name_en[128];          /* Nome patologia in inglese */
    double score;               /* Punteggio grezzo accumulato dalle risposte */
    double confidence;          /* Probabilita calcolata (Softmax) */
    int rejected;               /* 1 se l'ipotesi e stata scartata dal medico, 0 altrimenti */
    struct DiagnosisNode *next; /* Prossima diagnosi nella lista */
} DiagnosisNode;

/*
 * Avvia la procedura diagnostica interattiva: fa domande sui sintomi,
 * aggiorna le probabilita e mostra il risultato quando convergere.
 * lang: 1 = Italiano, altro = Inglese.
 */
void run_ai_dss_diagnosis(int lang);

/*
 * Inserimento manuale di una nuova patologia salvando i dati su file DB.
 * lang: 1 = Italiano, altro = Inglese.
 */
void add_new_disease_standalone(int lang);

#endif