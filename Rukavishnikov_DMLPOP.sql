-- =============================================================================
-- UNIVERSITÀ DEL PIEMONTE ORIENTALE (UPO)
-- Corso di Basi di Dati e Sistemi Informativi - A.A. 2025-2026
-- Script DML: Popolamento Iniziale Dati (DMLPOP v2.0 Extended)
-- Autore: Vladimir Rukavishnikov (Matr. 20063686)
-- File: Rukavishnikov_DMLPOP.sql
-- =============================================================================

-- =============================================================================
-- 1. DIZIONARIO DIAGNOSI (EXPANDED ICD-9)
-- =============================================================================
INSERT INTO DIZIONARIO_DIAGNOSI (codice, descrizione_it, descrizione_en, sistema, attivo) VALUES
-- Diagnosi base
('401.9',  'Ipertensione arteriosa essenziale', 'Essential Hypertension', 'ICD-9', 'Y'),
('250.00', 'Diabete mellito tipo 2', 'Type 2 Diabetes Mellitus', 'ICD-9', 'Y'),
('486',    'Polmonite batterica', 'Bacterial Pneumonia', 'ICD-9', 'Y'),
('780.60', 'Febbre non specificata', 'Fever of unknown origin', 'ICD-9', 'Y'),
('786.50', 'Dolore toracico non specificato', 'Chest pain unspecified', 'ICD-9', 'Y'),
('784.0',  'Cefalea e dolore facciale', 'Headache and Facial Pain', 'ICD-9', 'Y'),
('530.81', 'Reflusso gastroesofageo (MRGE)', 'Gastroesophageal Reflux (GERD)', 'ICD-9', 'Y'),
('410.9',  'Infarto acuto del miocardio non specificato', 'Acute Myocardial Infarction', 'ICD-9', 'Y'),
('493.90', 'Asma bronchiale non specificata', 'Bronchial Asthma unspecified', 'ICD-9', 'Y'),
('540.9',  'Appendicite acuta senza peritonite', 'Acute Appendicitis without peritonitis', 'ICD-9', 'Y'),
('780.4',  'Vertigine e stordimento', 'Dizziness and giddiness', 'ICD-9', 'Y'),
('300.00', 'Stato d ansia non specificato', 'Anxiety state unspecified', 'ICD-9', 'Y'),
('346.90', 'Emicrania non specificata', 'Migraine unspecified', 'ICD-9', 'Y'),
('413.9',  'Angina pectoris non specificata', 'Angina pectoris unspecified', 'ICD-9', 'Y'),
('441.01', 'Dissezione dell aorta toracica', 'Dissection of thoracic aorta', 'ICD-9', 'Y'),
('415.19', 'Embolia polmonare acuta', 'Acute Pulmonary Embolism', 'ICD-9', 'Y'),
('491.21', 'BPCO con riacutizzazione acuta', 'COPD with acute exacerbation', 'ICD-9', 'Y'),
('577.0',  'Pancreatite acuta', 'Acute pancreatitis', 'ICD-9', 'Y'),
('574.20', 'Calcolosi della colecisti', 'Calculus of gallbladder', 'ICD-9', 'Y'),
('558.9',  'Gastroenterite ed enterite non infettiva', 'Gastroenteritis and colitis', 'ICD-9', 'Y'),
('592.0',  'Calcolosi renale e colica ureterale', 'Calculus of kidney and renal colic', 'ICD-9', 'Y'),
('599.0',  'Infezione delle vie urinarie (IVU)', 'Urinary tract infection unspecified', 'ICD-9', 'Y'),
('780.2',  'Sincope e collasso', 'Syncope and collapse', 'ICD-9', 'Y'),
('434.91', 'Ictus cerebrale ischemico acuto', 'Acute ischemic cerebrovascular accident', 'ICD-9', 'Y'),
('307.81', 'Cefalea muscolo-tensiva', 'Tension headache', 'ICD-9', 'Y'),
('786.52', 'Dolore toracico pleuritico', 'Pleuritic chest pain', 'ICD-9', 'Y'),
('782.1',  'Rash ed eruzione cutanea', 'Rash and other nonspecific skin eruption', 'ICD-9', 'Y'),
('443.9',  'Vasculopatia periferica / Claudicatio', 'Peripheral vascular disease unspecified', 'ICD-9', 'Y'),
('531.90', 'Ulcera gastrica non specificata', 'Gastric ulcer unspecified', 'ICD-9', 'Y'),
('787.01', 'Nausea e vomito isolati', 'Nausea with vomiting', 'ICD-9', 'Y'),
('427.31', 'Fibrillazione atriale', 'Atrial fibrillation', 'ICD-9', 'Y'),
('428.0',  'Insufficienza cardiaca / Scompenso cardiaco', 'Congestive heart failure', 'ICD-9', 'Y'),
('571.5',  'Cirrosi epatica non specificata', 'Cirrhosis of liver without alcohol', 'ICD-9', 'Y'),
('585.9',  'Insufficienza renale cronica', 'Chronic kidney disease unspecified', 'ICD-9', 'Y'),
('433.10', 'Occlusione / Stenosi carotidea (TIA)', 'Carotid artery occlusion / TIA', 'ICD-9', 'Y'),
('532.90', 'Ulcera duodenale non specificata', 'Duodenal ulcer unspecified', 'ICD-9', 'Y'),
('575.10', 'Colecistite acuta', 'Acute cholecystitis', 'ICD-9', 'Y'),
('714.0',  'Artrite reumatoide', 'Rheumatoid arthritis', 'ICD-9', 'Y'),
('724.2',  'Lombaggine / Lombalgia acuta', 'Lumbago / Low back pain', 'ICD-9', 'Y'),
('244.9',  'Ipotiroidismo non specificato', 'Hypothyroidism unspecified', 'ICD-9', 'Y'),
('242.90', 'Ipertiroidismo / Tireotossicosi', 'Hyperthyroidism unspecified', 'ICD-9', 'Y'),
('285.9',  'Anemia non specificata', 'Anemia unspecified', 'ICD-9', 'Y'),
('487.0',  'Influenza con manifestazioni respiratorie', 'Influenza with respiratory manifestations', 'ICD-9', 'Y'),
('038.9',  'Setticemia non specificata / Sepsi', 'Unspecified septicemia', 'ICD-9', 'Y'),
('300.29', 'Disturbo da attacchi di panico', 'Panic disorder without agoraphobia', 'ICD-9', 'Y'),
('780.52', 'Insonnia non organica', 'Insomnia unspecified', 'ICD-9', 'Y'),
('783.21', 'Perdita di peso involontaria', 'Involuntary weight loss', 'ICD-9', 'Y'),
('780.79', 'Astenia e malessere generale', 'Other malaise and fatigue', 'ICD-9', 'Y'),
('789.00', 'Dolore addominale non specificato', 'Abdominal pain unspecified', 'ICD-9', 'Y'),
('578.9',  'Emorragia gastrointestinale non specificata', 'Gastrointestinal hemorrhage unspecified', 'ICD-9', 'Y');

