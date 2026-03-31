CREATE DATABASE IF NOT EXISTS cyberspace_nis2
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cyberspace_nis2;
-- TABELLE 1: Benutzer
CREATE TABLE Benutzer (
                          BenutzerId    INT             NOT NULL AUTO_INCREMENT,
                          Benutzername  VARCHAR(50)     NOT NULL,
                          Email         VARCHAR(255)    NOT NULL,
                          PasswortHash  VARCHAR(255)    NOT NULL,
                          Rolle         ENUM('Spieler','Moderator','Admin') NOT NULL,
                          ErstelltAm    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          FehlgeschlagenLogin  INT      NOT NULL DEFAULT 0,
                          GesperrtBis          DATETIME NULL,
                          Punkte        INT             NULL,
                          Abzeichen     VARCHAR(100)    NULL,
                          Abteilung     VARCHAR(100)    NULL,

                          PRIMARY KEY (BenutzerId),
                          UNIQUE KEY UQ_Benutzer_Email (Email)
);
CREATE TABLE Szenario (
                          SzenarioId        INT             NOT NULL AUTO_INCREMENT,
                          Titel             VARCHAR(100)    NOT NULL,
                          Beschreibung      TEXT            NULL,
                          SchwierigkeitsGrad ENUM('Einfach','Mittel','Schwer') NOT NULL,
                          Zielgruppe        ENUM('Einsteiger','Fortgeschrittene','Experten') NOT NULL,
                          Status            ENUM('Entwurf','Aktiv','Archiviert') NOT NULL DEFAULT 'Entwurf',
                          MinSpieler        INT             NOT NULL DEFAULT 2,
                          MaxSpieler        INT             NOT NULL DEFAULT 6,
                          MinPunkte         INT             NOT NULL DEFAULT 0,
                          ErstelltAm        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          ErstelltVon       INT             NOT NULL,

                          PRIMARY KEY (SzenarioId)
);
CREATE TABLE Rollen (
                        RolleId     INT             NOT NULL AUTO_INCREMENT,
                        Name        VARCHAR(50)     NOT NULL,
                        Beschreibung TEXT           NULL,

-- RollenFarbe (ValueObject)
                        Farbe       VARCHAR(20)     NULL,
                        FarbeHex    VARCHAR(7)      NULL,

                        PRIMARY KEY (RolleId),
                        UNIQUE KEY UQ_Rollen_Name (Name)
);
CREATE TABLE Statstik (
                          StatstikId      INT         NOT NULL AUTO_INCREMENT,
                          BenutzerId      INT         NOT NULL,
                          GespielteSpiele INT         NOT NULL DEFAULT 0,
                          GesamtPunkte    INT         NOT NULL DEFAULT 0,
                          BestePunktzahl  INT         NOT NULL DEFAULT 0,
                          ErstelltAm      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,

                          PRIMARY KEY (StatstikId)
);
CREATE TABLE Phase (
                       PhaseId         INT             NOT NULL AUTO_INCREMENT,
                       SzenarioId      INT             NOT NULL,
                       Titel           VARCHAR(100)    NOT NULL,
                       Beschreibung    TEXT            NULL,
                       Reihenfolge     INT             NOT NULL DEFAULT 1,
                       ZeitlimitSek    INT             NULL,

                       PRIMARY KEY (PhaseId)
);
CREATE TABLE SzenarioRolle (
                               SzenarioId  INT     NOT NULL,
                               RolleId     INT     NOT NULL,

                               PRIMARY KEY (SzenarioId, RolleId)
);

CREATE TABLE Session (
                         SessionID INT PRIMARY KEY AUTO_INCREMENT,
                         SzenarioID INT NOT NULL,
                         ModeratorID INT NOT NULL,
                         SessionName VARCHAR(100) NOT NULL COMMENT 'Name der Session',  
                         Status ENUM('Warten', 'Aktiv', 'Pausiert', 'Beendet') NOT NULL DEFAULT 'Warten',
                         AktuellePhase INT DEFAULT 1,
                         Startzeit DATETIME NULL,
                         Endzeit DATETIME NULL,
                         ErstelltAm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         BeendigungsGrund VARCHAR(200) NULL,
                         FOREIGN KEY (SzenarioID) REFERENCES Szenario(SzenarioID),
                         FOREIGN KEY (ModeratorID) REFERENCES Benutzer(BenutzerID)
) COMMENT = 'Laufende Spielsessions';


CREATE TABLE Karte (
                       KarteId         INT             NOT NULL AUTO_INCREMENT,
                       PhaseId         INT             NOT NULL,
                       Titel           VARCHAR(100)    NOT NULL,
                       Inhalt          TEXT            NULL,
                       KartenTyp       ENUM('Aktion','Ereignis','Reaktion','Information') NOT NULL,
                       Punkte          INT             NOT NULL DEFAULT 0,
                       Reihenfolge     INT             NOT NULL DEFAULT 1,

                       PRIMARY KEY (KarteId)
);
CREATE TABLE SessionSpieler (
                                SessionId   INT     NOT NULL,
                                SpielerId   INT     NOT NULL,
                                RolleId     INT     NULL,
                                Status      ENUM('Eingeladen','Aktiv','Inaktiv','Ausgeschieden') NOT NULL DEFAULT 'Eingeladen',
                                Punkte      INT     NOT NULL DEFAULT 0,
                                BeigetretenAm DATETIME NULL,

                                PRIMARY KEY (SessionId, SpielerId)
);
CREATE TABLE Einladung (
                           EinladungId     INT         NOT NULL AUTO_INCREMENT,
                           SessionId       INT         NOT NULL,
                           EingeladenVon   INT         NOT NULL,
                           EingeladenAn    INT         NOT NULL,
                           Status          ENUM('Ausstehend','Angenommen','Abgelehnt') NOT NULL DEFAULT 'Ausstehend',
                           ErstelltAm      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,

                           PRIMARY KEY (EinladungId)
);
CREATE TABLE `Option` (
                          OptionId        INT             NOT NULL AUTO_INCREMENT,
                          KarteId         INT             NOT NULL,
                          Text            VARCHAR(255)    NOT NULL,
                          IstRichtig      TINYINT(1)      NOT NULL DEFAULT 0,
                          Punkte          INT             NOT NULL DEFAULT 0,

                          PRIMARY KEY (OptionId)
);
CREATE TABLE Protokoll (
                           ProtokollId     INT         NOT NULL AUTO_INCREMENT,
                           SessionId       INT         NOT NULL,
                           BenutzerId      INT         NOT NULL,
                           Aktion          ENUM('Beigetreten','Verlassen','KarteGezogen','OptionGewaehlt','PunktErhalten','Gesperrt') NOT NULL,
                           Zeitstempel     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           Details         TEXT        NULL,

                           PRIMARY KEY (ProtokollId)
);
CREATE TABLE Spielverlauf (
                              SpieverlaufId   INT         NOT NULL AUTO_INCREMENT,
                              SessionId       INT         NOT NULL,
                              KarteId         INT         NOT NULL,
                              OptionId        INT         NULL,
                              SpielerId       INT         NOT NULL,
                              Zeitstempel     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              ErhaltePunkte   INT         NOT NULL DEFAULT 0,

                              PRIMARY KEY (SpieverlaufId)
);
-- FOREIGN KEYS
-- Szenario → Benutzer 
ALTER TABLE Szenario
    ADD CONSTRAINT FK_Szenario_Benutzer
        FOREIGN KEY (ErstelltVon) REFERENCES Benutzer(BenutzerId);
