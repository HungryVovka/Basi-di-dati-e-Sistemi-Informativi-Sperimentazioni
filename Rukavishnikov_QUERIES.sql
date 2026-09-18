-- =============================================================================
-- UNIVERSITÀ DEL PIEMONTE ORIENTALE (UPO)
-- Corso di Basi di Dati e Sistemi Informativi - A.A. 2025-2026
-- Script SQL: Operazioni dei 20 Scenari Operativi e Query Analitiche
-- Autore: Vladimir Rukavishnikov (Matr. 20063686)
-- File: Rukavishnikov_QUERIES.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SCENARIO 1: INSERIMENTO PAZIENTE E CONSENSI
-- -----------------------------------------------------------------------------
INSERT INTO PAZIENTE (paziente_id, codice_fiscale, nome, cognome, data_nascita, sesso, email, telefono, indirizzo, medico_base, consenso_trattamento_dati, consenso_ia, note_cliniche_sintetiche)
VALUES (6, 'SNTGNN90A01H501Z', 'Giovanni', 'Santoro', '1990-01-01', 'M', 'giovanni.santoro@email.it', '+39 340 9998877', 'Via Roma 15, Novara', 'Dr. Alberto Ferrari', 'Y', 'Y', 'Nessuna patologia nota')
ON CONFLICT (paziente_id) DO NOTHING;

INSERT INTO CONTATTO_EMERGENZA (contatto_id, paziente_id, nome, relazione, telefono)
VALUES (6, 6, 'Maria Santoro', 'Madre', '+39 349 9990000')
ON CONFLICT (contatto_id) DO NOTHING;