-- =============================================================================
-- 2. PARTE DEL CORPO, SINTOMI E MATRICE RELAZIONALE (EXPANDED DSS GRAPH)
-- =============================================================================
INSERT INTO CORPO_PARTE (parte_id, codice, nome_it, nome_en) VALUES
(1, 'CHEST',    'Torace e Petto', 'Chest and Thorax'),
(2, 'HEAD',     'Testa e Capo', 'Head and Cranium'),
(3, 'SYSTEMIC', 'Generale / Sistemico', 'Systemic / Whole Body'),
(4, 'GI',       'Apparato Digerente', 'Gastrointestinal System'),
(5, 'ABDOMEN',  'Addome e Pelvi', 'Abdomen and Pelvis'),
(6, 'LIMBS',    'Arti Superiori e Inferiori', 'Upper and Lower Limbs');

INSERT INTO SINTOMO (sintomo_id, codice, parte_id, domanda_it, domanda_en) VALUES
-- Sintomi base (1-12)
(1,  'SYM_CHEST_PRESS', 1, 'Avverti un senso di oppressione o forte pressione al petto?', 'Do you experience severe chest tightness or acute pressure?'),
(2,  'SYM_FEVER',       3, 'Hai febbre alta (>38.5 C) o brividi di freddo?', 'Do you have a high body temperature (>38.5 C) or chills?'),
(3,  'SYM_COUGH',       1, 'Presenti tosse persistente o difficolta respiratorie?', 'Do you suffer from a persistent cough or breathlessness?'),
(4,  'SYM_HEADACHE',    2, 'Soffri di dolore pulsante o localizzato al capo/viso?', 'Do you feel throbbing localized facial or head pain?'),
(5,  'SYM_REFLUX',      4, 'Avverti bruciore retrosternale o acido in gola?', 'Do you notice acid reflux or a burning sensation in chest?'),
(6,  'SYM_DIZZY',       2, 'Soffri di frequenti capogiri o visione offuscata?', 'Do you experience frequent dizziness or blurred vision?'),
(7,  'SYM_WHEEZING',    1, 'Senti fischi o sibili durante l espirazione?', 'Do you hear wheezing sounds while breathing out?'),
(8,  'SYM_POST_MEAL',   4, 'Il dolore aumenta subito dopo i pasti?', 'Does the pain worsen immediately after eating meals?'),
(9,  'SYM_ARM_PAIN',    6, 'Il dolore si irradia al braccio sinistro o alla mandibola?', 'Does the pain radiate to the left arm or jaw?'),
(10, 'SYM_ABD_RIGHT',   5, 'Avverti un dolore acuto nella parte inferiore destra dell addome?', 'Do you feel sharp pain in the lower right abdomen?'),
(11, 'SYM_SWEATING',    3, 'Presenti sudorazione fredda improvvisa o nausea?', 'Do you suffer from sudden cold sweats or nausea?'),
(12, 'SYM_PALPITATION', 1, 'Avverti battito cardiaco accelerato o irregolare?', 'Do you feel a rapid or irregular heartbeat?'),
(13, 'SYM_AURAPHOTO',   2, 'Noti fastidio marcato alla luce (fotofobia) o disturbi visivi/aura prima della cefalea?', 'Do you experience photophobia or visual aura prior to headache?'),
(14, 'SYM_TEARING_BACK',1, 'Avverti un dolore lacerante o trafiggente che dal petto migra alla schiena?', 'Do you feel a tearing or stabbing chest pain radiating to the back?'),
(15, 'SYM_DYSPNEA_EXERT',1,'La mancanza di fiato (affanno) compare anche per sforzi minimi o a riposo?', 'Does breathlessness occur even with minimal exertion or at rest?'),
(16, 'SYM_HEMOPTYSIS',  1, 'Presenti tracce di sangue nello sputo o catarro ematico?', 'Do you notice coughing up blood or blood-tinged sputum?'),
(17, 'SYM_PLEURITIC',   1, 'Il dolore al petto peggiora acutamente durante l inspirazione profonda o la tosse?', 'Does chest pain sharply worsen during deep inspiration or coughing?'),
(18, 'SYM_EPIGAST_PAIN',4, 'Avverti un dolore intenso a fascia nella parte alta dell addome irradiato alla schiena?', 'Do you feel severe upper abdominal pain radiating like a belt to the back?'),
(19, 'SYM_RUQ_PAIN',    5, 'Soffri di dolore acuto al quadrante superiore destro dell addome che aumenta con cibi grassi?', 'Do you feel right upper quadrant pain worsening after fatty meals?'),
(20, 'SYM_DYSPHAGIA',   4, 'Hai difficolta o dolore durante la deglutizione dei cibi solidi o liquidi?', 'Do you experience difficulty or pain when swallowing food or liquids?'),
(21, 'SYM_DYSURIA',     5, 'Avverti bruciore, dolore o difficolta durante la minzione?', 'Do you experience burning sensation or pain during urination?'),
(22, 'SYM_FLANK_PAIN',  5, 'Presenti un dolore acuto a colica al fianco che si irradia verso l inguine?', 'Do you feel sharp colicky flank pain radiating down to the groin?'),
(23, 'SYM_FOCAL_NEURO', 2, 'Avverti debolezza improvvisa ad un lato del corpo, asimmetria facciale o difficolta nel parlare?', 'Do you have sudden unilateral muscle weakness, facial drooping, or speech difficulty?'),
(24, 'SYM_SYNCOPE',     3, 'Hai avuto un improvvisa perdita di coscienza o sensazione imminente di svenimento?', 'Have you suffered a sudden loss of consciousness or near-fainting episode?'),
(25, 'SYM_CLAUDICATION',6, 'Accusi crampi e dolore ai polpacci durante la camminata che svaniscono fermandoti?', 'Do you feel calf pain or cramping while walking that subsides with rest?'),
(26, 'SYM_NIGHT_COUGH', 1, 'La tosse aumenta notevolmente quando ti stendi a letto durante la notte?', 'Does coughing worsen significantly when lying down at night?'),
(27, 'SYM_NECK_STIFF',  2, 'Accusi rigidita nucale e difficolta a piegare il mento verso il petto?', 'Do you feel neck stiffness or difficulty bending your chin to chest?'),
(28, 'SYM_SKIN_RASH',   3, 'Sono comparse macchie rosse, eruzioni cutanee improvvise o prurito diffuso?', 'Have you noticed sudden skin rash, red spots, or widespread itching?'),
(29, 'SYM_DIARRHEA',    4, 'Presenti scariche diarreiche frequenti o crampi addominali acuti?', 'Do you suffer from frequent watery diarrhea or acute abdominal cramps?'),
(30, 'SYM_ANKLE_EDEMA', 6, 'Noti gonfiore ed edema evidente alle caviglie o ai piedi a fine giornata?', 'Do you notice marked swelling or edema in your ankles or feet?'),
(31, 'SYM_FATIGUE',      3, 'Accusi stanchezza cronica, debolezza o astenia marcata?', 'Do you suffer from chronic fatigue or marked weakness?'),
(32, 'SYM_WEIGHT_LOSS',  3, 'Hai riscontrato un calo ponderale involontario recente?', 'Have you noticed recent involuntary weight loss?'),
(33, 'SYM_PALPIT_IRREG', 1, 'Avverti battito cardiaco irregolare, sfarfallio o fibrillazione?', 'Do you feel an irregular heartbeat or fluttering chest?'),
(34, 'SYM_ORTHOPNEA',    1, 'Hai difficolta a respirare quando ti sdrai in piano (ortopnea)?', 'Do you experience shortness of breath when lying flat?'),
(35, 'SYM_JAUNDICE',     3, 'Noti colorazione giallastra della cute o degli occhi (ittero)?', 'Do you notice yellowish discoloration of skin or eyes?'),
(36, 'SYM_BACK_PAIN_LOW',5, 'Soffri di dolore alla parte bassa della schiena (zona lombare)?', 'Do you suffer from lower back pain?'),
(37, 'SYM_TREMOR',       2, 'Presenti tremori alle mani, agitazione motoria o ansia acuta?', 'Do you have hand tremors or motor restlessness?'),
(38, 'SYM_COLD_INTOL',   3, 'Soffri di un intolleranza marcata al freddo e pelle molto secca?', 'Do you experience marked cold intolerance and dry skin?'),
(39, 'SYM_HEAT_INTOL',   3, 'Soffri di intolleranza al calore con sudorazione profusa?', 'Do you suffer from heat intolerance with profuse sweating?'),
(40, 'SYM_PALLOR',       3, 'Avverti pallore marcato, affaticamento precoce e vertigini?', 'Do you notice marked pallor, easy fatigue, and dizziness?'),
(41, 'SYM_POLYURIA',     5, 'Hai un aumento notevole della frequenza e del volume delle minzioni?', 'Do you experience a marked increase in urination frequency and volume?'),
(42, 'SYM_INSOMNIA',     2, 'Soffri di difficolta ad addormentarti o risvegli precoci frequenti?', 'Do you have trouble falling asleep or frequent early awakenings?'),
(43, 'SYM_JOINT_PAIN',   6, 'Presenti dolore, gonfiore o rigidita mattutina alle articolazioni?', 'Do you experience joint pain, swelling, or morning stiffness?'),
(44, 'SYM_PANIC_ATTACK', 3, 'Presenti attacchi improvvisi di paura, sensazione di soffocamento e tremori?', 'Do you have sudden panic attacks, choking sensations, or tremors?'),
(45, 'SYM_NAUSEA_VOMIT', 4, 'Avverti nausea persistente accompagnata da episodi di vomito?', 'Do you suffer from persistent nausea accompanied by vomiting?'),
(46, 'SYM_BLOOD_STOOL',  4, 'Noti presenza di sangue nelle feci o feci scure/catramose?', 'Have you noticed blood in your stool or dark tarry stools?'),
(47, 'SYM_MEMORY_LOSS',  2, 'Avverti vuoti di memoria improvvisi o difficolta di concentrazione?', 'Do you experience sudden memory gaps or concentration issues?'),
(48, 'SYM_SWALLOW_PAIN', 4, 'Accusi dolore intenso durante la deglutizione (odinofagia)?', 'Do you feel severe pain when swallowing?'),
(49, 'SYM_CONSTIPATION', 4, 'Soffri di stipsi ostinata o evacuazioni difficoltose da giorni?', 'Do you suffer from severe constipation or painful bowel movements?'),
(50, 'SYM_BLOATING',     5, 'Noti gonfiore addominale o tensione addominale marcata post-prandiale?', 'Do you notice abdominal bloating or marked post-meal distension?');

