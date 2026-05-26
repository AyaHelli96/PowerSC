CREATE DATABASE IF NOT EXISTS cyberspace_nis2
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
 
USE cyberspace_nis2;
 
-- =====================================
-- TABELLEN
-- =====================================

CREATE TABLE Benutzer (
                          BenutzerId          INT          NOT NULL AUTO_INCREMENT,
                          Benutzername        VARCHAR(50)  NOT NULL,
                          Email               VARCHAR(255) NOT NULL,
                          PasswortHash        VARCHAR(60)  NOT NULL,
                          Rolle               ENUM('Spieler','Moderator','Admin') NOT NULL,
                          ErstelltAm          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          FehlgeschlagenLogin INT          NOT NULL DEFAULT 0,
                          GesperrtBis         DATETIME     NULL,
                          Punkte              INT          NULL,
                          Abzeichen           VARCHAR(100) NULL,
                          Abteilung           VARCHAR(100) NULL,
                          PRIMARY KEY (BenutzerId),
                          UNIQUE KEY UQ_Benutzer_Email (Email)
);

CREATE TABLE Szenario (
                          SzenarioId         INT          NOT NULL AUTO_INCREMENT,
                          Titel              VARCHAR(100) NOT NULL,
                          Beschreibung       TEXT         NULL,
                          SchwierigkeitsGrad ENUM('Einfach','Mittel','Schwer') NOT NULL,
                          Zielgruppe         ENUM('Führungskräfte','IT-Personal','Alle') NOT NULL,
                          Status             ENUM('Entwurf','Aktiv','Archiviert') NOT NULL DEFAULT 'Entwurf',
                          MinSpieler         INT          NOT NULL DEFAULT 2,
                          MaxSpieler         INT          NOT NULL DEFAULT 6,
                          MinPunkte          INT          NOT NULL DEFAULT 0,
                          ErstelltAm         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          ErstelltVon        INT          NOT NULL,
                          Nis2Artikel        VARCHAR(50)  NULL,
                          DauerMinuten       INT          NOT NULL DEFAULT 30,
                          AnzahlPhasen       INT          NOT NULL DEFAULT 1,
                          PRIMARY KEY (SzenarioId),
                          CONSTRAINT CHK_Szenario_Dauer  CHECK (DauerMinuten BETWEEN 15 AND 120),
                          CONSTRAINT CHK_Szenario_Phasen CHECK (AnzahlPhasen BETWEEN 1 AND 10)
);

CREATE TABLE Rollen (
                        RolleId     INT          NOT NULL AUTO_INCREMENT,
                        Name        VARCHAR(50)  NOT NULL,
                        Beschreibung VARCHAR(200) NULL,
                        Farbe       VARCHAR(20)  NULL,
                        FarbeHex    VARCHAR(7)   NULL,
                        PRIMARY KEY (RolleId),
                        UNIQUE KEY UQ_Rollen_Name (Name),
                        CONSTRAINT CHK_Rollen_Farbe CHECK (Farbe IN ('Grau','Blau','Rot','Gruen','Lila'))
);

CREATE TABLE Statstik (
                          StatstikId      INT      NOT NULL AUTO_INCREMENT,
                          BenutzerId      INT      NOT NULL,
                          GespielteSpiele INT      NOT NULL DEFAULT 0,
                          GesamtPunkte    INT      NOT NULL DEFAULT 0,
                          BestePunktzahl  INT      NOT NULL DEFAULT 0,
                          ErstelltAm      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          AnzahlSiege       INT      NOT NULL DEFAULT 0,    
                          ComplianceProzent DECIMAL(5,2) NULL,              
                          LetzterSieg       DATETIME NULL,
                          AnzahlVersuche    INT          NOT NULL DEFAULT 0,  
                          AnzahlSackgassen  INT          NOT NULL DEFAULT 0,  
                          LetzterVersuch    DATETIME     NULL,                
                          PRIMARY KEY (StatstikId)
);

CREATE TABLE Phase (
                       PhaseId      INT          NOT NULL AUTO_INCREMENT,
                       SzenarioId   INT          NOT NULL,
                       Titel        VARCHAR(100) NOT NULL,
                       Beschreibung VARCHAR(200) NULL,
                       Reihenfolge  INT          NOT NULL DEFAULT 1,
                       ZeitlimitSek INT          NULL,
                       StartKarteId INT          NULL,
                       EndKarteId   INT          NULL,
                       MinPunkte    INT          NOT NULL DEFAULT 1,
                       PRIMARY KEY (PhaseId),
                       CONSTRAINT CHK_Phase_Nummer    CHECK (Reihenfolge BETWEEN 1 AND 5),
                       CONSTRAINT CHK_Phase_MinPunkte CHECK (MinPunkte > 0)
);