-- Statstik → Benutzer
ALTER TABLE Statstik
    ADD CONSTRAINT FK_Statstik_Benutzer
        FOREIGN KEY (BenutzerId) REFERENCES Benutzer(BenutzerId);
-- Phase → Szenario
ALTER TABLE Phase
    ADD CONSTRAINT FK_Phase_Szenario
        FOREIGN KEY (SzenarioId) REFERENCES Szenario(SzenarioId);
-- SzenarioRolle → Szenario
ALTER TABLE SzenarioRolle
    ADD CONSTRAINT FK_SzenarioRolle_Szenario
        FOREIGN KEY (SzenarioId) REFERENCES Szenario(SzenarioId);
-- SzenarioRolle → Rollen
ALTER TABLE SzenarioRolle
    ADD CONSTRAINT FK_SzenarioRolle_Rollen
        FOREIGN KEY (RolleId) REFERENCES Rollen(RolleId);
-- Session → Szenario
ALTER TABLE Session
    ADD CONSTRAINT FK_Session_Szenario
        FOREIGN KEY (SzenarioId) REFERENCES Szenario(SzenarioId);
-- Session → Benutzer (Moderator)
ALTER TABLE Session
    ADD CONSTRAINT FK_Session_Moderator
        FOREIGN KEY (ModeratorId) REFERENCES Benutzer(BenutzerId);
-- Karte → Phase
ALTER TABLE Karte
    ADD CONSTRAINT FK_Karte_Phase
        FOREIGN KEY (PhaseId) REFERENCES Phase(PhaseId);
-- SessionSpieler → Session
ALTER TABLE SessionSpieler
    ADD CONSTRAINT FK_SessionSpieler_Session
        FOREIGN KEY (SessionId) REFERENCES Session(SessionId);
-- SessionSpieler → Benutzer (Spieler)
ALTER TABLE SessionSpieler
    ADD CONSTRAINT FK_SessionSpieler_Spieler
        FOREIGN KEY (SpielerId) REFERENCES Benutzer(BenutzerId);
-- SessionSpieler → Rollen
ALTER TABLE SessionSpieler
    ADD CONSTRAINT FK_SessionSpieler_Rollen
        FOREIGN KEY (RolleId) REFERENCES Rollen(RolleId);
-- Einladung → Session
ALTER TABLE Einladung
    ADD CONSTRAINT FK_Einladung_Session
        FOREIGN KEY (SessionId) REFERENCES Session(SessionId);

-- Einladung → Benutzer (EingeladenVon)
ALTER TABLE Einladung
    ADD CONSTRAINT FK_Einladung_Von
        FOREIGN KEY (EingeladenVon) REFERENCES Benutzer(BenutzerId);

-- Einladung → Benutzer (EingeladenAn)
ALTER TABLE Einladung
    ADD CONSTRAINT FK_Einladung_An
        FOREIGN KEY (EingeladenAn) REFERENCES Benutzer(BenutzerId);

-- Option → Karte
ALTER TABLE `Option`
    ADD CONSTRAINT FK_Option_Karte
        FOREIGN KEY (KarteId) REFERENCES Karte(KarteId);

-- Protokoll → Session
ALTER TABLE Protokoll
    ADD CONSTRAINT FK_Protokoll_Session
        FOREIGN KEY (SessionId) REFERENCES Session(SessionId);

-- Protokoll → Benutzer
ALTER TABLE Protokoll
    ADD CONSTRAINT FK_Protokoll_Benutzer
        FOREIGN KEY (BenutzerId) REFERENCES Benutzer(BenutzerId);

-- Spielverlauf → Session
ALTER TABLE Spielverlauf
    ADD CONSTRAINT FK_Spielverlauf_Session
        FOREIGN KEY (SessionId) REFERENCES Session(SessionId);

-- Spielverlauf → Karte
ALTER TABLE Spielverlauf
    ADD CONSTRAINT FK_Spielverlauf_Karte
        FOREIGN KEY (KarteId) REFERENCES Karte(KarteId);

-- Spielverlauf → Option
ALTER TABLE Spielverlauf
    ADD CONSTRAINT FK_Spielverlauf_Option
        FOREIGN KEY (OptionId) REFERENCES `Option`(OptionId);

-- Spielverlauf → Benutzer (Spieler)
ALTER TABLE Spielverlauf
    ADD CONSTRAINT FK_Spielverlauf_Spieler
        FOREIGN KEY (SpielerId) REFERENCES Benutzer(BenutzerId);

-- ------------------------------
-- ---- Tabelle Anbassen
-- PasswortHash VARCHAR(60)
ALTER TABLE Benutzer
    MODIFY PasswortHash VARCHAR(60) NOT NULL;
-- ---
ALTER TABLE Szenario
    ADD COLUMN Nis2Artikel  VARCHAR(50) NULL,
ADD COLUMN DauerMinuten INT NOT NULL DEFAULT 30,
ADD COLUMN AnzahlPhasen INT NOT NULL DEFAULT 1;

