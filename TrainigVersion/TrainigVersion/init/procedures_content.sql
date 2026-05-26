USE cyberspace_nis2;
 
-- =====================================
-- STORED PROCEDURES
-- =====================================

-- Neuen Spieler registrieren
    
    DELIMITER //

          
CREATE PROCEDURE SP_SpielerRegistrieren(
    IN p_Benutzername VARCHAR(50),
    IN p_Email        VARCHAR(255),
    IN p_PasswortHash VARCHAR(255)
)
BEGIN
INSERT INTO Benutzer (Benutzername, Email, PasswortHash, Rolle, FehlgeschlagenLogin, Punkte)
VALUES (p_Benutzername, p_Email, p_PasswortHash, 'Spieler', 0, 0);
END //

-- Session starten (US 2.2.3 - ST-3)
CREATE PROCEDURE SP_SessionStarten(
    IN p_SessionId INT
)
BEGIN
    -- Neue Session starten (Warten → Aktiv)
    IF (SELECT Status FROM Session WHERE SessionID = p_SessionId) = 'Warten' THEN
UPDATE Session
SET Status    = 'Aktiv',
    Startzeit = CURRENT_TIMESTAMP
WHERE SessionID = p_SessionId;

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
SELECT p_SessionId, ModeratorID, 'SessionFortgesetzt', 'Session neu gestartet'
FROM Session WHERE SessionID = p_SessionId;

-- Pausierte Session fortsetzen (Pausiert → Aktiv)
ELSEIF (SELECT Status FROM Session WHERE SessionID = p_SessionId) = 'Pausiert' THEN
UPDATE Session
SET Status           = 'Aktiv',
    FortsetzungsZeit = CURRENT_TIMESTAMP,
    PausierZeit      = NULL,
    PausierGrund     = NULL
WHERE SessionID = p_SessionId;

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
SELECT p_SessionId, ModeratorID, 'SessionFortgesetzt', 'Session fortgesetzt'
FROM Session WHERE SessionID = p_SessionId;
END IF;
 
    -- Ergebnis zurückgeben
SELECT SessionID, Status, Startzeit, FortsetzungsZeit
FROM Session WHERE SessionID = p_SessionId;
END //

-- Session beenden (US 2.2.2 - ST-2)
CREATE PROCEDURE SP_SessionBeenden(
    IN p_SessionId INT,
    IN p_Grund     VARCHAR(200)
)
BEGIN
UPDATE Session
SET Status           = 'Beendet',
    Endzeit          = CURRENT_TIMESTAMP,
    BeendigungsGrund = p_Grund
WHERE SessionID = p_SessionId;

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
SELECT p_SessionId, ModeratorID, 'SessionPausiert',
       CONCAT('Session beendet. Grund: ', COALESCE(p_Grund, 'kein Grund'))
FROM Session WHERE SessionID = p_SessionId;

SELECT SessionID, Status, Endzeit, BeendigungsGrund
FROM Session WHERE SessionID = p_SessionId;
END //

-- Session pausieren (US 2.2.1 - ST-2)
CREATE PROCEDURE SP_SessionPausieren(
    IN p_SessionId INT,
    IN p_Grund     VARCHAR(200)
)
BEGIN
UPDATE Session
SET Status       = 'Pausiert',
    PausierZeit  = CURRENT_TIMESTAMP,
    PausierGrund = p_Grund
WHERE SessionID = p_SessionId
  AND Status = 'Aktiv';

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
SELECT p_SessionId, ModeratorID, 'SessionPausiert',
       CONCAT('Session pausiert. Grund: ', COALESCE(p_Grund, 'kein Grund'))
FROM Session WHERE SessionID = p_SessionId;
END //

-- Session fortsetzen (US 2.2.3 - ST-3)
CREATE PROCEDURE SP_SessionFortsetzen(
    IN p_SessionId INT
)
BEGIN
UPDATE Session
SET Status           = 'Aktiv',
    FortsetzungsZeit = CURRENT_TIMESTAMP,
    PausierZeit      = NULL,
    PausierGrund     = NULL
WHERE SessionID = p_SessionId
  AND Status = 'Pausiert';

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
SELECT p_SessionId, ModeratorID, 'SessionFortgesetzt', 'Session fortgesetzt'
FROM Session WHERE SessionID = p_SessionId;
END //