CREATE TABLE SzenarioRolle (
                               SzenarioId INT NOT NULL,
                               RolleId    INT NOT NULL,
                               PRIMARY KEY (SzenarioId, RolleId)
);

CREATE TABLE Session (
                         SessionID        INT          PRIMARY KEY AUTO_INCREMENT,
                         SzenarioID       INT          NOT NULL,
                         ModeratorID      INT          NOT NULL,
                         SessionName      VARCHAR(100) NOT NULL COMMENT 'Name der Session',
                         Status           ENUM('Warten','Aktiv','Pausiert','Beendet') NOT NULL DEFAULT 'Warten',
                         AktuellePhase    INT          DEFAULT 1,
                         Startzeit        DATETIME     NULL,
                         Endzeit          DATETIME     NULL,
                         ErstelltAm       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         BeendigungsGrund VARCHAR(200) NULL,
                         PausierZeit      DATETIME     NULL COMMENT 'Wann wurde pausiert',
                         PausierGrund     VARCHAR(200) NULL COMMENT 'Optionaler Grund',
                         FortsetzungsZeit DATETIME     NULL COMMENT 'Wann wurde fortgesetzt'
) COMMENT = 'Laufende Spielsessions';

CREATE TABLE Karte (
                       KarteId      INT          NOT NULL AUTO_INCREMENT,
                       PhaseId      INT          NOT NULL,
                       Titel        VARCHAR(80)  NOT NULL,
                       Inhalt       VARCHAR(300) NULL,
                       KartenTyp    ENUM('Aktion','Ereignis','Reaktion','Information') NOT NULL,
                       Punkte       INT          NOT NULL DEFAULT 0,
                       Reihenfolge  INT          NOT NULL DEFAULT 1,
                       KartenCode   VARCHAR(10)  NULL,
                       ReaktionsTyp ENUM('PositiverSchritt','NegativerSchritt','Wiederherstellung','Sackgasse') NULL,
                       AktioKarteId INT          NULL,
                       Nis2Artikel  VARCHAR(50)  NULL,
                       PRIMARY KEY (KarteId),
                       UNIQUE KEY UQ_Karte_KartenCode (KartenCode),
                       CONSTRAINT CHK_Karte_ReaktionsPunkte CHECK (
                           KartenTyp != 'Reaktion' OR Punkte IN (50, -30, 20, -50)
)
    );

CREATE TABLE SessionSpieler (
                                SessionId     INT      NOT NULL,
                                SpielerId     INT      NOT NULL,
                                RolleId       INT      NULL,
                                Status        ENUM('Eingeladen','Aktiv','Inaktiv','Ausgeschieden') NOT NULL DEFAULT 'Eingeladen',
                                Punkte        INT      NOT NULL DEFAULT 0,
                                BeigetretenAm DATETIME NULL,
                                PRIMARY KEY (SessionId, SpielerId)
);

CREATE TABLE Einladung (
                           EinladungId  INT      NOT NULL AUTO_INCREMENT,
                           SessionId    INT      NOT NULL,
                           EingeladenVon INT     NOT NULL,
                           EingeladenAn INT      NOT NULL,
                           Status       ENUM('Ausstehend','Angenommen','Abgelehnt') NOT NULL DEFAULT 'Ausstehend',
                           ErstelltAm   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           PRIMARY KEY (EinladungId)
);

CREATE TABLE `Option` (
                          OptionId   INT          NOT NULL AUTO_INCREMENT,
                          KarteId    INT          NOT NULL,
                          Text       VARCHAR(100) NOT NULL,
                          IstRichtig TINYINT(1)   NOT NULL DEFAULT 0,
                          Punkte     INT          NOT NULL DEFAULT 0,
                          PRIMARY KEY (OptionId)
);

CREATE TABLE Protokoll (
                           ProtokollId INT      NOT NULL AUTO_INCREMENT,
                           SessionId   INT      NOT NULL,
                           BenutzerId  INT      NOT NULL,
                           Aktion      ENUM(
        'Beigetreten',
        'Verlassen',
        'KarteGezogen',
        'OptionGewaehlt',
        'PunktErhalten',
        'Gesperrt',
        'SessionPausiert',
        'SessionFortgesetzt'
    ) NOT NULL,
                           Zeitstempel DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           Details     TEXT     NULL,
                           PRIMARY KEY (ProtokollId)
);

CREATE TABLE Spielverlauf (
                              SpieverlaufId INT      NOT NULL AUTO_INCREMENT,
                              SessionId     INT      NOT NULL,
                              KarteId       INT      NOT NULL,
                              OptionId      INT      NULL,
                              SpielerId     INT      NOT NULL,
                              Zeitstempel   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              ErhaltePunkte INT      NOT NULL DEFAULT 0,
                              PRIMARY KEY (SpieverlaufId)
);
 