ALTER TABLE Szenario
    ADD CONSTRAINT CHK_Szenario_Dauer
        CHECK (DauerMinuten BETWEEN 15 AND 120);

ALTER TABLE Szenario
    ADD CONSTRAINT CHK_Szenario_Phasen
        CHECK (AnzahlPhasen BETWEEN 1 AND 10);
--  Zielgruppe ENUM anpassen
ALTER TABLE Szenario
    MODIFY Zielgruppe
    ENUM('Führungskräfte','IT-Personal','Alle') NOT NULL;
-- Karte anpassen
ALTER TABLE Karte
    MODIFY Titel  VARCHAR(80)  NOT NULL,
    MODIFY Inhalt VARCHAR(300) NULL,
    ADD COLUMN KartenCode VARCHAR(10) NULL;

ALTER TABLE Karte
    ADD CONSTRAINT UQ_Karte_KartenCode
        UNIQUE (KartenCode);
-- Option anpassen
ALTER TABLE `Option`
    MODIFY Text VARCHAR(100) NOT NULL;

ALTER TABLE Karte
    ADD COLUMN ReaktionsTyp ENUM(
    'PositiverSchritt',
    'NegativerSchritt',
    'Wiederherstellung',
    'Sackgasse'
) NULL,
ADD COLUMN AktioKarteId INT NULL;

-- Karten Sprint 4 US 3.2.2
ALTER TABLE Karte ADD COLUMN Nis2Artikel VARCHAR(50) NULL;

-- Phase anpassen
ALTER TABLE Phase
    MODIFY Beschreibung VARCHAR(200) NULL,
    ADD COLUMN StartKarteId INT NULL,
    ADD COLUMN EndKarteId   INT NULL,
    ADD COLUMN MinPunkte    INT NOT NULL DEFAULT 1;

ALTER TABLE Phase
    ADD CONSTRAINT CHK_Phase_Nummer
        CHECK (Reihenfolge BETWEEN 1 AND 5);

ALTER TABLE Phase
    ADD CONSTRAINT CHK_Phase_MinPunkte
        CHECK (MinPunkte > 0);

-- Rollen anpassen
ALTER TABLE Rollen
    MODIFY Beschreibung VARCHAR(200) NULL;

ALTER TABLE Rollen
    ADD CONSTRAINT CHK_Rollen_Farbe
        CHECK (Farbe IN ('Grau','Blau','Rot','Gruen','Lila'));

-- CHECK Reaktions-Punkte (US 1.2.2 - Task 2)
ALTER TABLE Karte
    ADD CONSTRAINT CHK_Karte_ReaktionsPunkte
        CHECK (
            KartenTyp != 'Reaktion' OR
    Punkte IN (50, -30, 20, -50)
    );
-- ---------
    
-- Karte-> Karte (Reacktion-Actio)
ALTER TABLE Karte
    ADD CONSTRAINT FK_Karte_AktioKarte
        FOREIGN KEY (AktioKarteId) REFERENCES Karte(KarteId);
-- Phase-> Karte (start Karte)
ALTER TABLE Phase
    ADD CONSTRAINT FK_Phase_StartKarte
        FOREIGN KEY (StartKarteId) REFERENCES Karte(KarteId);
-- EndKarte
ALTER TABLE Phase
    ADD CONSTRAINT FK_Phase_EndKarte
        FOREIGN KEY (EndKarteId) REFERENCES Karte(KarteId);


-- -----SessionPausiert 
ALTER TABLE Protokoll
    MODIFY Aktion ENUM(
    'Beigetreten',
    'Verlassen',
    'KarteGezogen',
    'OptionGewaehlt',
    'PunktErhalten',
    'Gesperrt',
    'SessionPausiert'
    ) NOT NULL;
    
-- **************************************
-- SCHRITT 4: SEED-DATEN
-- ************************************

-- ---- Benutzer 
INSERT INTO Benutzer
(Benutzername, Email, PasswortHash, Rolle, FehlgeschlagenLogin, Punkte, Abteilung)
VALUES
    ('admin_aya',    'aya@cyberspace.at',        'hash_admin_123',  'Admin',     0, NULL, NULL),
    ('mod_karen',    'karen@cyberspace.at',       'hash_mod_456',    'Moderator', 0, NULL, 'IT-Security'),
    ('mod_ekaterine','ekaterine@cyberspace.at',   'hash_mod_789',    'Moderator', 0, NULL, 'Backend'),
    ('spieler_max',  'max@cyberspace.at',         'hash_sp_001',     'Spieler',   0, 0,    NULL),
    ('spieler_anna', 'anna@cyberspace.at',        'hash_sp_002',     'Spieler',   0, 0,    NULL),
    ('spieler_tom',  'tom@cyberspace.at',         'hash_sp_003',     'Spieler',   0, 0,    NULL);

-- ---- Rollen -----
INSERT INTO Rollen (Name, Beschreibung, Farbe, FarbeHex)
VALUES
    ('CEO',  'Chief Executive Officer - Gesamtverantwortung',      'Grau',  '#808080'),
    ('CTO',  'Chief Technology Officer - IT-Infrastruktur',        'Blau',  '#0000FF'),
    ('CFO',  'Chief Financial Officer - Finanzen und Budget',      'Rot',   '#FF0000'),
    ('CISO', 'Chief Information Security Officer - IT-Sicherheit', 'Gruen', '#00FF00'),
    ('ERM',  'Enterprise Risk Manager - Risikomanagement',         'Lila',  '#800080');

-- ---- Szenario 
INSERT INTO Szenario
(Titel, Beschreibung, SchwierigkeitsGrad, Zielgruppe, Status, MinSpieler, MaxSpieler, MinPunkte, ErstelltVon)
VALUES
    ('Ransomware Angriff',
     'Ein Unternehmen wird mit Ransomware angegriffen.',
     'Mittel', 'IT-Personal', 'Aktiv', 2, 6, 0, 2), 

    ('Lieferketten Angriff',
     'Angriff ueber einen externen Lieferanten.',
     'Schwer', 'Führungskräfte', 'Entwurf', 3, 8, 0, 2),  

    ('Datenschutz Grundlagen',
     'Einfuehrung in NIS2 und DSGVO.',
     'Einfach', 'Alle', 'Aktiv', 2, 4, 0, 2);

