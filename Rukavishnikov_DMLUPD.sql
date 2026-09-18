-- =============================================================================
-- UNIVERSITÀ DEL PIEMONTE ORIENTALE (UPO)
-- Corso di Basi di Dati e Sistemi Informativi - A.A. 2025-2026
-- Script DML: Operazioni di Aggiornamento, Cancellazione e Test Vincoli (DMLUPD v2.0)
-- Autore: Vladimir Rukavishnikov (Matr. 20063686)
-- File: Rukavishnikov_DMLUPD.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. OPERAZIONI DI AGGIORNAMENTO CLINICO E OPERATIVO (UPDATE)
-- -----------------------------------------------------------------------------

-- Scenario 1.1: Annullamento Prenotazione e Ripristino Slot (Scenario 18)
UPDATE PRENOTAZIONE
SET stato = 'ANNULLATA',
    note = 'Annullata dal paziente per motivi personali'
WHERE prenotazione_id = 4;

UPDATE CALENDARIO_SLOT
SET stato = 'LIBERO'
WHERE slot_id = 4;

-- Scenario 1.2: Modifica Consenso IA e Tracciamento Storico (Scenari 1, 13)
UPDATE PAZIENTE
SET consenso_ia = 'N'
WHERE paziente_id = 3;

INSERT INTO CONSENSO (paziente_id, tipo, stato, valido_dal, note)
VALUES (3, 'IA', 'REVOCATO', CURRENT_TIMESTAMP, 'Revoca del consenso per decisioni IA effettuata da sportello');

-- Scenario 1.3: Chiusura Visita e Validazione Diagnosi Finale (Scenari 7, 10)
UPDATE VISITA
SET stato = 'CHIUSA',
    ended_at = CURRENT_TIMESTAMP
WHERE visita_id = 3;

UPDATE DIAGNOSI
SET stato = 'FINALE',
    validata_il = CURRENT_TIMESTAMP
WHERE diagnosi_id = 3;

-- Scenario 1.4: Disattivazione Anagrafica Medico
UPDATE MEDICO
SET attivo = 'N',
    updated_at = CURRENT_TIMESTAMP
WHERE medico_id = 4;

-- -----------------------------------------------------------------------------
-- 2. OPERAZIONI DI CANCELLAZIONE E INTEGRITÀ REFERENZIALE (DELETE)
-- -----------------------------------------------------------------------------

-- Scenario 2.1: Test ON DELETE CASCADE
-- Eliminazione di una Visita: cancella in cascata Allegati, Esami, Referti, Diagnosi e AI_Suggerimento
DELETE FROM VISITA
WHERE visita_id = 1;

-- Scenario 2.2: Test ON DELETE SET NULL
-- Eliminazione di un Medico non vincolato a visite chiuse: azzera le FK opzionali nei reparti e negli slot
DELETE FROM MEDICO
WHERE medico_id = 4;

-- Scenario 2.3: Cancellazione Logica Paziente - Diritto all'oblio / GDPR (Scenario 19)
-- Anonimizzazione dei dati personali garantendo l'integrità della storia clinica
UPDATE PAZIENTE
SET email = NULL,
    telefono = NULL,
    indirizzo = 'DATO CANCELLATO SU RICHIESTA PRIVACY',
    note_cliniche_sintetiche = 'Profilo disattivato per cancellazione logica'
WHERE paziente_id = 5;

-- -----------------------------------------------------------------------------
-- 3. TEST DEI VINCOLI DI INTEGRITÀ E CHECK CONSTRAINT (ECCEZIONI ATTESE)
-- -----------------------------------------------------------------------------

-- Test CHECK 1: Valore confidenza IA fuori dal range consentito [0, 1]
-- ESITO ATTESO: ERROR - violates check constraint "chk_ai_confidenza"
-- INSERT INTO AI_SUGGERIMENTO (visita_id, modello_versione, candidato_codice, candidato_descr, confidenza, spiegazione)
-- VALUES (2, 'AI-DSS-v2.1', '401.9', 'Ipertensione', 1.5000, 'Test valore errato');

-- Test CHECK 2: Slot orario incoerente (ora fine precedente all'inizio)
-- ESITO ATTESO: ERROR - violates check constraint "chk_slot_date"
-- INSERT INTO CALENDARIO_SLOT (ambulatorio_id, inizio, fine, stato)
-- VALUES (1, '2026-10-01 10:00:00', '2026-10-01 09:00:00', 'LIBERO');

-- Test RESTRICT: Tentativo di eliminazione diretta di un Paziente con storia clinica erogata
-- ESITO ATTESO: ERROR - violates foreign key constraint "fk_visita_paziente" (ON DELETE RESTRICT)
-- DELETE FROM PAZIENTE WHERE paziente_id = 2;