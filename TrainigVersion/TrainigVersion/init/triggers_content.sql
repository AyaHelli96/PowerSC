USE cyberspace_nis2;
 
-- =====================================
-- TRIGGERS
-- =====================================

-- Min. eine richtige Option (US 1.2.1)

    DELIMITER //
              
CREATE TRIGGER TRG_MinEineRichtigeOption
    AFTER INSERT ON `Option`
    FOR EACH ROW
BEGIN
    DECLARE anzahlRichtig INT;

    SELECT COUNT(*) INTO anzahlRichtig FROM `Option` WHERE KarteId = NEW.KarteId AND IstRichtig = 1;

    IF anzahlRichtig = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mindestens eine Option muss korrekt sein!';
END IF;
END //

-- Reaktion keine Optionen (US 1.2.2)
CREATE TRIGGER TRG_ReaktionKeineOptionen
    BEFORE INSERT ON `Option`
    FOR EACH ROW
BEGIN
    DECLARE kartenTyp VARCHAR(20);

    SELECT KartenTyp INTO kartenTyp FROM Karte WHERE KarteId = NEW.KarteId;

    IF kartenTyp = 'Reaktion' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reaktion-Karten dürfen keine Optionen haben!';
END IF;
END //

-- Phase Start/End Karte verschieden (US 1.3.1)
CREATE TRIGGER TRG_Phase_StartEndKarte
    BEFORE INSERT ON Phase
    FOR EACH ROW
BEGIN
    IF NEW.StartKarteId = NEW.EndKarteId AND NEW.StartKarteId IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Start-Karte und End-Karte müssen verschieden sein!';
END IF;
END //

-- Phasen Reihenfolge ohne Lücken (US 1.3.1)
CREATE TRIGGER TRG_Phase_Reihenfolge
    BEFORE INSERT ON Phase
    FOR EACH ROW
BEGIN
    DECLARE maxReihenfolge INT;

    SELECT COALESCE(MAX(Reihenfolge), 0) INTO maxReihenfolge FROM Phase WHERE SzenarioId = NEW.SzenarioId;

    IF NEW.Reihenfolge != maxReihenfolge + 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phasen-Reihenfolge darf keine Lücken haben!';
END IF;
END //

-- Min. 5 Rollen (US 1.4.1)
CREATE TRIGGER TRG_Rollen_MinFuenf
    BEFORE DELETE ON Rollen
    FOR EACH ROW
BEGIN
    DECLARE anzahlRollen INT;

    SELECT COUNT(*) INTO anzahlRollen FROM Rollen;

    IF anzahlRollen <= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mindestens 5 Standard-Rollen müssen vorhanden sein!';
END IF;
END //

-- Keine doppelte Entscheidung (Sprint 4)
CREATE TRIGGER TRG_KeineDoppelteEntscheidung
    BEFORE INSERT ON Spielverlauf
    FOR EACH ROW
BEGIN
    DECLARE bereitsGespielt INT;

    SELECT COUNT(*) INTO bereitsGespielt FROM Spielverlauf WHERE SessionId = NEW.SessionId AND SpielerId = NEW.SpielerId AND KarteId = NEW.KarteId;

    IF bereitsGespielt > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Diese Karte wurde bereits gespielt — keine Zurück-Möglichkeit!';
END IF;
END //

-- State Machine Session Status (US 2.2.3 - ST-2)
CREATE TRIGGER TRG_SessionStateMachine
    BEFORE UPDATE ON Session
    FOR EACH ROW
BEGIN
    IF OLD.Status = 'Beendet' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Beendete Session kann nicht mehr geändert werden!';
END IF;

IF OLD.Status = 'Warten' AND NEW.Status NOT IN ('Aktiv', 'Beendet') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Warten kann nur zu Aktiv wechseln!';
END IF;
    
    IF OLD.Status = 'Aktiv' AND NEW.Status NOT IN ('Pausiert', 'Beendet') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Aktiv kann nur zu Pausiert oder Beendet wechseln!';
END IF;
    
    IF OLD.Status = 'Pausiert' AND NEW.Status NOT IN ('Aktiv', 'Beendet') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pausiert kann nur zu Aktiv oder Beendet wechseln!';
END IF;
END //

-- Sackgasse Zähler (US 3.3.2 - ST-2)
CREATE TRIGGER TRG_Sackgasse
    AFTER INSERT ON Spielverlauf
    FOR EACH ROW
BEGIN
    DECLARE karteReaktionsTyp VARCHAR(20);

    SELECT ReaktionsTyp INTO karteReaktionsTyp FROM Karte WHERE KarteId = NEW.KarteId;

    IF karteReaktionsTyp = 'Sackgasse' THEN
    UPDATE Statstik SET AnzahlSackgassen = AnzahlSackgassen + 1, LetzterVersuch = NEW.Zeitstempel WHERE BenutzerId = NEW.SpielerId;
END IF;
END //

-- Szenario Versionierung (US 1.1.2 - ST-2)
CREATE TRIGGER TRG_SzenarioVersionierung
    BEFORE UPDATE ON Szenario
    FOR EACH ROW
BEGIN
    DECLARE naechsteVersion INT;
    
    -- Berechne nächste Versionsnummer
    SELECT COALESCE(MAX(VersionNummer), 0) + 1 INTO naechsteVersion
    FROM SzenarioVersion WHERE SzenarioId = OLD.SzenarioId;

    -- Speichere alte Version
    INSERT INTO SzenarioVersion (
        SzenarioId, VersionNummer, Titel, Beschreibung,
        Schwierigkeit, Status, GeaendertVon, GeaendertAm
    ) VALUES (
                 OLD.SzenarioId, naechsteVersion, OLD.Titel, OLD.Beschreibung,
                 OLD.Schwierigkeit, OLD.Status, NEW.ErstelltVon, CURRENT_TIMESTAMP
             );
END //
-- Letzter Admin Schutz (US 0.3.1 - ST-3)
CREATE TRIGGER TRG_LetzterAdminSchutz
    BEFORE UPDATE ON Benutzer
    FOR EACH ROW
BEGIN
    DECLARE anzahlAdmins INT;
    
    -- Nur wenn Admin herabgestuft wird
    IF OLD.Rolle = 'Administrator' AND NEW.Rolle != 'Administrator' THEN
    SELECT COUNT(*) INTO anzahlAdmins
    FROM Benutzer
    WHERE Rolle = 'Administrator' AND BenutzerID != OLD.BenutzerID;

    IF anzahlAdmins = 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Der letzte Administrator kann nicht herabgestuft werden!';
END IF;
END IF;
END //
    
    
    
    DELIMITER ;