-- ---- Phase ----
INSERT INTO Phase
(SzenarioId, Titel, Beschreibung, Reihenfolge, ZeitlimitSek)
VALUES
    (1, 'Erkennung',     'Ransomware wird entdeckt',           1, 300),
    (1, 'Eindaemmung',   'Ausbreitung stoppen',                2, 600),
    (1, 'Wiederherstellung', 'Systeme wiederherstellen',       3, 900),
    (3, 'Grundlagen',    'NIS2 Grundbegriffe kennenlernen',    1, 600),
    (3, 'Anwendung',     'Regeln auf Beispiele anwenden',      2, 600);

-- ---- SzenarioRolle ----
INSERT INTO SzenarioRolle (SzenarioId, RolleId)
VALUES
    (1, 1),  -- Ransomware + CEO
    (1, 2),  -- Ransomware + CTO
    (1, 4),  -- Ransomware + CISO
    (3, 1),  -- Datenschutz + CEO
    (3, 4);  -- Datenschutz + CISO

-- ---- Karte ---------
INSERT INTO Karte
(PhaseId, Titel, Inhalt, KartenTyp, Punkte, Reihenfolge)
VALUES
    (1, 'Verdaechtiger Prozess',
     'Ein unbekannter Prozess verschluesselt Dateien. Was tust du?',
     'Ereignis', 10, 1),

    (1, 'Netzwerk trennen',
     'Trenne das betroffene System sofort vom Netzwerk.',
     'Aktion', 20, 2),

    (2, 'Backup pruefen',
     'Sind aktuelle Backups vorhanden und nicht infiziert?',
     'Information', 15, 1),

    (4, 'Was ist NIS2?',
     'NIS2 ist eine EU-Richtlinie fuer Cybersicherheit.',
     'Information', 5, 1);

-- ---- Option --------
INSERT INTO `Option`
(KarteId, Text, IstRichtig, Punkte)
VALUES
    (1, 'System sofort herunterfahren',     1, 20),
    (1, 'Weiterarbeiten und ignorieren',    0, 0),
    (1, 'IT-Abteilung benachrichtigen',     1, 15),
    (3, 'Ja, Backup ist sicher',            1, 15),
    (3, 'Nein, kein Backup vorhanden',      0, 0),
    (4, 'EU-Richtlinie fuer Cybersicherheit', 1, 5),
    (4, 'Ein Antivirenprogramm',              0, 0);
-- **********************
-- VIEWS
-- ************************
-- Alle Spieler mit Punkten 
CREATE VIEW View_TopSpieler AS
SELECT
    b.BenutzerId,
    b.Benutzername,
    b.Email,
    COALESCE(SUM(ss.Punkte), 0)  AS GesamtPunkte,
    COUNT(ss.SessionId)          AS AnzahlSessions
FROM Benutzer b
         LEFT JOIN SessionSpieler ss ON b.BenutzerId = ss.SpielerId
WHERE b.Rolle = 'Spieler'
GROUP BY b.BenutzerId, b.Benutzername, b.Email
ORDER BY GesamtPunkte DESC;

-- Aktive Sessions mit Details 
CREATE VIEW View_AktiveSessions AS
SELECT
    s.SessionId,
    sz.Titel        AS SzenarioTitel,
    sz.SchwierigkeitsGrad,
    b.Benutzername  AS Moderator,
    s.Status,
    s.StartZeit,
    COUNT(ss.SpielerId) AS AnzahlSpieler
FROM Session s
         JOIN Szenario sz     ON s.SzenarioId  = sz.SzenarioId
         JOIN Benutzer b      ON s.ModeratorId = b.BenutzerId
         LEFT JOIN SessionSpieler ss ON s.SessionId = ss.SessionId
WHERE s.Status IN ('Warten', 'Aktiv')
GROUP BY s.SessionId, sz.Titel, sz.SchwierigkeitsGrad,
         b.Benutzername, s.Status, s.StartZeit;

-- Spielverlauf mit Details 
CREATE VIEW View_Spielverlauf AS
SELECT
    sv.SpieverlaufId,
    s.SessionId,
    sz.Titel        AS SzenarioTitel,
    b.Benutzername  AS Spieler,
    k.Titel         AS Karte,
    o.Text          AS GewaehlteOption,
    o.IstRichtig,
    sv.ErhaltePunkte,
    sv.Zeitstempel
FROM Spielverlauf sv
         JOIN Session s      ON sv.SessionId  = s.SessionId
         JOIN Szenario sz    ON s.SzenarioId  = sz.SzenarioId
         JOIN Benutzer b     ON sv.SpielerId  = b.BenutzerId
         JOIN Karte k        ON sv.KarteId    = k.KarteId
         LEFT JOIN `Option` o ON sv.OptionId  = o.OptionId;

--  Moderator Dashboard 
CREATE VIEW View_ModeratorDashboard AS
SELECT
    b.BenutzerId    AS ModeratorId,
    b.Benutzername  AS Moderator,
    COUNT(s.SessionId)                              AS GesamtSessions,
    SUM(CASE WHEN s.Status = 'Beendet' THEN 1
             ELSE 0 END)                            AS AbgeschlosseneSessions,
    SUM(CASE WHEN s.Status = 'Aktiv' THEN 1
             ELSE 0 END)                            AS LaufendeSessions
FROM Benutzer b
         LEFT JOIN Session s ON b.BenutzerId = s.ModeratorId
WHERE b.Rolle = 'Moderator'
GROUP BY b.BenutzerId, b.Benutzername;

-- View_SzenarioDashboard (US 1.6.1 - Task 19)
CREATE VIEW View_SzenarioDashboard AS
SELECT
    s.SzenarioId,
    s.Titel,
    s.Status,
    s.SchwierigkeitsGrad,
    s.ErstelltAm,
    COUNT(DISTINCT p.PhaseId)  AS AnzahlPhasen,
    COUNT(DISTINCT k.KarteId)  AS AnzahlKarten,
    b.Benutzername             AS ErstelltVon
