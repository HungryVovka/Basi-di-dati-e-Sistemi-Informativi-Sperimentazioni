-- =============================================================================
-- UNIVERSITÀ DEL PIEMONTE ORIENTALE (UPO)
-- Corso di Basi di Dati e Sistemi Informativi - A.A. 2025-2026
-- Script DDL: Creazione Struttura Database Ospedaliero & AI DSS (v2.0 Extended)
-- Autore: Vladimir Rukavishnikov (Matr. 20063686)
-- File: Rukavishnikov_DDL.sql
-- =============================================================================

DROP TABLE IF EXISTS LOG CASCADE;
DROP TABLE IF EXISTS UTENTE_SISTEMA CASCADE;
DROP TABLE IF EXISTS AI_AZIONE_MEDICO CASCADE;
DROP TABLE IF EXISTS AI_SUGGERIMENTO CASCADE;
DROP TABLE IF EXISTS MAPPA_SINTOMO_DIAGNOSI CASCADE;
DROP TABLE IF EXISTS SINTOMO CASCADE;
DROP TABLE IF EXISTS CORPO_PARTE CASCADE;
DROP TABLE IF EXISTS DIAGNOSI CASCADE;
DROP TABLE IF EXISTS REFERTO CASCADE;
DROP TABLE IF EXISTS ESAME CASCADE;
DROP TABLE IF EXISTS ALLEGATO_VISITA CASCADE;
DROP TABLE IF EXISTS VISITA CASCADE;
DROP TABLE IF EXISTS PRENOTAZIONE CASCADE;
DROP TABLE IF EXISTS CALENDARIO_SLOT CASCADE;
DROP TABLE IF EXISTS VISITA_TIPO CASCADE;
DROP TABLE IF EXISTS CONSENSO CASCADE;
DROP TABLE IF EXISTS CONTATTO_EMERGENZA CASCADE;
DROP TABLE IF EXISTS PAZIENTE CASCADE;
DROP TABLE IF EXISTS MAPPA_MEDICO_AMBULATORIO CASCADE;
DROP TABLE IF EXISTS AMBULATORIO CASCADE;
DROP TABLE IF EXISTS REPARTO CASCADE;
DROP TABLE IF EXISTS MEDICO CASCADE;
DROP TABLE IF EXISTS DIZIONARIO_DIAGNOSI CASCADE;

-- -----------------------------------------------------------------------------
-- 1. VOCABOLARI, CATALOGHI E GRAFO SINTOMI-DIAGNOSI (DSS EXTENDED)
-- -----------------------------------------------------------------------------

-- Dizionario Diagnosi (ICD-9)
CREATE TABLE DIZIONARIO_DIAGNOSI (
    codice VARCHAR(10) NOT NULL,
    descrizione_it TEXT NOT NULL,
    descrizione_en TEXT NOT NULL,
    sistema VARCHAR(20) DEFAULT 'ICD-9' NOT NULL,
    attivo CHAR(1) DEFAULT 'Y' NOT NULL,
    CONSTRAINT pk_dizionario_diagnosi PRIMARY KEY (codice),
    CONSTRAINT chk_dizionario_attivo CHECK (attivo IN ('Y', 'N'))
);

-- Mappa Localizzazione Anatomica (Parti del Corpo)
CREATE TABLE CORPO_PARTE (
    parte_id SERIAL NOT NULL,
    codice VARCHAR(30) NOT NULL,
    nome_it VARCHAR(100) NOT NULL,
    nome_en VARCHAR(100) NOT NULL,
    CONSTRAINT pk_corpo_parte PRIMARY KEY (parte_id),
    CONSTRAINT uq_corpo_parte_codice UNIQUE (codice)
);

