USE cyberspace_nis2;
 
-- =====================================
-- TABELLEN ANPASSEN
-- =====================================
-- Alle Spalten und Constraints sind bereits ,aber das bleibt für zukünftige Änderungen !
-- Szenario Versionierung (US 1.1.2)
CREATE TABLE SzenarioVersion (
                                 VersionId        INT PRIMARY KEY AUTO_INCREMENT,
                                 SzenarioId       INT NOT NULL,
                                 VersionNummer    INT NOT NULL,
                                 Titel            VARCHAR(100) NOT NULL,
                                 Beschreibung     TEXT NULL,
                                 Schwierigkeit    ENUM('Leicht','Mittel','Schwer') NOT NULL,
                                 Status           ENUM('Entwurf','Aktiv','Archiviert') NOT NULL,
                                 GeaendertVon     INT NOT NULL COMMENT 'BenutzerID des Bearbeiters',
                                 GeaendertAm      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 Aenderungsgrund  VARCHAR(200) NULL COMMENT 'Optional: Warum wurde geändert',
                                 FOREIGN KEY (SzenarioId) REFERENCES Szenario(SzenarioId) ON DELETE CASCADE,
                                 FOREIGN KEY (GeaendertVon) REFERENCES Benutzer(BenutzerID)
) COMMENT = 'Speichert alle Versionen eines Szenarios für Änderungshistorie';

-- Import Log (US 1.5.1)
CREATE TABLE ImportLog (
                           ImportId         INT PRIMARY KEY AUTO_INCREMENT,
                           SzenarioId       INT NULL COMMENT 'NULL wenn Import fehlgeschlagen',
                           ImportiertVon    INT NOT NULL COMMENT 'Admin BenutzerID',
                           ImportZeitpunkt  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           DateiName        VARCHAR(255) NOT NULL,
                           AnzahlKarten     INT DEFAULT 0,
                           AnzahlPhasen     INT DEFAULT 0,
                           AnzahlRollen     INT DEFAULT 0,
                           Status           ENUM('Erfolgreich','Fehlgeschlagen') NOT NULL,
                           Fehlermeldung    TEXT NULL COMMENT 'Bei Fehler: Details',
                           FOREIGN KEY (SzenarioId) REFERENCES Szenario(SzenarioId) ON DELETE SET NULL,
                           FOREIGN KEY (ImportiertVon) REFERENCES Benutzer(BenutzerID)
) COMMENT = 'Speichert alle Import-Vorgänge für Nachvollziehbarkeit';

-- Export Log (US 1.5.2)
CREATE TABLE ExportLog (
                           ExportId         INT PRIMARY KEY AUTO_INCREMENT,
                           SzenarioId       INT NOT NULL,
                           ExportiertVon    INT NOT NULL COMMENT 'Admin BenutzerID',
                           ExportZeitpunkt  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           DateiName        VARCHAR(255) NOT NULL,
                           FOREIGN KEY (SzenarioId) REFERENCES Szenario(SzenarioId) ON DELETE CASCADE,
                           FOREIGN KEY (ExportiertVon) REFERENCES Benutzer(BenutzerID)
) COMMENT = 'Speichert alle Export-Vorgänge für Nachvollziehbarkeit und Backup-Tracking';