-- Matrice Relazionale Ponderata Sintomo -> Diagnosi (Grafo DSS Espanso)
INSERT INTO MAPPA_SINTOMO_DIAGNOSI (sintomo_id, codice_icd9, peso_rilevanza) VALUES
-- SYM_CHEST_PRESS (Pressione al petto)
(1, '401.9',   0.3500),
(1, '786.50',  0.8000),
(1, '410.9',   0.9500),
(1, '413.9',   0.9000),
(1, '530.81',  0.3000),
(1, '300.00',  0.4000),

-- SYM_FEVER (Febbre)
(2, '486',     0.8500),
(2, '780.60',  0.9000),
(2, '540.9',   0.7500),
(2, '577.0',   0.6000),
(2, '599.0',   0.7000),
(2, '558.9',   0.5000),

-- SYM_COUGH (Tosse / Dispnea)
(3, '486',     0.8200),
(3, '493.90',  0.8800),
(3, '491.21',  0.8500),
(3, '415.19',  0.6000),

-- SYM_HEADACHE (Cefalea)
(4, '784.0',   0.9000),
(4, '346.90',  0.9500),
(4, '307.81',  0.8500),
(4, '401.9',   0.4500),
(4, '300.00',  0.3000),

-- SYM_REFLUX (Reflusso)
(5, '530.81',  0.9200),
(5, '531.90',  0.6500),
(5, '786.50',  0.2500),