-- Catalogo Sintomi Dinamici
CREATE TABLE SINTOMO (
    sintomo_id SERIAL NOT NULL,
    codice VARCHAR(50) NOT NULL,
    parte_id INT,
    domanda_it TEXT NOT NULL,
    domanda_en TEXT NOT NULL,
    CONSTRAINT pk_sintomo PRIMARY KEY (sintomo_id),
    CONSTRAINT uq_sintomo_codice UNIQUE (codice),
    CONSTRAINT fk_sintomo_corpo_parte FOREIGN KEY (parte_id)
        REFERENCES CORPO_PARTE (parte_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Matrice Dinamica di Rilevanza Sintomo -> Diagnosi (Pesi e Incertezza)
CREATE TABLE MAPPA_SINTOMO_DIAGNOSI (
    sintomo_id INT NOT NULL,
    codice_icd9 VARCHAR(10) NOT NULL,
    peso_rilevanza NUMERIC(5,4) NOT NULL,
    CONSTRAINT pk_mappa_sintomo_diagnosi PRIMARY KEY (sintomo_id, codice_icd9),
    CONSTRAINT fk_msd_sintomo FOREIGN KEY (sintomo_id)
        REFERENCES SINTOMO (sintomo_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_msd_diagnosi FOREIGN KEY (codice_icd9)
        REFERENCES DIZIONARIO_DIAGNOSI (codice) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_msd_peso CHECK (peso_rilevanza >= -1.0000 AND peso_rilevanza <= 1.0000)
);

-- -----------------------------------------------------------------------------
-- 2. STRUTTURA ORGANIZZATIVA E PERSONALE MEDICO
-- -----------------------------------------------------------------------------

CREATE TABLE REPARTO (
    reparto_id SERIAL NOT NULL,
    nome VARCHAR(100) NOT NULL,
    ubicazione VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    capo_medico_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_reparto PRIMARY KEY (reparto_id)
);

CREATE TABLE MEDICO (
    medico_id SERIAL NOT NULL,
    matricola_medico VARCHAR(20) NOT NULL,
    albo_numero INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    specializzazione VARCHAR(100) NOT NULL,
    reparto_id INT NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    attivo CHAR(1) DEFAULT 'Y' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_medico PRIMARY KEY (medico_id),
    CONSTRAINT uq_medico_matricola UNIQUE (matricola_medico),
    CONSTRAINT uq_medico_albo UNIQUE (albo_numero),
    CONSTRAINT fk_medico_reparto FOREIGN KEY (reparto_id)
        REFERENCES REPARTO (reparto_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_medico_attivo CHECK (attivo IN ('Y', 'N'))
);

ALTER TABLE REPARTO
    ADD CONSTRAINT fk_reparto_capo_medico FOREIGN KEY (capo_medico_id)
        REFERENCES MEDICO (medico_id) ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE AMBULATORIO (
    ambulatorio_id SERIAL NOT NULL,
    reparto_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    sede VARCHAR(100) NOT NULL,
    specialita VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_ambulatorio PRIMARY KEY (ambulatorio_id),
    CONSTRAINT fk_ambulatorio_reparto FOREIGN KEY (reparto_id)
        REFERENCES REPARTO (reparto_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE MAPPA_MEDICO_AMBULATORIO (
    medico_id INT NOT NULL,
    ambulatorio_id INT NOT NULL,
    CONSTRAINT pk_mappa_medico_ambulatorio PRIMARY KEY (medico_id, ambulatorio_id),
    CONSTRAINT fk_mma_medico FOREIGN KEY (medico_id)
        REFERENCES MEDICO (medico_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_mma_ambulatorio FOREIGN KEY (ambulatorio_id)
        REFERENCES AMBULATORIO (ambulatorio_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------------------------
-- 3. ANAGRAFICA PAZIENTI E CONSENSI
-- -----------------------------------------------------------------------------

CREATE TABLE PAZIENTE (
    paziente_id SERIAL NOT NULL,
    codice_fiscale CHAR(16) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    data_nascita DATE NOT NULL,
    sesso CHAR(1) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    indirizzo TEXT,
    medico_base VARCHAR(100),
    consenso_trattamento_dati CHAR(1) DEFAULT 'Y' NOT NULL,
    consenso_ia CHAR(1) DEFAULT 'N' NOT NULL,
    note_cliniche_sintetiche TEXT,
    CONSTRAINT pk_paziente PRIMARY KEY (paziente_id),
    CONSTRAINT uq_paziente_cf UNIQUE (codice_fiscale),
    CONSTRAINT chk_paziente_sesso CHECK (sesso IN ('M', 'F', 'X')),
    CONSTRAINT chk_paziente_privacy CHECK (consenso_trattamento_dati IN ('Y', 'N')),
    CONSTRAINT chk_paziente_ia CHECK (consenso_ia IN ('Y', 'N'))
);

CREATE TABLE CONTATTO_EMERGENZA (
    contatto_id SERIAL NOT NULL,
    paziente_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    relazione VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    CONSTRAINT pk_contatto_emergenza PRIMARY KEY (contatto_id),
    CONSTRAINT fk_contatto_paziente FOREIGN KEY (paziente_id)
        REFERENCES PAZIENTE (paziente_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CONSENSO (
    consenso_id SERIAL NOT NULL,
    paziente_id INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    stato VARCHAR(20) NOT NULL,
    valido_dal TIMESTAMP NOT NULL,
    valido_al TIMESTAMP,
    note TEXT,
    CONSTRAINT pk_consenso PRIMARY KEY (consenso_id),
    CONSTRAINT fk_consenso_paziente FOREIGN KEY (paziente_id)
        REFERENCES PAZIENTE (paziente_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_consenso_tipo CHECK (tipo IN ('PRIVACY', 'IA')),
    CONSTRAINT chk_consenso_stato CHECK (stato IN ('CONCESSO', 'REVOCATO'))
);

-- -----------------------------------------------------------------------------
-- 4. PRESTAZIONI, CALENDARI E PRENOTAZIONI
-- -----------------------------------------------------------------------------

CREATE TABLE VISITA_TIPO (
    visita_tipo_id SERIAL NOT NULL,
    codice VARCHAR(30) NOT NULL,
    descrizione TEXT NOT NULL,
    specialita VARCHAR(100) NOT NULL,
    durata_minuti INT NOT NULL,
    icd9_predefinito VARCHAR(10),
    CONSTRAINT pk_visita_tipo PRIMARY KEY (visita_tipo_id),
    CONSTRAINT uq_visita_tipo_codice UNIQUE (codice),
    CONSTRAINT fk_visita_tipo_icd9 FOREIGN KEY (icd9_predefinito)
        REFERENCES DIZIONARIO_DIAGNOSI (codice) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_visita_tipo_durata CHECK (durata_minuti > 0)
);

CREATE TABLE CALENDARIO_SLOT (
    slot_id SERIAL NOT NULL,
    ambulatorio_id INT NOT NULL,
    medico_id INT,
    inizio TIMESTAMP NOT NULL,
    fine TIMESTAMP NOT NULL,
    stato VARCHAR(20) DEFAULT 'LIBERO' NOT NULL,
    fonte VARCHAR(50),
    note TEXT,
    CONSTRAINT pk_calendario_slot PRIMARY KEY (slot_id),
    CONSTRAINT fk_slot_ambulatorio FOREIGN KEY (ambulatorio_id)
        REFERENCES AMBULATORIO (ambulatorio_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_slot_medico FOREIGN KEY (medico_id)
        REFERENCES MEDICO (medico_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_slot_stato CHECK (stato IN ('LIBERO', 'OCCUPATO', 'BLOCCATO')),
    CONSTRAINT chk_slot_date CHECK (fine > inizio)
);

CREATE TABLE PRENOTAZIONE (
    prenotazione_id SERIAL NOT NULL,
    paziente_id INT NOT NULL,
    ambulatorio_id INT NOT NULL,
    visita_tipo_id INT NOT NULL,
    medico_id INT,
    priorita VARCHAR(20) DEFAULT 'ORDINARIA' NOT NULL,
    motivo TEXT,
    inizio TIMESTAMP NOT NULL,
    fine TIMESTAMP NOT NULL,
    stato VARCHAR(20) DEFAULT 'CREATA' NOT NULL,
    note TEXT,
    CONSTRAINT pk_prenotazione PRIMARY KEY (prenotazione_id),
    CONSTRAINT fk_prenotazione_paziente FOREIGN KEY (paziente_id)
        REFERENCES PAZIENTE (paziente_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prenotazione_ambulatorio FOREIGN KEY (ambulatorio_id)
        REFERENCES AMBULATORIO (ambulatorio_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prenotazione_visita_tipo FOREIGN KEY (visita_tipo_id)
        REFERENCES VISITA_TIPO (visita_tipo_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prenotazione_medico FOREIGN KEY (medico_id)
        REFERENCES MEDICO (medico_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_prenotazione_priorita CHECK (priorita IN ('ORDINARIA', 'URGENTE')),
    CONSTRAINT chk_prenotazione_stato CHECK (stato IN ('CREATA', 'CONFERMATA', 'EROGATA', 'ANNULLATA')),
    CONSTRAINT chk_prenotazione_date CHECK (fine > inizio)
);

-- -----------------------------------------------------------------------------
-- 5. EPISODIO CLINICO, DIAGNOSTICA E REFERTAZIONE
-- -----------------------------------------------------------------------------

CREATE TABLE VISITA (
    visita_id SERIAL NOT NULL,
    prenotazione_id INT,
    paziente_id INT NOT NULL,
    medico_id INT NOT NULL,
    ambulatorio_id INT NOT NULL,
    anamnesi TEXT,
    sintomi TEXT,
    esame_obiettivo TEXT,
    vitali_testo TEXT,
    stato VARCHAR(20) DEFAULT 'APERTA' NOT NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    CONSTRAINT pk_visita PRIMARY KEY (visita_id),
    CONSTRAINT uq_visita_prenotazione UNIQUE (prenotazione_id),
    CONSTRAINT fk_visita_prenotazione FOREIGN KEY (prenotazione_id)
        REFERENCES PRENOTAZIONE (prenotazione_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_visita_paziente FOREIGN KEY (paziente_id)
        REFERENCES PAZIENTE (paziente_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_visita_medico FOREIGN KEY (medico_id)
        REFERENCES MEDICO (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_visita_ambulatorio FOREIGN KEY (ambulatorio_id)
        REFERENCES AMBULATORIO (ambulatorio_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_visita_stato CHECK (stato IN ('APERTA', 'CHIUSA'))
);

CREATE TABLE ALLEGATO_VISITA (
    allegato_id SERIAL NOT NULL,
    visita_id INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    uri VARCHAR(255) NOT NULL,
    descrizione TEXT,
    CONSTRAINT pk_allegato_visita PRIMARY KEY (allegato_id),
    CONSTRAINT fk_allegato_visita FOREIGN KEY (visita_id)
        REFERENCES VISITA (visita_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ESAME (
    esame_id SERIAL NOT NULL,
    visita_id INT NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    codice_loinc VARCHAR(20),
    stato VARCHAR(20) DEFAULT 'PRESCRITTO' NOT NULL,
    programmato_per TIMESTAMP,
    eseguito_il TIMESTAMP,
    note TEXT,
    CONSTRAINT pk_esame PRIMARY KEY (esame_id),
    CONSTRAINT fk_esame_visita FOREIGN KEY (visita_id)
        REFERENCES VISITA (visita_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_esame_stato CHECK (stato IN ('PRESCRITTO', 'PROGRAMMATO', 'ESEGUITO', 'ANNULLATO'))
);

CREATE TABLE REFERTO (
    referto_id SERIAL NOT NULL,
    esame_id INT NOT NULL,
    dati_strutturati TEXT NOT NULL,
    allegato_uri VARCHAR(255),
    autore_id INT NOT NULL,
    versione INT DEFAULT 1 NOT NULL,
    CONSTRAINT pk_referto PRIMARY KEY (referto_id),
    CONSTRAINT uq_referto_esame UNIQUE (esame_id),
    CONSTRAINT fk_referto_esame FOREIGN KEY (esame_id)
        REFERENCES ESAME (esame_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_referto_autore FOREIGN KEY (autore_id)
        REFERENCES MEDICO (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE DIAGNOSI (
    diagnosi_id SERIAL NOT NULL,
    visita_id INT NOT NULL,
    codice_icd9 VARCHAR(10) NOT NULL,
    descrizione TEXT NOT NULL,
    stato VARCHAR(20) DEFAULT 'PROVVISORIA' NOT NULL,
    autore_medico_id INT NOT NULL,
    validata_il TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    versione INT DEFAULT 1 NOT NULL,
    CONSTRAINT pk_diagnosi PRIMARY KEY (diagnosi_id),
    CONSTRAINT fk_diagnosi_visita FOREIGN KEY (visita_id)
        REFERENCES VISITA (visita_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_diagnosi_icd9 FOREIGN KEY (codice_icd9)
        REFERENCES DIZIONARIO_DIAGNOSI (codice) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_diagnosi_autore FOREIGN KEY (autore_medico_id)
        REFERENCES MEDICO (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_diagnosi_stato CHECK (stato IN ('PROVVISORIA', 'FINALE'))
);

-- -----------------------------------------------------------------------------
-- 6. INTEGRAZIONE MOTORE AI / DECISION SUPPORT SYSTEM (DSS)
-- -----------------------------------------------------------------------------

CREATE TABLE AI_SUGGERIMENTO (
    suggerimento_id SERIAL NOT NULL,
    visita_id INT NOT NULL,
    modello_versione VARCHAR(50) NOT NULL,
    candidato_codice VARCHAR(10) NOT NULL,
    candidato_descr TEXT NOT NULL,
    confidenza NUMERIC(5,4) NOT NULL,
    spiegazione TEXT NOT NULL,
    CONSTRAINT pk_ai_suggerimento PRIMARY KEY (suggerimento_id),
    CONSTRAINT fk_ai_suggerimento_visita FOREIGN KEY (visita_id)
        REFERENCES VISITA (visita_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ai_suggerimento_icd9 FOREIGN KEY (candidato_codice)
        REFERENCES DIZIONARIO_DIAGNOSI (codice) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_ai_confidenza CHECK (confidenza >= 0.0000 AND confidenza <= 1.0000)
);

CREATE TABLE AI_AZIONE_MEDICO (
    azione_id SERIAL NOT NULL,
    suggerimento_id INT NOT NULL,
    medico_id INT NOT NULL,
    azione VARCHAR(20) NOT NULL,
    nota TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_ai_azione_medico PRIMARY KEY (azione_id),
    CONSTRAINT fk_ai_azione_suggerimento FOREIGN KEY (suggerimento_id)
        REFERENCES AI_SUGGERIMENTO (suggerimento_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ai_azione_medico FOREIGN KEY (medico_id)
        REFERENCES MEDICO (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_ai_azione CHECK (azione IN ('ACCETTA', 'RIGETTA', 'MODIFICA'))
);

-- -----------------------------------------------------------------------------
-- 7. GOVERNANCE E AUDIT LOG
-- -----------------------------------------------------------------------------

CREATE TABLE UTENTE_SISTEMA (
    utente_id SERIAL NOT NULL,
    username VARCHAR(50) NOT NULL,
    ruolo VARCHAR(20) NOT NULL,
    medico_id INT,
    attivo CHAR(1) DEFAULT 'Y' NOT NULL,
    CONSTRAINT pk_utente_sistema PRIMARY KEY (utente_id),
    CONSTRAINT uq_utente_username UNIQUE (username),
    CONSTRAINT fk_utente_medico FOREIGN KEY (medico_id)
        REFERENCES MEDICO (medico_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_utente_ruolo CHECK (ruolo IN ('AMMIN', 'TECNICO', 'MEDICO', 'AUDITOR')),
    CONSTRAINT chk_utente_attivo CHECK (attivo IN ('Y', 'N'))
);

CREATE TABLE LOG (
    log_id SERIAL NOT NULL,
    entita VARCHAR(50) NOT NULL,
    entita_id INT NOT NULL,
    azione VARCHAR(10) NOT NULL,
    utente_id INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    diff_testo TEXT,
    ip VARCHAR(45),
    CONSTRAINT pk_log PRIMARY KEY (log_id),
    CONSTRAINT fk_log_utente FOREIGN KEY (utente_id)
        REFERENCES UTENTE_SISTEMA (utente_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_log_azione CHECK (azione IN ('CREATE', 'READ', 'UPDATE', 'DELETE'))
);