FROM Szenario s
         LEFT JOIN Phase p    ON s.SzenarioId  = p.SzenarioId
         LEFT JOIN Karte k    ON p.PhaseId     = k.PhaseId
         LEFT JOIN Benutzer b ON s.ErstelltVon = b.BenutzerId
GROUP BY
    s.SzenarioId, s.Titel, s.Status,
    s.SchwierigkeitsGrad, s.ErstelltAm,
    b.Benutzername
ORDER BY s.ErstelltAm DESC;
--  View_PhasenUebersicht (US 1.3.1 - Task 20)
CREATE VIEW View_PhasenUebersicht AS
SELECT
    p.PhaseId,
    p.SzenarioId,
    s.Titel         AS SzenarioTitel,
    p.Titel         AS PhasenName,
    p.Reihenfolge   AS PhasenNummer,
    p.Beschreibung,
    p.MinPunkte,
    p.ZeitlimitSek,
    ks.Titel        AS StartKarte,
    ke.Titel        AS EndKarte,
    COUNT(k.KarteId) AS AnzahlKarten
FROM Phase p
         JOIN Szenario s      ON p.SzenarioId   = s.SzenarioId
         LEFT JOIN Karte ks   ON p.StartKarteId = ks.KarteId
         LEFT JOIN Karte ke   ON p.EndKarteId   = ke.KarteId
         LEFT JOIN Karte k    ON p.PhaseId      = k.PhaseId
GROUP BY
    p.PhaseId, p.SzenarioId, s.Titel,
    p.Titel, p.Reihenfolge, p.Beschreibung,
    p.MinPunkte, p.ZeitlimitSek,
    ks.Titel, ke.Titel
ORDER BY p.SzenarioId, p.Reihenfolge;
-- View_RollenUebersicht (US 1.4.1 - Task 21)
CREATE VIEW View_RollenUebersicht AS
SELECT
    r.RolleId,
    r.Name          AS RollenName,
    r.Beschreibung,
    r.Farbe,
    r.FarbeHex,
    COUNT(DISTINCT sr.SzenarioId) AS AnzahlSzenarien,
    GROUP_CONCAT(s.Titel)         AS ZugeordneteSzenarien
FROM Rollen r
         LEFT JOIN SzenarioRolle sr ON r.RolleId     = sr.RolleId
         LEFT JOIN Szenario s       ON sr.SzenarioId = s.SzenarioId
GROUP BY
    r.RolleId, r.Name,
    r.Beschreibung, r.Farbe, r.FarbeHex;

--  View_VerfuegbareRollen (US 2.3.1 - Task 22)
CREATE VIEW View_VerfuegbareRollen AS
SELECT
    r.RolleId,
    r.Name      AS RollenName,
    r.Beschreibung,
    r.Farbe,
    r.FarbeHex,
    ss.SessionId,
    CASE
        WHEN ss.RolleId IS NOT NULL THEN 'Vergeben'
        ELSE 'Verfügbar'
        END AS RollenStatus
FROM Rollen r
         LEFT JOIN SessionSpieler ss ON r.RolleId = ss.RolleId;

-- View_AktiveSzenarien (US 3.1.1 - Task 23)
CREATE VIEW View_AktiveSzenarien AS
SELECT
    s.SzenarioId,
    s.Titel,
    s.Beschreibung,
    s.SchwierigkeitsGrad,
    s.Zielgruppe,
    s.DauerMinuten,
    s.Nis2Artikel,
    s.MinSpieler,
    s.MaxSpieler,
    COUNT(DISTINCT p.PhaseId) AS AnzahlPhasen,
    COUNT(DISTINCT k.KarteId) AS AnzahlKarten
FROM Szenario s
         LEFT JOIN Phase p ON s.SzenarioId = p.SzenarioId
         LEFT JOIN Karte k ON p.PhaseId    = k.PhaseId
WHERE s.Status = 'Aktiv'
GROUP BY
    s.SzenarioId, s.Titel, s.Beschreibung,
    s.SchwierigkeitsGrad, s.Zielgruppe,
    s.DauerMinuten, s.Nis2Artikel,
    s.MinSpieler, s.MaxSpieler
ORDER BY
    CASE s.SchwierigkeitsGrad
        WHEN 'Einfach' THEN 1
        WHEN 'Mittel'  THEN 2
        WHEN 'Schwer'  THEN 3
        END;
-- View SpilerVerlauf Sprint 4 
CREATE VIEW View_SpielverlaufDetail AS
SELECT
    sv.SpieverlaufId,
    sv.SessionId,
    sv.SpielerId,
    b.Benutzername      AS Spieler,
    k.KarteId,
    k.Titel             AS KarteTitel,
    k.Inhalt            AS KarteText,
    k.KartenTyp,
    k.Punkte            AS MaxPunkte,
    sv.OptionId,
    o.Text              AS GewaehlteOption,
    o.IstRichtig,
    sv.ErhaltePunkte,
    sv.Zeitstempel,
    p.Titel             AS PhaseTitel,
    p.Reihenfolge       AS PhaseNummer,
    sz.Titel            AS SzenarioTitel,
    0                   AS AbgeschlossenePhasen,
    0                   AS GesamtPhasen,
    0                   AS GespielteKarten,
    0                   AS GesamtKarten
FROM Spielverlauf sv
         JOIN Session s       ON sv.SessionId  = s.SessionID
         JOIN Szenario sz     ON s.SzenarioID  = sz.SzenarioId
         JOIN Benutzer b      ON sv.SpielerId  = b.BenutzerId
         JOIN Karte k         ON sv.KarteId    = k.KarteId
         JOIN Phase p         ON k.PhaseId     = p.PhaseId
         LEFT JOIN `Option` o ON sv.OptionId   = o.OptionId;
-- View Feedback 
CREATE VIEW View_ErfolgsFeedback AS
SELECT
    sv.SpieverlaufId,
    sv.SessionId,
    sv.SpielerId,
    b.Benutzername      AS Spieler,
    k.Titel             AS KarteTitel,
    o.Text              AS GewaehlteOption,
    o.IstRichtig,
    sv.ErhaltePunkte,
    k.KartenTyp,
    -- Reaktions-Karte NNN:001 = PositiverSchritt
    r.ReaktionsTyp,
    r.Inhalt            AS Erklaerung,
    r.Nis2Artikel       AS Nis2Referenz,
    ss.Punkte           AS GesamtPunkte