-- SYM_DIZZY (Vertigini)
(6, '780.4',   0.9000),
(6, '401.9',   0.5000),
(6, '780.2',   0.7000),
(6, '300.00',  0.3500),

-- SYM_WHEEZING (Sibili respiratorie)
(7, '493.90',  0.9500),
(7, '491.21',  0.8000),
(7, '486',     0.4000),

-- SYM_POST_MEAL (Dolore post-prandiale)
(8, '530.81',  0.8500),
(8, '574.20',  0.9000),
(8, '531.90',  0.8000),

-- SYM_ARM_PAIN (Irradiazione braccio/mandibola)
(9, '410.9',   0.9800),
(9, '413.9',   0.8800),
(9, '786.50',  0.3500),

-- SYM_ABD_RIGHT (Dolore fossa iliaca destra)
(10, '540.9',  0.9600),

-- SYM_SWEATING (Sudorazione / Nausea)
(11, '410.9',  0.8500),
(11, '540.9',  0.5000),
(11, '577.0',  0.7000),
(11, '300.00', 0.6000),

-- SYM_PALPITATION (Palpitazioni)
(12, '300.00', 0.7500),
(12, '401.9',  0.4000),
(12, '410.9',  0.6000),

-- SYM_AURAPHOTO (Fotofobia / Aura visiva)
(13, '346.90', 0.9800),
(13, '784.0',  0.4000),

-- SYM_TEARING_BACK (Dolore lacerante petto->schiena)
(14, '441.01', 0.9900),
(14, '410.9',  0.3000),

-- SYM_DYSPNEA_EXERT (Dispnea da sforzo/riposo)
(15, '415.19', 0.9000),
(15, '491.21', 0.8500),
(15, '493.90', 0.7500),
(15, '410.9',  0.7000),

-- SYM_HEMOPTYSIS (Emoftoe / Sangue nello sputo)
(16, '415.19', 0.8500),
(16, '486',     0.6500),
(16, '491.21',  0.5000),

