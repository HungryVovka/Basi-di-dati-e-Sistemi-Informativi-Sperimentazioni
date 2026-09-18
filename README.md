# Basi di dati e Sistemi Informativi: Sperimentazioni - A.A. 2025-2026
# Progettazione e realizzazione di una base di dati
Consegnare una relazione che illustri il lavoro effettuato per la progettazione della base di dati derivante dai
requisiti indicati nella sezione “Requisiti iniziali” e che segua rigorosamente lo schema guida indicato nei file
“2 Schema progettazione concettuale”, “3 Schema progettazione logica”, “4 DDL e DML”. Nella prima pagina
della relazione devono essere riportati i nomi, cognomi, numeri di matricola e indirizzi e-mail dei componenti
del gruppo.

Supponendo che un gruppo sia composto dagli studenti di cognome A, B, C, si consegnino i seguenti file:
* Un file “A_B_C_Relazione” contenente la relazione (unione dei file “2 Schema progettazione
concettuale”, “3 Schema progettazione logica”, “4 DDL e DML”, che non dovete consegnare
separatamente).
* Tre file “A_B_C_DDL.sql”, “A_B_C_DMLPOP.sql”, “A_B_C_DMLUPD.sql” contenenti gli
script SQL indicati nel file “4 DDL e DML”.
Tali file dovranno essere consegnati in una cartella compressa “A_B_C.zip” insieme al file contenente le query
della parte di SQL.

## Schema guida
* 1. Progettazione concettuale
  + 1.1. Requisiti iniziali (testo integrato con osservazioni fatte a partire dai file forniti)
  + 1.2. Glossario dei termini
  + 1.5. Schema E-R + regole aziendali

## Come auto-valutare il proprio schema E-R (+ business rules):
* § Correttezza: controllare se i costrutti sono usati propriamente. Inoltre nella stesura dello schema ER non bisogna considerare come verrà tradotto in relazionale (evitate errori come: omettere gli
identificatori delle entità, aggiungere identificatori alle associazioni, aggiungere alle associazioni
gli identificatori delle entità coinvolte, non indicare il tipo di generalizzazione, dare lo stesso nome
a due entità o associazioni, usare un identificatore esterno basato su associazioni non (1,1) o un
identificatore basato su attributi opzionali o multivalore)
* § Completezza: rileggere i requisiti iniziali e considerare se ogni informazione rilevante è stata
rappresentata nelle entità, associazioni, attributi, identificatori, cardinalità dell’E-R o nelle business
rules. Verificare la coerenza degli identificatori delle entità e delle sottoentità gerarchiche con i
requisiti riscritti.
* § Leggibilità: L’E-R è intuitivo? I nomi dati alle entità/associazioni sono facilmente comprensibili?
È chiaro cosa rappresentano?
* § Minimalità: Sono presenti ridondanze indesiderate? È possibile rappresentare le stesse informazioni
in modo più semplice.

## 2. Progettazione logica
  * 2.1. Ristrutturazione dello schema E-R
  * 2.1.1.Eliminazione delle generalizzazioni (motivare le scelte effettuate)
  * 2.1.2.Eventuale partizionamento/accorpamento di entità e associazioni (motivare
le scelte effettuate)
  * 2.1.3.Eventuale scelta degli identificatori principali (motivare le scelte effettuate)
  * 2.2. Schema E-R ristrutturato + regole aziendali
  * 2.3. Schema relazionale (indicare anche i vincoli di integrità referenziale)2

## 3. SQL DDL/DML
  * 3.1. DDL di creazione del database
  * 3.2. DML di popolamento di tutte le tabelle del database (se popolate il database con dati verosimili,
potreste rendervi conto di errori commessi nella fase di progettazione concettuale e di cui avreste
dovuto rendervi conto prima)
  * 3.3. Qualche operazione di cancellazione e modifica per verificare i vincoli e gli effetti causati da
operazioni su chiavi esterni