-- Protokoll Daten abrufen (US 2.1.1 - ST-4)
CREATE PROCEDURE SP_ProtokollDaten(
    IN p_SessionId INT
)
BEGIN
SELECT
    p.ProtokollId,
    p.Zeitstempel,
    p.Aktion,
    p.Details,
    b.Benutzername AS Benutzer,
    b.Rolle
FROM Protokoll p
         JOIN Benutzer b ON p.BenutzerId = b.BenutzerId
WHERE p.SessionId = p_SessionId
ORDER BY p.Zeitstempel ASC;
END //

-- Spieler zu Session hinzufügen
CREATE PROCEDURE SP_SpielerHinzufuegen(
    IN p_SessionId INT,
    IN p_SpielerId INT
)
BEGIN
INSERT INTO SessionSpieler (SessionId, SpielerId, Status, Punkte)
VALUES (p_SessionId, p_SpielerId, 'Aktiv', 0);

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion)
VALUES (p_SessionId, p_SpielerId, 'Beigetreten');
END //

-- Punkte vergeben
CREATE PROCEDURE SP_PunkteVergeben(
    IN p_SessionId INT,
    IN p_SpielerId INT,
    IN p_Punkte    INT
)
BEGIN
UPDATE SessionSpieler
SET Punkte = Punkte + p_Punkte
WHERE SessionId = p_SessionId AND SpielerId = p_SpielerId;

UPDATE Statstik
SET GesamtPunkte = GesamtPunkte + p_Punkte
WHERE BenutzerId = p_SpielerId;

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
VALUES (p_SessionId, p_SpielerId, 'PunktErhalten',
        CONCAT('Punkte erhalten: ', p_Punkte));
END //

-- Login Versuch (US 0.2.1)
CREATE PROCEDURE SP_LoginVersuch(
    IN p_Email  VARCHAR(255),
    IN p_Erfolg TINYINT(1)
)
BEGIN
    IF p_Erfolg = 1 THEN
UPDATE Benutzer SET FehlgeschlagenLogin = 0, GesperrtBis = NULL
WHERE Email = p_Email;
ELSE
UPDATE Benutzer SET FehlgeschlagenLogin = FehlgeschlagenLogin + 1
WHERE Email = p_Email;

UPDATE Benutzer SET GesperrtBis = DATE_ADD(NOW(), INTERVAL 5 MINUTE)
WHERE Email = p_Email AND FehlgeschlagenLogin >= 3;
END IF;
END //