-- SYM_PLEURITIC (Dolore pleuritico all inspirazione)
(17, '786.52', 0.9500),
(17, '415.19', 0.8000),
(17, '486',     0.7500),

-- SYM_EPIGAST_PAIN (Dolore epigastrico a fascia)
(18, '577.0',  0.9600),
(18, '531.90', 0.7000),
(18, '530.81', 0.4000),

-- SYM_RUQ_PAIN (Dolore ipocondrio destro post-grassi)
(19, '574.20', 0.9700),
(19, '577.0',  0.4000),

-- SYM_DYSPHAGIA (Disfagia / Difficolta deglutizione)
(20, '530.81', 0.8000),
(20, '531.90', 0.5000),

-- SYM_DYSURIA (Disuria / Bruciore minzionale)
(21, '599.0',  0.9800),
(21, '592.0',  0.4500),

-- SYM_FLANK_PAIN (Colica al fianco / Inguine)
(22, '592.0',  0.9900),
(22, '599.0',  0.5000),

-- SYM_FOCAL_NEURO (Deficit neurologico focale / Ictus)
(23, '434.91', 0.9900),

-- SYM_SYNCOPE (Sincope / Svenimento)
(24, '780.2',  0.9500),
(24, '410.9',  0.6000),
(24, '415.19', 0.6500),
(24, '300.00', 0.4000),

-- SYM_CLAUDICATION (Claudicatio intermittens)
(25, '443.9',  0.9800),

-- SYM_NIGHT_COUGH (Tosse notturna da clinostatismo)
(26, '530.81', 0.7500),
(26, '493.90', 0.8000),

-- SYM_NECK_STIFF (Rigidita nucale)
(27, '784.0',  0.5000),
(27, '307.81', 0.6500),

-- SYM_SKIN_RASH (Rash cutaneo)
(28, '782.1',  0.9500),

-- SYM_DIARRHEA (Diarrea e crampi)
(29, '558.9',  0.9500),

-- SYM_ANKLE_EDEMA (Edema caviglie)
(30, '401.9',  0.5000),
(30, '250.00', 0.4000),

-- SYM_FATIGUE (Astenia / Affaticamento)
(31, '780.79', 0.9500),
(31, '285.9',  0.8800),
(31, '244.9',  0.8200),
(31, '428.0',  0.7500),
(31, '250.00', 0.7000),
(31, '585.9',  0.6500),

-- SYM_WEIGHT_LOSS (Perdita di peso)
(32, '783.21', 0.9800),
(32, '242.90', 0.8500),
(32, '250.00', 0.7500),
(32, '571.5',  0.6000),

-- SYM_PALPIT_IRREG (Aritmia / Fibrillazione)
(33, '427.31', 0.9900),
(33, '242.90', 0.7500),
(33, '300.29', 0.6000),

-- SYM_ORTHOPNEA (Ortopnea)
(34, '428.0',  0.9600),
(34, '491.21', 0.7000),
(34, '415.19', 0.6500),

-- SYM_JAUNDICE (Ittero)
(35, '571.5',  0.9500),
(35, '575.10', 0.8500),
(35, '574.20', 0.8000),

-- SYM_BACK_PAIN_LOW (Lombalgia)
(36, '724.2',  0.9800),
(36, '592.0',  0.7000),
(36, '599.0',  0.4500),

-- SYM_TREMOR (Tremore)
(37, '242.90', 0.8800),
(37, '300.29', 0.8000),
(37, '300.00', 0.6500),

-- SYM_COLD_INTOL (Intolleranza al freddo)
(38, '244.9',  0.9600),
(38, '285.9',  0.5000),

-- SYM_HEAT_INTOL (Intolleranza al calore)
(39, '242.90', 0.9700),

-- SYM_PALLOR (Pallore)
(40, '285.9',  0.9600),
(40, '578.9',  0.8500),
(40, '410.9',  0.6000),

-- SYM_POLYURIA (Poliuria)
(41, '250.00', 0.9500),
(41, '585.9',  0.7000),
(41, '599.0',  0.6000),

-- SYM_INSOMNIA (Insonnia)
(42, '780.52', 0.9800),
(42, '300.00', 0.7500),
(42, '300.29', 0.7000),

-- SYM_JOINT_PAIN (Dolori articolari)
(43, '714.0',  0.9700),

-- SYM_PANIC_ATTACK (Attacchi di panico)
(44, '300.29', 0.9900),
(44, '300.00', 0.8000),
(44, '242.90', 0.5000),

-- SYM_NAUSEA_VOMIT (Nausea e vomito)
(45, '787.01', 0.9500),
(45, '558.9',  0.8800),
(45, '577.0',  0.8500),
(45, '575.10', 0.8000),
(45, '531.90', 0.6500),

-- SYM_BLOOD_STOOL (Sangue nelle feci / Melena)
(46, '578.9',  0.9800),
(46, '531.90', 0.8500),
(46, '532.90', 0.8500),

-- SYM_MEMORY_LOSS (Problemi di memoria)
(47, '433.10', 0.7500),
(47, '434.91', 0.7000),

-- SYM_SWALLOW_PAIN (Dolore durante la deglutizione)
(48, '530.81', 0.8500),
(48, '531.90', 0.5000),