FROM Spielverlauf sv
         JOIN Benutzer b         ON sv.SpielerId  = b.BenutzerId
         JOIN `Option` o         ON sv.OptionId   = o.OptionId
         JOIN Karte k            ON sv.KarteId    = k.KarteId
         LEFT JOIN Karte r       ON k.KarteId     = r.AktioKarteId
    AND r.ReaktionsTyp = 'PositiverSchritt'
         JOIN SessionSpieler ss  ON sv.SessionId  = ss.SessionId
    AND sv.SpielerId  = ss.SpielerId
WHERE o.IstRichtig = 1;

-- View_ModeratorSessions (US 2.1.1 - ST-1)
CREATE VIEW View_ModeratorSessions AS
SELECT
    s.SessionId,
    s.SessionName,
    s.Status,
    s.ErstelltAm,
    s.Startzeit,
    s.Endzeit,
    sz.Titel        AS SzenarioTitel,
    sz.SchwierigkeitsGrad,
    b.BenutzerId    AS ModeratorId,
    b.Benutzername  AS Moderator,
    COUNT(ss.SpielerId) AS AnzahlSpieler
FROM Session s
         JOIN Szenario sz     ON s.SzenarioId  = sz.SzenarioId
         JOIN Benutzer b      ON s.ModeratorId = b.BenutzerId
         LEFT JOIN SessionSpieler ss ON s.SessionId = ss.SessionId
GROUP BY
    s.SessionId, s.SessionName, s.Status,
    s.ErstelltAm, s.Startzeit, s.Endzeit,
    sz.Titel, sz.SchwierigkeitsGrad,
    b.BenutzerId, b.Benutzername;



-- ******************
-- STORED PROCEDURES
-- *******************
-- Neuen Spieler registrieren
DELIMITER $$
CREATE PROCEDURE SP_SpielerRegistrieren(
    IN p_Benutzername   VARCHAR(50),
    IN p_Email          VARCHAR(255),
    IN p_PasswortHash   VARCHAR(255)
)
BEGIN
INSERT INTO Benutzer
(Benutzername, Email, PasswortHash, Rolle, FehlgeschlagenLogin, Punkte)
VALUES
    (p_Benutzername, p_Email, p_PasswortHash, 'Spieler', 0, 0);
END$$
DELIMITER ;

-- Session starten
DELIMITER $$
CREATE PROCEDURE SP_SessionStarten(
    IN p_SessionId  INT
)
BEGIN
UPDATE Session
SET Status    = 'Aktiv',
    StartZeit = CURRENT_TIMESTAMP
WHERE SessionId = p_SessionId;
END$$
DELIMITER ;

-- Session beenden
DELIMITER $$
CREATE PROCEDURE SP_SessionBeenden(
    IN p_SessionId  INT
)
BEGIN
UPDATE Session
SET Status  = 'Beendet',
    EndZeit = CURRENT_TIMESTAMP
WHERE SessionId = p_SessionId;
END$$
DELIMITER ;

-- Session pausieren (US 2.1.1 - ST-3)
DELIMITER $$
CREATE PROCEDURE SP_SessionPausieren(
    IN p_SessionId INT
)
BEGIN
UPDATE Session
SET Status = 'Pausiert'
WHERE SessionId = p_SessionId
  AND Status = 'Aktiv';

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
SELECT p_SessionId, ModeratorId, 'SessionPausiert', 'Session pausiert'
FROM Session
WHERE SessionId = p_SessionId;
END$$
DELIMITER ;

-- Protokoll Daten abrufen (US 2.1.1 - ST-4)
DELIMITER $$
CREATE PROCEDURE SP_ProtokollDaten(
    IN p_SessionId INT
)
BEGIN
SELECT
    p.ProtokollId,
    p.Zeitstempel,
    p.Aktion,
    p.Details,
    b.Benutzername  AS Benutzer,
    b.Rolle
FROM Protokoll p
         JOIN Benutzer b ON p.BenutzerId = b.BenutzerId
WHERE p.SessionId = p_SessionId
ORDER BY p.Zeitstempel ASC;
END$$
DELIMITER ;

-- Spieler zu Session hinzufügen
DELIMITER $$
CREATE PROCEDURE SP_SpielerHinzufuegen(
    IN p_SessionId  INT,
    IN p_SpielerId  INT
)
BEGIN
INSERT INTO SessionSpieler
(SessionId, SpielerId, Status, Punkte)
VALUES
    (p_SessionId, p_SpielerId, 'Aktiv', 0);

INSERT INTO Protokoll
(SessionId, BenutzerId, Aktion)
VALUES
    (p_SessionId, p_SpielerId, 'Beigetreten');
END$$
DELIMITER ;

-- Punkte vergeben
DELIMITER $$
CREATE PROCEDURE SP_PunkteVergeben(
    IN p_SessionId  INT,
    IN p_SpielerId  INT,
    IN p_Punkte     INT
)
BEGIN
UPDATE SessionSpieler
SET Punkte = Punkte + p_Punkte
WHERE SessionId = p_SessionId
  AND SpielerId = p_SpielerId;

UPDATE Statstik
SET GesamtPunkte = GesamtPunkte + p_Punkte
WHERE BenutzerId = p_SpielerId;

INSERT INTO Protokoll
(SessionId, BenutzerId, Aktion, Details)
VALUES
    (p_SessionId, p_SpielerId, 'PunktErhalten',
     CONCAT('Punkte erhalten: ', p_Punkte));
END$$
DELIMITER ;

-- Login Versuch (US 0.2.1 - Task 9)
DELIMITER $$
CREATE PROCEDURE SP_LoginVersuch(
    IN p_Email   VARCHAR(255),
    IN p_Erfolg  TINYINT(1)
)
BEGIN
    IF p_Erfolg = 1 THEN
UPDATE Benutzer
SET FehlgeschlagenLogin = 0,
    GesperrtBis = NULL
WHERE Email = p_Email;
ELSE
UPDATE Benutzer
SET FehlgeschlagenLogin = FehlgeschlagenLogin + 1
WHERE Email = p_Email;

UPDATE Benutzer
SET GesperrtBis = DATE_ADD(NOW(), INTERVAL 5 MINUTE)
WHERE Email = p_Email
  AND FehlgeschlagenLogin >= 3;