-- Karten Code generieren (US 1.2.1)
CREATE PROCEDURE SP_KartenCodeGenerieren(
    IN  p_KartenTyp  VARCHAR(20),
    OUT p_KartenCode VARCHAR(10)
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

SELECT COUNT(*) + 1 INTO anzahl FROM Karte WHERE KartenTyp = p_KartenTyp;
SET p_KartenCode = CONCAT(prefix, ':', LPAD(anzahl, 3, '0'));
END //

-- Szenario löschen (US 1.6.1)
CREATE PROCEDURE SP_SzenarioLoeschen(
    IN p_SzenarioId INT
)
BEGIN
    DECLARE aktuellerStatus VARCHAR(20);
SELECT Status INTO aktuellerStatus FROM Szenario WHERE SzenarioId = p_SzenarioId;

IF aktuellerStatus = 'Aktiv' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aktive Szenarien können nicht gelöscht werden!';
ELSE
DELETE FROM Szenario WHERE SzenarioId = p_SzenarioId;
END IF;
END //

-- Szenario veröffentlichen (US 1.6.1)
CREATE PROCEDURE SP_SzenarioVeroeffentlichen(
    IN p_SzenarioId INT
)
BEGIN
UPDATE Szenario SET Status = 'Aktiv'
WHERE SzenarioId = p_SzenarioId AND Status = 'Entwurf';
END //

-- Aktive Szenarien prüfen
CREATE PROCEDURE SP_AktiveSzenarienPruefen()
BEGIN
    DECLARE anzahlAktiv INT;
SELECT COUNT(*) INTO anzahlAktiv FROM Szenario WHERE Status = 'Aktiv';

IF anzahlAktiv = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mindestens 1 aktives Szenario muss vorhanden sein!';
END IF;
END //

-- Option wählen
CREATE PROCEDURE SP_OptionWaehlen(
    IN p_SessionId INT,
    IN p_SpielerId INT,
    IN p_KarteId   INT,
    IN p_OptionId  INT
)
BEGIN
    DECLARE istRichtig TINYINT(1);
    DECLARE punkte     INT;

SELECT IstRichtig, Punkte INTO istRichtig, punkte
FROM `Option` WHERE OptionId = p_OptionId;

INSERT INTO Spielverlauf (SessionId, KarteId, OptionId, SpielerId, ErhaltePunkte)
VALUES (p_SessionId, p_KarteId, p_OptionId, p_SpielerId,
        CASE WHEN istRichtig = 1 THEN punkte ELSE 0 END);

IF istRichtig = 1 THEN
UPDATE SessionSpieler SET Punkte = Punkte + punkte
WHERE SessionId = p_SessionId AND SpielerId = p_SpielerId;
END IF;

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
VALUES (p_SessionId, p_SpielerId, 'OptionGewaehlt',
        CONCAT('KarteId:', p_KarteId, ' OptionId:', p_OptionId,
               ' Richtig:', istRichtig,
               ' Punkte:', CASE WHEN istRichtig = 1 THEN punkte ELSE 0 END));

SELECT istRichtig AS IstRichtig,
       CASE WHEN istRichtig = 1 THEN punkte ELSE 0 END AS ErhaltePunkte,
       ss.Punkte AS GesamtPunkte
FROM SessionSpieler ss
WHERE ss.SessionId = p_SessionId AND ss.SpielerId = p_SpielerId;
END //

-- Phasen Fortschritt (Sprint 4)
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
WHERE sv.SessionId = p_SessionId AND sv.SpielerId = p_SpielerId;

SELECT COUNT(DISTINCT p.PhaseId) INTO p_GesamtPhasen
FROM Session s JOIN Phase p ON s.SzenarioID = p.SzenarioId
WHERE s.SessionID = p_SessionId;

SELECT COUNT(DISTINCT sv.KarteId) INTO p_GespielteKarten
FROM Spielverlauf sv
WHERE sv.SessionId = p_SessionId AND sv.SpielerId = p_SpielerId;

SELECT COUNT(DISTINCT k.KarteId) INTO p_GesamtKarten
FROM Session s
         JOIN Phase p ON s.SzenarioID = p.SzenarioId
         JOIN Karte k ON p.PhaseId    = k.PhaseId
WHERE s.SessionID = p_SessionId AND k.KartenTyp != 'Reaktion';

SET p_FortschrittProzent = ROUND(
        (p_GespielteKarten * 100.0) / NULLIF(p_GesamtKarten, 0), 2);

SELECT Punkte INTO p_AktuellePunkte
FROM SessionSpieler WHERE SessionId = p_SessionId AND SpielerId = p_SpielerId;
END //

-- Erfolgs Punkte vergeben
CREATE PROCEDURE SP_ErfolgsPunkteVergeben(
    IN p_SessionId INT,
    IN p_SpielerId INT,
    IN p_Punkte    INT
)
BEGIN
UPDATE SessionSpieler SET Punkte = Punkte + p_Punkte
WHERE SessionId = p_SessionId AND SpielerId = p_SpielerId;

UPDATE Statstik
SET GesamtPunkte   = GesamtPunkte + p_Punkte,
    BestePunktzahl = GREATEST(BestePunktzahl, GesamtPunkte + p_Punkte)
WHERE BenutzerId = p_SpielerId;

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
VALUES (p_SessionId, p_SpielerId, 'PunktErhalten',
        CONCAT('+', p_Punkte, ' Punkte (Richtige Antwort - Erfolgsfeedback)'));

SELECT ss.Punkte AS GesamtPunkte, p_Punkte AS ErhaltePunkte
FROM SessionSpieler ss
WHERE ss.SessionId = p_SessionId AND ss.SpielerId = p_SpielerId;
END //

-- Rolle Szenario zuordnen
CREATE PROCEDURE SP_RolleSzenarioZuordnen(
    IN p_RolleId    INT,
    IN p_SzenarioId INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM SzenarioRolle
        WHERE RolleId = p_RolleId AND SzenarioId = p_SzenarioId
    ) THEN
        INSERT INTO SzenarioRolle (SzenarioId, RolleId) VALUES (p_SzenarioId, p_RolleId);
END IF;
END //

-- Rolle vergeben (US 2.3.1)
CREATE PROCEDURE SP_RolleVergeben(
    IN p_SessionId INT,
    IN p_SpielerId INT,
    IN p_RolleId   INT
)
BEGIN
    DECLARE rolleVergeben INT;

SELECT COUNT(*) INTO rolleVergeben
FROM SessionSpieler WHERE SessionId = p_SessionId AND RolleId = p_RolleId;

IF rolleVergeben > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Diese Rolle ist bereits vergeben!';
ELSE
UPDATE SessionSpieler SET RolleId = p_RolleId
WHERE SessionId = p_SessionId AND SpielerId = p_SpielerId;
END IF;
END //

-- Session Recovery (US 2.2.2 - ST-4)
CREATE PROCEDURE SP_SessionRecovery(
    IN p_SessionId INT
)
BEGIN
    -- Session Basis-Daten
SELECT
    s.SessionID,
    s.SessionName,
    s.Status,
    s.AktuellePhase,
    s.Startzeit,
    s.Endzeit,
    s.BeendigungsGrund,
    sz.Titel         AS SzenarioTitel,
    b.Benutzername   AS Moderator
FROM Session s
         JOIN Szenario sz ON s.SzenarioID  = sz.SzenarioId
         JOIN Benutzer b  ON s.ModeratorID = b.BenutzerId
WHERE s.SessionID = p_SessionId;

-- Spieler und ihre Punkte
SELECT
    b.Benutzername  AS Spieler,
    ss.Punkte,
    ss.Status,
    r.Name          AS Rolle
FROM SessionSpieler ss
         JOIN Benutzer b      ON ss.SpielerId = b.BenutzerId
         LEFT JOIN Rollen r   ON ss.RolleId   = r.RolleId
WHERE ss.SessionId = p_SessionId;

-- Gespielter Verlauf
SELECT
    k.Titel          AS Karte,
    o.Text           AS GewaehlteOption,
    o.IstRichtig,
    sv.ErhaltePunkte,
    sv.Zeitstempel
FROM Spielverlauf sv
         JOIN Karte k         ON sv.KarteId  = k.KarteId
         LEFT JOIN `Option` o ON sv.OptionId = o.OptionId
WHERE sv.SessionId = p_SessionId
ORDER BY sv.Zeitstempel ASC;
END //




-- Victory Berechnen (US 3.3.1 - ST-2)
CREATE PROCEDURE SP_VictoryBerechnen(
    IN  p_SessionId  INT,
    IN  p_SpielerId  INT,
    OUT p_IstSieg    TINYINT(1),
    OUT p_Compliance DECIMAL(5,2)
        )
BEGIN
    DECLARE erreichterPunkte INT;
    DECLARE maxPunkte        INT;
    DECLARE schwellwert      DECIMAL(5,2);
 
    -- Erreichte Punkte des Spielers
SELECT COALESCE(SUM(ss.Punkte), 0) INTO erreichterPunkte
FROM SessionSpieler ss
WHERE ss.SessionId = p_SessionId
  AND ss.SpielerId = p_SpielerId;

-- Max mögliche Punkte des Szenarios
SELECT COALESCE(SUM(k.Punkte), 0) INTO maxPunkte
FROM Session s
         JOIN Phase p ON s.SzenarioID = p.SzenarioId
         JOIN Karte k ON p.PhaseId    = k.PhaseId
WHERE s.SessionID = p_SessionId
  AND k.KartenTyp != 'Reaktion';

-- Compliance berechnen
SET p_Compliance = ROUND(
        (erreichterPunkte * 100.0) / NULLIF(maxPunkte, 0), 2
    );
 
    -- Sieg wenn >= 70%
    SET p_IstSieg = CASE WHEN p_Compliance >= 70 THEN 1 ELSE 0 END;
 
    -- Statistik aktualisieren
    IF p_IstSieg = 1 THEN
UPDATE Statstik
SET AnzahlSiege       = AnzahlSiege + 1,
    ComplianceProzent = p_Compliance,
    LetzterSieg       = CURRENT_TIMESTAMP,
    BestePunktzahl    = GREATEST(BestePunktzahl, erreichterPunkte)
WHERE BenutzerId = p_SpielerId;
END IF;
 
    -- Ergebnis zurückgeben
SELECT
    p_IstSieg           AS IstSieg,
    erreichterPunkte    AS ErreichtePunkte,
    maxPunkte           AS MaxPunkte,
    p_Compliance        AS ComplianceProzent;
END //

CREATE PROCEDURE SP_GameOverVerarbeiten(
    IN p_SessionId INT,
    IN p_SpielerId INT,
    IN p_Grund VARCHAR(50)
)
BEGIN
    DECLARE v_AktuellePunkte INT;
    DECLARE v_ComplianceProzent DECIMAL(5,2);
    
    -- 1. Hole aktuelle Punktzahl des Spielers aus der Session
SELECT Punkte INTO v_AktuellePunkte
FROM SessionSpieler
WHERE SessionId = p_SessionId AND SpielerId = p_SpielerId;

-- 2. Berechne Compliance-Prozentsatz (max 1000 Punkte = 100%)
SET v_ComplianceProzent = (v_AktuellePunkte / 1000.0) * 100;
    
    -- 3. Update Statistiken
UPDATE Statstik
SET AnzahlVersuche = AnzahlVersuche + 1,
    LetzterVersuch = NOW(),
    ComplianceProzent = v_ComplianceProzent,
    GesamtPunkte = GesamtPunkte + v_AktuellePunkte,
    GespielteSpiele = GespielteSpiele + 1,
    -- Update BestePunktzahl falls neue Punktzahl höher ist
    BestePunktzahl = GREATEST(BestePunktzahl, v_AktuellePunkte)
WHERE BenutzerId = p_SpielerId;

-- 4. Setze Spieler-Status auf "Ausgeschieden"
UPDATE SessionSpieler
SET Status = 'Ausgeschieden'
WHERE SessionId = p_SessionId AND SpielerId = p_SpielerId;

-- 5. Logge Game Over Event im Protokoll
INSERT INTO Protokoll (SessionId, BenutzerId, Aktion, Details)
VALUES (
           p_SessionId,
           p_SpielerId,
           'Gesperrt',
           CONCAT('Game Over: ', p_Grund, ' | Punkte: ', v_AktuellePunkte, ' | Compliance: ', v_ComplianceProzent, '%')
       );

END //

-- Szenario bearbeiten (US 1.1.2 - ST-4)
CREATE PROCEDURE SP_SzenarioBearbeiten(
    IN p_SzenarioId     INT,
    IN p_Titel          VARCHAR(100),
    IN p_Beschreibung   TEXT,
    IN p_Schwierigkeit  ENUM('Leicht','Mittel','Schwer'),
    IN p_BearbeiterID   INT,
    IN p_Aenderungsgrund VARCHAR(200)
        )
BEGIN
    DECLARE aktuellerStatus VARCHAR(20);
    
    -- Status prüfen
SELECT Status INTO aktuellerStatus FROM Szenario WHERE SzenarioId = p_SzenarioId;

-- Warnung wenn aktiv (aber nicht blockieren)
IF aktuellerStatus = 'Aktiv' THEN
SELECT 'WARNUNG: Dieses Szenario ist aktiv und wird gerade verwendet!' AS Warnung;
END IF;
    
    -- Szenario aktualisieren (Trigger speichert automatisch alte Version)
UPDATE Szenario
SET Titel = p_Titel,
    Beschreibung = p_Beschreibung,
    Schwierigkeit = p_Schwierigkeit
WHERE SzenarioId = p_SzenarioId;

-- Aenderungsgrund in letzter Version speichern
UPDATE SzenarioVersion
SET Aenderungsgrund = p_Aenderungsgrund
WHERE SzenarioId = p_SzenarioId
    ORDER BY VersionNummer DESC 
    LIMIT 1;

-- Ergebnis zurückgeben
SELECT SzenarioId, Titel, Beschreibung, Schwierigkeit, Status
FROM Szenario WHERE SzenarioId = p_SzenarioId;
END //

-- Import vorbereiten (US 1.5.1 - ST-2)
CREATE PROCEDURE SP_ImportVorbereiten(
    IN p_BenutzerID INT,
    IN p_DateiName VARCHAR(255),
    OUT p_ImportId INT,
    OUT p_IstAdmin BOOLEAN
)
BEGIN
    DECLARE benutzerRolle VARCHAR(20);
    
    -- Rolle prüfen
SELECT Rolle INTO benutzerRolle FROM Benutzer WHERE BenutzerID = p_BenutzerID;

IF benutzerRolle = 'Administrator' THEN
        SET p_IstAdmin = TRUE;
        
        -- Import-Log-Eintrag erstellen (Status wird später aktualisiert)
INSERT INTO ImportLog (ImportiertVon, DateiName, Status)
VALUES (p_BenutzerID, p_DateiName, 'Fehlgeschlagen');

SET p_ImportId = LAST_INSERT_ID();
ELSE
        SET p_IstAdmin = FALSE;
        SET p_ImportId = NULL;
END IF;
END //

-- Import abschliessen (US 1.5.1 - ST-3)
CREATE PROCEDURE SP_ImportAbschliessen(
    IN p_ImportId INT,
    IN p_SzenarioId INT,
    IN p_AnzahlKarten INT,
    IN p_AnzahlPhasen INT,
    IN p_AnzahlRollen INT,
    IN p_IstErfolgreich BOOLEAN,
    IN p_Fehlermeldung TEXT
)
BEGIN
    IF p_IstErfolgreich THEN
UPDATE ImportLog
SET SzenarioId = p_SzenarioId,
    AnzahlKarten = p_AnzahlKarten,
    AnzahlPhasen = p_AnzahlPhasen,
    AnzahlRollen = p_AnzahlRollen,
    Status = 'Erfolgreich',
    Fehlermeldung = NULL
WHERE ImportId = p_ImportId;
ELSE
UPDATE ImportLog
SET Status = 'Fehlgeschlagen',
    Fehlermeldung = p_Fehlermeldung
WHERE ImportId = p_ImportId;
END IF;
END //

-- Export vorbereiten (US 1.5.2 - ST-2)
CREATE PROCEDURE SP_ExportVorbereiten(
    IN p_BenutzerID INT,
    IN p_SzenarioId INT,
    OUT p_ExportId INT,
    OUT p_IstAdmin BOOLEAN,
    OUT p_DateiName VARCHAR(255)
)
BEGIN
    DECLARE benutzerRolle VARCHAR(20);
    DECLARE szenarioTitel VARCHAR(100);
    DECLARE exportDatum VARCHAR(20);
    
    -- Rolle prüfen
SELECT Rolle INTO benutzerRolle FROM Benutzer WHERE BenutzerID = p_BenutzerID;

IF benutzerRolle = 'Administrator' THEN
        SET p_IstAdmin = TRUE;
        
        -- Szenario-Titel und Datum für Dateiname
SELECT Titel INTO szenarioTitel FROM Szenario WHERE SzenarioId = p_SzenarioId;
SET exportDatum = DATE_FORMAT(NOW(), '%Y%m%d');
        SET p_DateiName = CONCAT(szenarioTitel, '_', exportDatum, '.json');
        
        -- Export-Log-Eintrag erstellen
INSERT INTO ExportLog (SzenarioId, ExportiertVon, DateiName)
VALUES (p_SzenarioId, p_BenutzerID, p_DateiName);

SET p_ExportId = LAST_INSERT_ID();
ELSE
        SET p_IstAdmin = FALSE;
        SET p_ExportId = NULL;
        SET p_DateiName = NULL;
END IF;
END //

-- Szenario Export Daten (US 1.5.2 - ST-3)
CREATE PROCEDURE SP_SzenarioExportDaten(
    IN p_SzenarioId INT
)
BEGIN
    -- 1. Szenario-Metadaten
SELECT SzenarioId, Titel, Beschreibung, Schwierigkeit, Status, ErstelltAm
FROM Szenario WHERE SzenarioId = p_SzenarioId;

-- 2. Alle Karten mit Optionen
SELECT k.KarteId, k.KartenTyp, k.KartenCode, k.Titel, k.Beschreibung,
       k.ReaktionsTyp, k.Punkte, k.VorherigeKarteId,
       o.OptionId, o.OptionText, o.IstRichtig, o.NaechsteKarteId
FROM Karte k
         LEFT JOIN `Option` o ON k.KarteId = o.KarteId
WHERE k.SzenarioId = p_SzenarioId
ORDER BY k.KarteId, o.OptionId;

-- 3. Alle Phasen
SELECT PhaseId, Titel, Beschreibung, Reihenfolge, StartKarteId, EndKarteId
FROM Phase WHERE SzenarioId = p_SzenarioId
ORDER BY Reihenfolge;

-- 4. Alle zugeordneten Rollen
SELECT sr.RolleId, r.Rollenname, r.Beschreibung
FROM SzenarioRolle sr
         JOIN Rollen r ON sr.RolleId = r.RolleId
WHERE sr.SzenarioId = p_SzenarioId;
END //

-- Berechtigung ändern (US 0.3.1 - ST-2)
CREATE PROCEDURE SP_BerechtigungAendern(
    IN p_BenutzerId INT,
    IN p_NeueRolle ENUM('Spieler','Moderator','Administrator'),
    IN p_AdminId INT
        )
BEGIN
    DECLARE alteRolle VARCHAR(20);
    DECLARE adminRolle VARCHAR(20);
    DECLARE anzahlAdmins INT;
    
    -- Prüfe: Ist ausführender Benutzer Admin?
SELECT Rolle INTO adminRolle FROM Benutzer WHERE BenutzerID = p_AdminId;
IF adminRolle != 'Administrator' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nur Administratoren können Berechtigungen ändern!';
END IF;
    
    -- Hole aktuelle Rolle
SELECT Rolle INTO alteRolle FROM Benutzer WHERE BenutzerID = p_BenutzerId;

-- Prüfe: Letzter Admin-Schutz
IF alteRolle = 'Administrator' AND p_NeueRolle != 'Administrator' THEN
SELECT COUNT(*) INTO anzahlAdmins FROM Benutzer WHERE Rolle = 'Administrator';
IF anzahlAdmins <= 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Der letzte Administrator kann nicht herabgestuft werden!';
END IF;
END IF;
    
    -- Rolle ändern
UPDATE Benutzer SET Rolle = p_NeueRolle WHERE BenutzerID = p_BenutzerId;

-- Log-Eintrag erstellen
INSERT INTO BerechtigungsLog (BenutzerId, AlteRolle, NeueRolle, GeaendertVon)
VALUES (p_BenutzerId, alteRolle, p_NeueRolle, p_AdminId);

-- Ergebnis zurückgeben
SELECT BenutzerID, Benutzername, Rolle FROM Benutzer WHERE BenutzerID = p_BenutzerId;
END //

-- Session Details laden (US 2.1.2 - ST-3)
CREATE PROCEDURE SP_SessionDetailsLaden(
    IN p_SessionId INT
)
BEGIN
    -- Result Set 1: Session-Übersicht
SELECT * FROM View_SessionDetails WHERE SessionId = p_SessionId;

-- Result Set 2: Spieler-Liste mit Rollen und Status
SELECT
    ss.SpielerId,
    b.Benutzername,
    r.Rollenname,
    ss.Punkte,
    ss.Status,
    ss.LetzteAktivitaet
FROM SessionSpieler ss
         JOIN Benutzer b ON ss.SpielerId = b.BenutzerID
         JOIN Rollen r ON ss.RolleId = r.RolleId
WHERE ss.SessionId = p_SessionId
ORDER BY ss.Punkte DESC;

-- Result Set 3: Phasen-Fortschritt
SELECT
    p.PhaseId,
    p.Titel,
    p.Reihenfolge,
    COUNT(DISTINCT sv.KarteId) AS GespielteKarten
FROM Phase p
         JOIN Session s ON p.SzenarioId = s.SzenarioId
         LEFT JOIN Spielverlauf sv ON sv.SessionId = s.SessionId
WHERE s.SessionId = p_SessionId
GROUP BY p.PhaseId, p.Titel, p.Reihenfolge
ORDER BY p.Reihenfolge;

-- Result Set 4: Letzte 10 Aktionen
SELECT * FROM View_LetzteAktionen
WHERE SessionId = p_SessionId
ORDER BY Zeitstempel DESC
    LIMIT 10;
END //
    
    
    DELIMITER ;
 