-- SYM_CONSTIPATION (Costipazione)
(49, '244.9',  0.7000),
(49, '558.9',  0.4000),

-- SYM_BLOATING (Gonfiore addominale)
(50, '530.81', 0.7500),
(50, '532.90', 0.7000),
(50, '574.20', 0.6000);

-- -----------------------------------------------------------------------------
-- 3. REPARTI, MEDICI E AMBULATORI
-- -----------------------------------------------------------------------------
INSERT INTO REPARTO (reparto_id, nome, ubicazione, telefono) VALUES
(1, 'Cardiologia', 'Blocco A - Piano 2', '+39 0321 111111'),
(2, 'Medicina Interna', 'Blocco B - Piano 1', '+39 0321 222222'),
(3, 'Neurologia', 'Blocco C - Piano 3', '+39 0321 333333'),
(4, 'Pneumologia', 'Blocco A - Piano 1', '+39 0321 444444');

INSERT INTO MEDICO (medico_id, matricola_medico, albo_numero, nome, cognome, specializzazione, reparto_id, email, telefono, attivo) VALUES
(1, 'MED-1001', 54321, 'Mario', 'Rossi', 'Cardiologia', 1, 'mario.rossi@ospedale.it', '+39 333 1000001', 'Y'),
(2, 'MED-1002', 54322, 'Laura', 'Bianchi', 'Medicina Interna', 2, 'laura.bianchi@ospedale.it', '+39 333 1000002', 'Y'),
(3, 'MED-1003', 54323, 'Giovanni', 'Verdi', 'Neurologia', 3, 'giovanni.verdi@ospedale.it', '+39 333 1000003', 'Y'),
(4, 'MED-1004', 54324, 'Elena', 'Neri', 'Pneumologia', 4, 'elena.neri@ospedale.it', '+39 333 1000004', 'Y');

UPDATE REPARTO SET capo_medico_id = 1 WHERE reparto_id = 1;
UPDATE REPARTO SET capo_medico_id = 2 WHERE reparto_id = 2;
UPDATE REPARTO SET capo_medico_id = 3 WHERE reparto_id = 3;
UPDATE REPARTO SET capo_medico_id = 4 WHERE reparto_id = 4;

INSERT INTO AMBULATORIO (ambulatorio_id, reparto_id, nome, sede, specialita) VALUES
(1, 1, 'Ambulatorio Cardiologia Generale', 'Stanza A201', 'Cardiologia'),
(2, 2, 'Ambulatorio Medicina Generale', 'Stanza B105', 'Medicina Interna'),
(3, 3, 'Ambulatorio Cefalee e Neurologia', 'Stanza C302', 'Neurologia'),
(4, 4, 'Ambulatorio Fisiopatologia Respiratoria', 'Stanza A104', 'Pneumologia');

INSERT INTO MAPPA_MEDICO_AMBULATORIO (medico_id, ambulatorio_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4);

-- -----------------------------------------------------------------------------
-- 4. PAZIENTI, CONTATTI DI EMERGENZA E CONSENSI
-- -----------------------------------------------------------------------------
INSERT INTO PAZIENTE (paziente_id, codice_fiscale, nome, cognome, data_nascita, sesso, email, telefono, indirizzo, medico_base, consenso_trattamento_dati, consenso_ia, note_cliniche_sintetiche) VALUES
(1, 'RSSMRA80A01L219Z', 'Marco', 'Russo', '1980-01-01', 'M', 'marco.russo@email.it', '+39 340 1234567', 'Via Roma 10, Novara', 'Dr. Alberto Ferrari', 'Y', 'Y', 'Iperteso in trattamento'),
(2, 'GSSGNN75M15F205Y', 'Giovanna', 'Galli', '1975-08-15', 'F', 'giovanna.galli@email.it', '+39 340 2345678', 'Corso Torino 45, Vercelli', 'Dr.ssa Marta Conti', 'Y', 'Y', 'Diabete tipo 2 compenso sufficiente'),
(3, 'BRNLCU92R20H501X', 'Luca', 'Baroni', '1992-10-20', 'M', 'luca.baroni@email.it', '+39 340 3456789', 'Via Milano 8, Alessandria', 'Dr. Alberto Ferrari', 'Y', 'N', 'Nessuna patologia cronica segnalata'),
(4, 'MNTFNC88T50F205W', 'Francesca', 'Fontana', '1988-12-10', 'F', 'francesca.fontana@email.it', '+39 340 4567890', 'Via Dante 12, Novara', 'Dr. Paolo Colombo', 'Y', 'Y', 'Soggetta a cefalea a grappolo'),
(5, 'PRTMTT65H12L219V', 'Matteo', 'Proietti', '1965-06-12', 'M', 'matteo.proietti@email.it', '+39 340 5678901', 'Via Verdi 3, Casale M.', 'Dr.ssa Marta Conti', 'Y', 'N', 'Fumatore, sospetta BPCO');

INSERT INTO CONTATTO_EMERGENZA (contatto_id, paziente_id, nome, relazione, telefono) VALUES
(1, 1, 'Anna Russo', 'Moglie', '+39 349 1111111'),
(2, 2, 'Stefano Galli', 'Fratello', '+39 349 2222222'),
(3, 3, 'Giulia Baroni', 'Sorella', '+39 349 3333333'),
(4, 4, 'Roberto Fontana', 'Padre', '+39 349 4444444'),
(5, 5, 'Carla Proietti', 'Moglie', '+39 349 5555555');

