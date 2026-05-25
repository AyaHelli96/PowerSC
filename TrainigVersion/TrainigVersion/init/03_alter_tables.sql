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