END IF;
END$$
DELIMITER ;

-- Karten Code generieren (US 1.2.1 - Task 10)
DELIMITER $$
CREATE PROCEDURE SP_KartenCodeGenerieren(
    IN  p_KartenTyp   VARCHAR(20),
    OUT p_KartenCode  VARCHAR(10)
)
BEGIN
    DECLARE anzahl INT;
    DECLARE prefix VARCHAR(3);

    SET prefix = CASE p_KartenTyp
        WHEN 'Aktion'      THEN 'ACT'
        WHEN 'Ereignis'    THEN 'ERG'
        WHEN 'Reaktion'    THEN 'REA'
        WHEN 'Information' THEN 'INF'
        ELSE 'KRT'
END;

SELECT COUNT(*) + 1 INTO anzahl
FROM Karte WHERE KartenTyp = p_KartenTyp;

SET p_KartenCode = CONCAT(prefix, ':', LPAD(anzahl, 3, '0'));
END$$
DELIMITER ;

-- Szenario löschen (US 1.6.1 - Task 11)
DELIMITER $$
CREATE PROCEDURE SP_SzenarioLoeschen(
    IN p_SzenarioId INT
)
BEGIN
    DECLARE aktuellerStatus VARCHAR(20);

SELECT Status INTO aktuellerStatus
FROM Szenario WHERE SzenarioId = p_SzenarioId;

IF aktuellerStatus = 'Aktiv' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aktive Szenarien können nicht gelöscht werden!';
ELSE
DELETE FROM Szenario WHERE SzenarioId = p_SzenarioId;
END IF;
END$$
DELIMITER ;

-- Szenario veröffentlichen (US 1.6.1 - Task ST-99)
DELIMITER $$
CREATE PROCEDURE SP_SzenarioVeroeffentlichen(
    IN p_SzenarioId INT
)
BEGIN
UPDATE Szenario
SET Status = 'Aktiv'
WHERE SzenarioId = p_SzenarioId
  AND Status = 'Entwurf';
END$$
DELIMITER ;

-- Aktive Szenarien prüfen
DELIMITER $$
CREATE PROCEDURE SP_AktiveSzenarienPruefen()
BEGIN
    DECLARE anzahlAktiv INT;

SELECT COUNT(*) INTO anzahlAktiv
FROM Szenario WHERE Status = 'Aktiv';

IF anzahlAktiv = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mindestens 1 aktives Szenario muss vorhanden sein!';
END IF;
END$$
DELIMITER ;

-- Option wählen
DELIMITER $$
CREATE PROCEDURE SP_OptionWaehlen(
    IN p_SessionId  INT,
    IN p_SpielerId  INT,
    IN p_KarteId    INT,
    IN p_OptionId   INT
)
BEGIN
    DECLARE istRichtig     TINYINT(1);
    DECLARE punkte         INT;
    DECLARE aktuellePunkte INT;

SELECT IstRichtig, Punkte
INTO istRichtig, punkte
FROM `Option`
WHERE OptionId = p_OptionId;

INSERT INTO Spielverlauf
(SessionId, KarteId, OptionId, SpielerId, ErhaltePunkte)
VALUES
    (p_SessionId, p_KarteId, p_OptionId, p_SpielerId,
     CASE WHEN istRichtig = 1 THEN punkte ELSE 0 END);

IF istRichtig = 1 THEN
UPDATE SessionSpieler
SET Punkte = Punkte + punkte
WHERE SessionId = p_SessionId
  AND SpielerId = p_SpielerId;
END IF;

INSERT INTO Protokoll
(SessionId, BenutzerId, Aktion, Details)
VALUES
    (p_SessionId, p_SpielerId, 'OptionGewaehlt',
     CONCAT('KarteId:', p_KarteId,
            ' OptionId:', p_OptionId,
            ' Richtig:', istRichtig,
            ' Punkte:', CASE WHEN istRichtig = 1 THEN punkte ELSE 0 END));

SELECT
    istRichtig      AS IstRichtig,
    CASE WHEN istRichtig = 1 THEN punkte ELSE 0 END AS ErhaltePunkte,
    ss.Punkte       AS GesamtPunkte
FROM SessionSpieler ss
WHERE ss.SessionId = p_SessionId
  AND ss.SpielerId = p_SpielerId;
END$$
DELIMITER ;

-- Phasen Fortschritt (Sprint 4 - Task 3)
DELIMITER $$
CREATE PROCEDURE SP_PhasenFortschritt(
    IN  p_SessionId          INT,
    IN  p_SpielerId          INT,
    OUT p_AktuellePhase      INT,
    OUT p_GesamtPhasen       INT,
    OUT p_GespielteKarten    INT,
    OUT p_GesamtKarten       INT,
    OUT p_FortschrittProzent DECIMAL(5,2),
    OUT p_AktuellePunkte     INT
)
BEGIN
SELECT COALESCE(MAX(p.Reihenfolge), 1) INTO p_AktuellePhase
FROM Spielverlauf sv
         JOIN Karte k ON sv.KarteId = k.KarteId
         JOIN Phase p ON k.PhaseId  = p.PhaseId
WHERE sv.SessionId = p_SessionId
  AND sv.SpielerId = p_SpielerId;

SELECT COUNT(DISTINCT p.PhaseId) INTO p_GesamtPhasen
FROM Session s
         JOIN Phase p ON s.SzenarioId = p.SzenarioId
WHERE s.SessionId = p_SessionId;

SELECT COUNT(DISTINCT sv.KarteId) INTO p_GespielteKarten
FROM Spielverlauf sv
WHERE sv.SessionId = p_SessionId
  AND sv.SpielerId = p_SpielerId;

SELECT COUNT(DISTINCT k.KarteId) INTO p_GesamtKarten
FROM Session s
         JOIN Phase p ON s.SzenarioId = p.SzenarioId
         JOIN Karte k ON p.PhaseId    = k.PhaseId
WHERE s.SessionId = p_SessionId
  AND k.KartenTyp != 'Reaktion';

SET p_FortschrittProzent = ROUND(
        (p_GespielteKarten * 100.0) / NULLIF(p_GesamtKarten, 0), 2
    );