INSERT INTO CONSENSO (consenso_id, paziente_id, tipo, stato, valido_dal, valido_al, note) VALUES
(1, 1, 'PRIVACY', 'CONCESSO', '2025-01-10 09:00:00', NULL, 'Consenso privacy completo'),
(2, 1, 'IA', 'CONCESSO', '2025-01-10 09:00:00', NULL, 'Autorizzato uso algoritmi DSS'),
(3, 2, 'PRIVACY', 'CONCESSO', '2025-01-12 10:30:00', NULL, 'Consenso privacy completo'),
(4, 2, 'IA', 'CONCESSO', '2025-01-12 10:30:00', NULL, 'Autorizzato uso algoritmi DSS'),
(5, 3, 'PRIVACY', 'CONCESSO', '2025-02-01 11:00:00', NULL, 'Consenso privacy completo'),
(6, 3, 'IA', 'REVOCATO', '2025-02-01 11:00:00', NULL, 'Rifiutato supporto decisione IA'),
(7, 4, 'PRIVACY', 'CONCESSO', '2025-02-15 14:00:00', NULL, 'Consenso privacy completo'),
(8, 4, 'IA', 'CONCESSO', '2025-02-15 14:00:00', NULL, 'Autorizzato uso algoritmi DSS'),
(9, 5, 'PRIVACY', 'CONCESSO', '2025-03-01 08:30:00', NULL, 'Consenso privacy completo'),
(10, 5, 'IA', 'REVOCATO', '2025-03-01 08:30:00', NULL, 'Trattamento IA non accettato');

-- -----------------------------------------------------------------------------
-- 5. PRESTAZIONI, SLOT CALENDARIO E PRENOTAZIONI
-- -----------------------------------------------------------------------------
INSERT INTO VISITA_TIPO (visita_tipo_id, codice, descrizione, specialita, durata_minuti, icd9_predefinito) VALUES
(1, 'VIS-CARD-01', 'Visita Cardiologica Prima Visita', 'Cardiologia', 30, '401.9'),
(2, 'VIS-MED-01',  'Visita Internistica Generale', 'Medicina Interna', 30, '780.60'),
(3, 'VIS-NEUR-01', 'Visita Neurologica Specialistica', 'Neurologia', 45, '784.0'),
(4, 'VIS-PNEU-01', 'Visita Pneumologica e Controllo', 'Pneumologia', 30, '486');

INSERT INTO CALENDARIO_SLOT (slot_id, ambulatorio_id, medico_id, inizio, fine, stato, fonte) VALUES
(1, 1, 1, '2026-09-10 09:00:00', '2026-09-10 09:30:00', 'OCCUPATO', 'CUP'),
(2, 2, 2, '2026-09-10 10:00:00', '2026-09-10 10:30:00', 'OCCUPATO', 'CUP'),
(3, 3, 3, '2026-09-10 11:00:00', '2026-09-10 11:45:00', 'OCCUPATO', 'PORTALE'),
(4, 4, 4, '2026-09-10 12:00:00', '2026-09-10 12:30:00', 'OCCUPATO', 'CUP'),
(5, 1, 1, '2026-09-11 09:00:00', '2026-09-11 09:30:00', 'LIBERO', 'SISTEMA');

INSERT INTO PRENOTAZIONE (prenotazione_id, paziente_id, ambulatorio_id, visita_tipo_id, medico_id, priorita, motivo, inizio, fine, stato) VALUES
(1, 1, 1, 1, 1, 'ORDINARIA', 'Controllo pressione e dolore toracico lieve', '2026-09-10 09:00:00', '2026-09-10 09:30:00', 'EROGATA'),
(2, 2, 2, 2, 2, 'ORDINARIA', 'Pico febbrile persistente e astenia', '2026-09-10 10:00:00', '2026-09-10 10:30:00', 'EROGATA'),
(3, 4, 3, 3, 3, 'URGENTE',   'Cefalea intensa da tre giorni', '2026-09-10 11:00:00', '2026-09-10 11:45:00', 'EROGATA'),
(4, 5, 4, 4, 4, 'ORDINARIA', 'Tosse persistente con dispnea', '2026-09-10 12:00:00', '2026-09-10 12:30:00', 'CONFERMATA'),
(5, 3, 2, 2, 2, 'ORDINARIA', 'Check-up generale', '2026-09-11 10:00:00', '2026-09-11 10:30:00', 'CREATA');

-- -----------------------------------------------------------------------------
-- 6. VISITE, ESAMI, REFERTI E DIAGNOSI
-- -----------------------------------------------------------------------------
INSERT INTO VISITA (visita_id, prenotazione_id, paziente_id, medico_id, ambulatorio_id, anamnesi, sintomi, esame_obiettivo, vitali_testo, stato, started_at, ended_at) VALUES
(1, 1, 1, 1, 1, 'Anamnesi positiva per ipertensione', 'Dolore toracico atipico, palpitazioni', 'Toni cardiaci validi, no soffio', 'PA: 145/95 mmHg, FC: 82 bpm', 'CHIUSA', '2026-09-10 09:02:00', '2026-09-10 09:31:00'),
(2, 2, 2, 2, 2, 'Paziente diabetica in terapia orale', 'Febbre a 38.5C, brividi, tosse', 'Oscultazione polmonare con rantoli basi', 'PA: 120/80 mmHg, TC: 38.5 C', 'CHIUSA', '2026-09-10 10:05:00', '2026-09-10 10:35:00'),
(3, 3, 4, 3, 3, 'Soggetta a cefalee frequenti', 'Cefalea pulsante retro-orbitaria', 'Nervio cranici indenni, no segni meningei', 'PA: 130/85 mmHg, FC: 75 bpm', 'CHIUSA', '2026-09-10 11:00:00', '2026-09-10 11:40:00');