INSERT INTO CONSENSO (consenso_id, paziente_id, tipo, stato, valido_dal, note)
VALUES (11, 6, 'PRIVACY', 'CONCESSO', CURRENT_TIMESTAMP, 'Consenso acquisito all inserimento')
ON CONFLICT (consenso_id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SCENARIO 2: INSERIMENTO MEDICO
-- -----------------------------------------------------------------------------
INSERT INTO MEDICO (medico_id, matricola_medico, albo_numero, nome, cognome, specializzazione, reparto_id, email, telefono, attivo)
VALUES (5, 'MED-1005', 54325, 'Andrea', 'Moretti', 'Cardiologia', 1, 'andrea.moretti@ospedale.it', '+39 333 1000005', 'Y')
ON CONFLICT (medico_id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SCENARIO 3: CREAZIONE REPARTO
-- -----------------------------------------------------------------------------
INSERT INTO REPARTO (reparto_id, nome, ubicazione, telefono, capo_medico_id)
VALUES (5, 'Otoprotesi e ORL', 'Blocco D - Piano 1', '+39 0321 555555', NULL)
ON CONFLICT (reparto_id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SCENARIO 4: CREAZIONE AMBULATORIO E MAPPATURA
-- -----------------------------------------------------------------------------
INSERT INTO AMBULATORIO (ambulatorio_id, reparto_id, nome, sede, specialita)
VALUES (5, 5, 'Ambulatorio Otorinolaringoiatria', 'Stanza D101', 'Otorinolaringoiatria')
ON CONFLICT (ambulatorio_id) DO NOTHING;

INSERT INTO MAPPA_MEDICO_AMBULATORIO (medico_id, ambulatorio_id)
VALUES (1, 5)
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- SCENARIO 5: GENERAZIONE AGENDA / SLOT CALENDARIO
-- -----------------------------------------------------------------------------
INSERT INTO CALENDARIO_SLOT (slot_id, ambulatorio_id, medico_id, inizio, fine, stato, fonte)
VALUES (6, 1, 1, '2026-09-15 09:00:00', '2026-09-15 09:30:00', 'LIBERO', 'SISTEMA')
ON CONFLICT (slot_id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SCENARIO 6: INSERIMENTO PRENOTAZIONE
-- -----------------------------------------------------------------------------
INSERT INTO PRENOTAZIONE (prenotazione_id, paziente_id, ambulatorio_id, visita_tipo_id, medico_id, priorita, motivo, inizio, fine, stato)
VALUES (6, 6, 1, 1, 1, 'ORDINARIA', 'Controllo di routine pressione', '2026-09-15 09:00:00', '2026-09-15 09:30:00', 'CONFERMATA')
ON CONFLICT (prenotazione_id) DO NOTHING;

UPDATE CALENDARIO_SLOT SET stato = 'OCCUPATO' WHERE slot_id = 6;

-- -----------------------------------------------------------------------------
-- SCENARIO 7: CHECK-IN E APERTURA VISITA
-- -----------------------------------------------------------------------------
INSERT INTO VISITA (visita_id, prenotazione_id, paziente_id, medico_id, ambulatorio_id, anamnesi, sintomi, esame_obiettivo, vitali_testo, stato, started_at)
VALUES (4, 6, 6, 1, 1, 'Paziente privo di anamnesi patologica remota', 'Sintomi lievi di affaticamento', 'EOC nella norma', 'PA 120/80, FC 70 bpm', 'APERTA', CURRENT_TIMESTAMP)
ON CONFLICT (visita_id) DO NOTHING;

UPDATE PRENOTAZIONE SET stato = 'EROGATA' WHERE prenotazione_id = 6;

-- -----------------------------------------------------------------------------
-- SCENARIO 8: PRESCRIZIONE ESAMI
-- -----------------------------------------------------------------------------
INSERT INTO ESAME (esame_id, visita_id, tipo, codice_loinc, stato, programmato_per)
VALUES (4, 4, 'Profilo Lipidico Completo', '24331-1', 'PRESCRITTO', CURRENT_TIMESTAMP)
ON CONFLICT (esame_id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SCENARIO 9: INSERIMENTO REFERTO
-- -----------------------------------------------------------------------------
UPDATE ESAME SET stato = 'ESEGUITO', eseguito_il = CURRENT_TIMESTAMP WHERE esame_id = 4;

INSERT INTO REFERTO (referto_id, esame_id, dati_strutturati, allegato_uri, autore_id, versione)
VALUES (3, 4, 'Colesterolo Totale: 190 mg/dL, HDL: 55 mg/dL, LDL: 115 mg/dL', '/storage/ref/ref_104.pdf', 1, 1)
ON CONFLICT (referto_id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SCENARIO 10: FORMULAZIONE DIAGNOSI FINALE
-- -----------------------------------------------------------------------------
INSERT INTO DIAGNOSI (diagnosi_id, visita_id, codice_icd9, descrizione, stato, autore_medico_id, validata_il, versione)
VALUES (4, 4, '401.9', 'Ipertensione arteriosa di grado lieve', 'FINALE', 1, CURRENT_TIMESTAMP, 1)
ON CONFLICT (diagnosi_id) DO NOTHING;

UPDATE VISITA SET stato = 'CHIUSA', ended_at = CURRENT_TIMESTAMP WHERE visita_id = 4;

-- -----------------------------------------------------------------------------
-- SCENARIO 11: GENERAZIONE SUGGERIMENTO IA (DSS)
-- -----------------------------------------------------------------------------
INSERT INTO AI_SUGGERIMENTO (suggerimento_id, visita_id, modello_versione, candidato_codice, candidato_descr, confidenza, spiegazione)
VALUES (4, 4, 'AI-DSS-v2.1', '401.9', 'Ipertensione arteriosa essenziale', 0.8800, 'Riscontrati valori pressori al limite superiore della norma.')
ON CONFLICT (suggerimento_id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SCENARIO 12: VALUTAZIONE IA DA PARTE DEL MEDICO
-- -----------------------------------------------------------------------------
INSERT INTO AI_AZIONE_MEDICO (azione_id, suggerimento_id, medico_id, azione, nota, timestamp)
VALUES (4, 4, 1, 'ACCETTA', 'Confermato quadro diagnostico suggerito dal DSS', CURRENT_TIMESTAMP)
ON CONFLICT (azione_id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SCENARIO 13: AGGIORNAMENTO CONSENSI PRIVACY/IA
-- -----------------------------------------------------------------------------
UPDATE PAZIENTE SET consenso_ia = 'N' WHERE paziente_id = 6;

INSERT INTO CONSENSO (paziente_id, tipo, stato, valido_dal, note)
VALUES (6, 'IA', 'REVOCATO', CURRENT_TIMESTAMP, 'Revoca consenso IA effettuata da sportello');

-- -----------------------------------------------------------------------------
-- SCENARIO 14: CONSULTAZIONE STORICO CLINICO PAZIENTE
-- -----------------------------------------------------------------------------
SELECT 
    p.paziente_id,
    p.nome || ' ' || p.cognome AS paziente_nome,
    v.visita_id,
    v.started_at AS data_visita,
    m.nome || ' ' || m.cognome AS medico_nome,
    r.nome AS reparto_nome,
    d.codice_icd9,
    d.descrizione AS diagnosi_it,
    d.stato AS stato_diagnosi
FROM PAZIENTE p
JOIN VISITA v ON p.paziente_id = v.paziente_id
JOIN MEDICO m ON v.medico_id = m.medico_id
JOIN REPARTO r ON m.reparto_id = r.reparto_id
LEFT JOIN DIAGNOSI d ON v.visita_id = d.visita_id
WHERE p.paziente_id = 1
ORDER BY v.started_at DESC;

-- -----------------------------------------------------------------------------
-- SCENARIO 15: REPORT CARICO DI LAVORO MEDICO E REPARTO
-- -----------------------------------------------------------------------------
SELECT 
    r.nome AS reparto_nome,
    m.medico_id,
    m.matricola_medico,
    m.nome || ' ' || m.cognome AS medico_nome,
    COUNT(v.visita_id) AS totale_visite,
    COUNT(CASE WHEN v.stato = 'CHIUSA' THEN 1 END) AS visite_completate,
    COUNT(CASE WHEN v.stato = 'APERTA' THEN 1 END) AS visite_in_corso
FROM REPARTO r
JOIN MEDICO m ON r.reparto_id = m.reparto_id
LEFT JOIN VISITA v ON m.medico_id = v.medico_id
GROUP BY r.nome, m.medico_id, m.matricola_medico, m.nome, m.cognome
ORDER BY totale_visite DESC;

-- -----------------------------------------------------------------------------
-- SCENARIO 16: MONITORAGGIO LISTE D'ATTESA E PRENOTAZIONI
-- -----------------------------------------------------------------------------
SELECT 
    pr.prenotazione_id,
    p.codice_fiscale,
    p.nome || ' ' || p.cognome AS paziente_nome,
    a.nome AS ambulatorio_nome,
    vt.descrizione AS tipo_prestazione,
    pr.priorita,
    pr.inizio AS orario_inizio,
    pr.stato AS stato_prenotazione
FROM PRENOTAZIONE pr
JOIN PAZIENTE p ON pr.paziente_id = p.paziente_id
JOIN AMBULATORIO a ON pr.ambulatorio_id = a.ambulatorio_id
JOIN VISITA_TIPO vt ON pr.visita_tipo_id = vt.visita_tipo_id
WHERE pr.stato IN ('CREATA', 'CONFERMATA')
ORDER BY 
    CASE WHEN pr.priorita = 'URGENTE' THEN 1 ELSE 2 END,
    pr.inizio ASC;

-- -----------------------------------------------------------------------------
-- SCENARIO 17: VERIFICHE DI INCOMPLETEZZA CLINICA
-- -----------------------------------------------------------------------------
SELECT 
    v.visita_id,
    v.started_at AS ora_inizio,
    p.paziente_id,
    p.nome || ' ' || p.cognome AS paziente_nome,
    m.nome || ' ' || m.cognome AS medico_nome,
    v.sintomi,
    v.stato AS stato_visita,
    COALESCE(d.stato, 'MANCANTE') AS stato_diagnosi
FROM VISITA v
JOIN PAZIENTE p ON v.paziente_id = p.paziente_id
JOIN MEDICO m ON v.medico_id = m.medico_id
LEFT JOIN DIAGNOSI d ON v.visita_id = d.visita_id
WHERE v.stato = 'APERTA' 
   OR d.stato = 'PROVVISORIA'
   OR d.diagnosi_id IS NULL
ORDER BY v.started_at ASC;

-- -----------------------------------------------------------------------------
-- SCENARIO 18: ANNULLAMENTO PRENOTAZIONE E RIPRISTINO SLOT
-- -----------------------------------------------------------------------------
UPDATE PRENOTAZIONE 
SET stato = 'ANNULLATA', note = 'Annullamento richiesto dal paziente' 
WHERE prenotazione_id = 5;

UPDATE CALENDARIO_SLOT 
SET stato = 'LIBERO' 
WHERE slot_id = 5;

-- -----------------------------------------------------------------------------
-- SCENARIO 19: CANCELLAZIONE LOGICA PAZIENTE (DIRITTO ALL'OBLIO/PRIVACY)
-- -----------------------------------------------------------------------------
UPDATE PAZIENTE 
SET email = NULL, 
    telefono = NULL, 
    indirizzo = 'DATO ANONIMIZZATO SU RICHIESTA PRIVACY',
    note_cliniche_sintetiche = 'Profilo disattivato'
WHERE paziente_id = 5;

-- -----------------------------------------------------------------------------
-- SCENARIO 20: MANUTENZIONE E PULIZIA AUDIT LOG
-- -----------------------------------------------------------------------------
DELETE FROM LOG 
WHERE timestamp < CURRENT_TIMESTAMP - INTERVAL '1 year';