SELECT Punkte INTO p_AktuellePunkte
FROM SessionSpieler
WHERE SessionId = p_SessionId
  AND SpielerId = p_SpielerId;
END$$
DELIMITER ;

-- Erfolgs Punkte vergeben
DELIMITER $$
CREATE PROCEDURE SP_ErfolgsPunkteVergeben(
    IN p_SessionId  INT,
    IN p_SpielerId  INT,
    IN p_Punkte     INT
)
BEGIN
UPDATE SessionSpieler
SET Punkte = Punkte + p_Punkte
WHERE SessionId = p_SessionId
  AND SpielerId = p_SpielerId;

UPDATE Statstik
SET GesamtPunkte   = GesamtPunkte + p_Punkte,
    BestePunktzahl = GREATEST(BestePunktzahl, GesamtPunkte + p_Punkte)
WHERE BenutzerId = p_SpielerId;

INSERT INTO Protokoll
(SessionId, BenutzerId, Aktion, Details)
VALUES
    (p_SessionId, p_SpielerId, 'PunktErhalten',
     CONCAT('+', p_Punkte, ' Punkte (Richtige Antwort - Erfolgsfeedback)'));

SELECT
    ss.Punkte   AS GesamtPunkte,
    p_Punkte    AS ErhaltePunkte
FROM SessionSpieler ss
WHERE ss.SessionId = p_SessionId
  AND ss.SpielerId = p_SpielerId;
END$$
DELIMITER ;

-- Rolle Szenario zuordnen
DELIMITER $$
CREATE PROCEDURE SP_RolleSzenarioZuordnen(
    IN p_RolleId    INT,
    IN p_SzenarioId INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM SzenarioRolle
        WHERE RolleId = p_RolleId AND SzenarioId = p_SzenarioId
    ) THEN
        INSERT INTO SzenarioRolle (SzenarioId, RolleId)
        VALUES (p_SzenarioId, p_RolleId);
END IF;
END$$
DELIMITER ;

-- Rolle vergeben (US 2.3.1 - Task 13)
DELIMITER $$
CREATE PROCEDURE SP_RolleVergeben(
    IN p_SessionId INT,
    IN p_SpielerId INT,
    IN p_RolleId   INT
)
BEGIN
    DECLARE rolleVergeben INT;

SELECT COUNT(*) INTO rolleVergeben
FROM SessionSpieler
WHERE SessionId = p_SessionId AND RolleId = p_RolleId;

IF rolleVergeben > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Diese Rolle ist bereits vergeben!';
ELSE
UPDATE SessionSpieler
SET RolleId = p_RolleId
WHERE SessionId = p_SessionId AND SpielerId = p_SpielerId;
END IF;
END$$
DELIMITER ;
-- ****************Trigger***************
-- TRG_MinEineRichtigeOption (US 1.2.1 - Task 14)
DELIMITER $$
CREATE TRIGGER TRG_MinEineRichtigeOption
    AFTER INSERT ON `Option`
    FOR EACH ROW
BEGIN
    DECLARE anzahlRichtig INT;
    SELECT COUNT(*) INTO anzahlRichtig
    FROM `Option`
    WHERE KarteId = NEW.KarteId AND IstRichtig = 1;

    IF anzahlRichtig = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mindestens eine Option muss korrekt sein!';
END IF;
END$$
DELIMITER ;
-- TRG_ReaktionKeineOptionen (US 1.2.2 - Task 15)
DELIMITER $$
CREATE TRIGGER TRG_ReaktionKeineOptionen
    BEFORE INSERT ON `Option`
    FOR EACH ROW
BEGIN
    DECLARE kartenTyp VARCHAR(20);
    SELECT KartenTyp INTO kartenTyp
    FROM Karte WHERE KarteId = NEW.KarteId;

    IF kartenTyp = 'Reaktion' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reaktion-Karten dürfen keine Optionen haben!';
END IF;
END$$
DELIMITER ;
-- TRG_Phase_StartEndKarte (US 1.3.1 - Task 16)
DELIMITER $$
CREATE TRIGGER TRG_Phase_StartEndKarte
    BEFORE INSERT ON Phase
    FOR EACH ROW
BEGIN
    IF NEW.StartKarteId = NEW.EndKarteId
    AND NEW.StartKarteId IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Start-Karte und End-Karte müssen verschieden sein!';
END IF;
END$$
DELIMITER ;
-- TRG_Phase_Reihenfolge (US 1.3.1 - Task 17)
DELIMITER $$
CREATE TRIGGER TRG_Phase_Reihenfolge
    BEFORE INSERT ON Phase
    FOR EACH ROW
BEGIN
    DECLARE maxReihenfolge INT;

    SELECT COALESCE(MAX(Reihenfolge), 0) INTO maxReihenfolge
    FROM Phase WHERE SzenarioId = NEW.SzenarioId;

    IF NEW.Reihenfolge != maxReihenfolge + 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phasen-Reihenfolge darf keine Lücken haben!';
END IF;
END$$
DELIMITER ;
-- TRG_Rollen_MinFuenf (US 1.4.1 - Task 18)
DELIMITER $$
CREATE TRIGGER TRG_Rollen_MinFuenf
    BEFORE DELETE ON Rollen
    FOR EACH ROW
BEGIN
    DECLARE anzahlRollen INT;
    SELECT COUNT(*) INTO anzahlRollen FROM Rollen;

    IF anzahlRollen <= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mindestens 5 Standard-Rollen müssen vorhanden sein!';
END IF;
END$$
DELIMITER ;

DELIMITER $$
-- KeineDoppleteEntscheidung Task 4 Sprint 4 
CREATE TRIGGER TRG_KeineDoppelteEntscheidung
    BEFORE INSERT ON Spielverlauf
    FOR EACH ROW
BEGIN
    DECLARE bereitsGespielt INT;

    SELECT COUNT(*) INTO bereitsGespielt
    FROM Spielverlauf
    WHERE SessionId = NEW.SessionId
      AND SpielerId = NEW.SpielerId
      AND KarteId   = NEW.KarteId;

    IF bereitsGespielt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Diese Karte wurde bereits gespielt — keine Zurück-Möglichkeit!';
END IF;
END$$
DELIMITER ;