INSERT INTO ALLEGATO_VISITA (allegato_id, visita_id, tipo, uri, descrizione) VALUES
(1, 1, 'ECG_TRACCIATO', '/storage/docs/visita_1_ecg.pdf', 'Tracciato ECG a 12 derivazioni'),
(2, 2, 'RX_TORACE', '/storage/docs/visita_2_rx.png', 'Radiografia del torace antero-posteriore');

INSERT INTO ESAME (esame_id, visita_id, tipo, codice_loinc, stato, programmato_per, eseguito_il) VALUES
(1, 1, 'Troponina I cardiaca', '10839-9', 'ESEGUITO', '2026-09-10 09:30:00', '2026-09-10 09:50:00'),
(2, 2, 'Emocromo completo', '57021-8', 'ESEGUITO', '2026-09-10 10:40:00', '2026-09-10 11:10:00'),
(3, 3, 'TAC Cenerello / Encefalo', '24725-4', 'PROGRAMMATO', '2026-09-12 15:00:00', NULL);

INSERT INTO REFERTO (referto_id, esame_id, dati_strutturati, allegato_uri, autore_id, versione) VALUES
(1, 1, 'Troponina I: 0.01 ng/mL (Negativo per necrosi miocardica)', '/storage/ref/ref_101.pdf', 1, 1),
(2, 2, 'Leucociti: 13.500 /uL (Leucocitosi con neutrofilia), PCR: 45 mg/L', '/storage/ref/ref_102.pdf', 2, 1);

INSERT INTO DIAGNOSI (diagnosi_id, visita_id, codice_icd9, descrizione, stato, autore_medico_id, validata_il, versione) VALUES
(1, 1, '401.9', 'Ipertensione arteriosa essenziale in scarso controllo farmacologico', 'FINALE', 1, '2026-09-10 09:35:00', 1),
(2, 2, '486',   'Polmonite batterica acuta del lobo inferiore', 'FINALE', 2, '2026-09-10 11:20:00', 1),
(3, 3, '784.0', 'Cefalea muscolo-tensiva intensa', 'PROVVISORIA', 3, '2026-09-10 11:42:00', 1);

-- -----------------------------------------------------------------------------
-- 7. INTEGRAZIONE MOTORE IA (AI DSS)
-- -----------------------------------------------------------------------------
INSERT INTO AI_SUGGERIMENTO (suggerimento_id, visita_id, modello_versione, candidato_codice, candidato_descr, confidenza, spiegazione) VALUES
(1, 1, 'AI-DSS-v2.1', '786.50', 'Dolore toracico non specificato', 0.8200, 'Sintomatologia toracica associata a valori pressori elevati.'),
(2, 1, 'AI-DSS-v2.1', '401.9',  'Ipertensione arteriosa essenziale', 0.9400, 'Valori PA 145/95 e familiarita elevata.'),
(3, 2, 'AI-DSS-v2.1', '486',    'Polmonite batterica', 0.8900, 'Presenza di febbre alta, rantoli ed elevati leucociti.');

INSERT INTO AI_AZIONE_MEDICO (azione_id, suggerimento_id, medico_id, azione, nota, timestamp) VALUES
(1, 1, 1, 'RIGETTA', 'Troponina negativa, escluso dolore toracico di origine ischemica', '2026-09-10 09:33:00'),
(2, 2, 1, 'ACCETTA', 'Confermata ipertensione essenziale', '2026-09-10 09:34:00'),
(3, 3, 2, 'ACCETTA', 'Quadro clinico e referto ematico concordanti con polmonite', '2026-09-10 11:18:00');

-- -----------------------------------------------------------------------------
-- 8. UTENTI E AUDIT LOG
-- -----------------------------------------------------------------------------
INSERT INTO UTENTE_SISTEMA (utente_id, username, ruolo, medico_id, attivo) VALUES
(1, 'admin', 'AMMIN', NULL, 'Y'),
(2, 'dr_rossi', 'MEDICO', 1, 'Y'),
(3, 'dr_bianchi', 'MEDICO', 2, 'Y'),
(4, 'auditor_1', 'AUDITOR', NULL, 'Y');

INSERT INTO LOG (log_id, entita, entita_id, azione, utente_id, diff_testo, ip) VALUES
(1, 'PAZIENTE', 1, 'CREATE', 1, 'Inserito nuovo paziente Marco Russo', '192.168.1.50'),
(2, 'VISITA', 1, 'CREATE', 2, 'Aperta visita cardiologica ID 1', '192.168.1.101'),
(3, 'DIAGNOSI', 1, 'CREATE', 2, 'Inserita diagnosi finale ICD-9 401.9', '192.168.1.101');