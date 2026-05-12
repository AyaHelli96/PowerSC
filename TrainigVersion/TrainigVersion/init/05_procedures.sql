USE cyberspace_nis2;
 
-- =====================================
-- STORED PROCEDURES
-- =====================================
 
-- Neuen Spieler registrieren
DELIMITER $$
CREATE PROCEDURE SP_SpielerRegistrieren(
    IN p_Benutzername VARCHAR(50),
    IN p_Email        VARCHAR(255),
    IN p_PasswortHash VARCHAR(255)
)
BEGIN
INSERT INTO Benutzer (Benutzername, Email, PasswortHash, Rolle, FehlgeschlagenLogin, Punkte)
VALUES (p_Benutzername, p_Email, p_PasswortHash, 'Spieler', 0, 0);
END$$
DELIMITER ;
 
-- Session starten (US 2.2.3 - ST-3)
DELIMITER $$
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
END$$
DELIMITER ;
 
-- Session beenden
DELIMITER $$
CREATE PROCEDURE SP_SessionBeenden(
    IN p_SessionId INT
)
BEGIN
UPDATE Session
SET Status  = 'Beendet',
    Endzeit = CURRENT_TIMESTAMP
WHERE SessionID = p_SessionId;
END$$
DELIMITER ;
 
-- Session pausieren (US 2.2.1 - ST-2)
DELIMITER $$
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
END$$
DELIMITER ;
 
-- Session fortsetzen (US 2.2.3 - ST-3)
DELIMITER $$
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
    b.Benutzername AS Benutzer,
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
    IN p_SessionId INT,
    IN p_SpielerId INT
)
BEGIN
INSERT INTO SessionSpieler (SessionId, SpielerId, Status, Punkte)
VALUES (p_SessionId, p_SpielerId, 'Aktiv', 0);

INSERT INTO Protokoll (SessionId, BenutzerId, Aktion)
VALUES (p_SessionId, p_SpielerId, 'Beigetreten');
END$$
DELIMITER ;
 
-- Punkte vergeben
DELIMITER $$
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
END$$
DELIMITER ;
 
-- Login Versuch (US 0.2.1)
DELIMITER $$
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
END$$
DELIMITER ;
 
-- Karten Code generieren (US 1.2.1)
DELIMITER $$
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
END$$
DELIMITER ;
 
-- Szenario löschen (US 1.6.1)
DELIMITER $$
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
END$$
DELIMITER ;
 
-- Szenario veröffentlichen (US 1.6.1)
DELIMITER $$
CREATE PROCEDURE SP_SzenarioVeroeffentlichen(
    IN p_SzenarioId INT
)
BEGIN
UPDATE Szenario SET Status = 'Aktiv'
WHERE SzenarioId = p_SzenarioId AND Status = 'Entwurf';
END$$
DELIMITER ;
 
-- Aktive Szenarien prüfen
DELIMITER $$
CREATE PROCEDURE SP_AktiveSzenarienPruefen()
BEGIN
    DECLARE anzahlAktiv INT;
SELECT COUNT(*) INTO anzahlAktiv FROM Szenario WHERE Status = 'Aktiv';

IF anzahlAktiv = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mindestens 1 aktives Szenario muss vorhanden sein!';
END IF;
END$$
DELIMITER ;
 
-- Option wählen
DELIMITER $$
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
END$$
DELIMITER ;
 
-- Phasen Fortschritt (Sprint 4)
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
END$$
DELIMITER ;
 
-- Erfolgs Punkte vergeben
DELIMITER $$
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
        INSERT INTO SzenarioRolle (SzenarioId, RolleId) VALUES (p_SzenarioId, p_RolleId);
END IF;
END$$
DELIMITER ;
 
-- Rolle vergeben (US 2.3.1)
DELIMITER $$
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
END$$
DELIMITER ;
