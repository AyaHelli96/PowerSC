USE cyberspace_nis2;
 
-- =====================================
-- FOREIGN KEYS
-- =====================================

ALTER TABLE Szenario
    ADD CONSTRAINT FK_Szenario_Benutzer
        FOREIGN KEY (ErstelltVon) REFERENCES Benutzer(BenutzerId);

ALTER TABLE Statstik
    ADD CONSTRAINT FK_Statstik_Benutzer
        FOREIGN KEY (BenutzerId) REFERENCES Benutzer(BenutzerId);

ALTER TABLE Phase
    ADD CONSTRAINT FK_Phase_Szenario
        FOREIGN KEY (SzenarioId) REFERENCES Szenario(SzenarioId);

ALTER TABLE SzenarioRolle
    ADD CONSTRAINT FK_SzenarioRolle_Szenario
        FOREIGN KEY (SzenarioId) REFERENCES Szenario(SzenarioId);

ALTER TABLE SzenarioRolle
    ADD CONSTRAINT FK_SzenarioRolle_Rollen
        FOREIGN KEY (RolleId) REFERENCES Rollen(RolleId);

ALTER TABLE Session
    ADD CONSTRAINT FK_Session_Szenario
        FOREIGN KEY (SzenarioID) REFERENCES Szenario(SzenarioId);

ALTER TABLE Session
    ADD CONSTRAINT FK_Session_Moderator
        FOREIGN KEY (ModeratorID) REFERENCES Benutzer(BenutzerId);

ALTER TABLE Karte
    ADD CONSTRAINT FK_Karte_Phase
        FOREIGN KEY (PhaseId) REFERENCES Phase(PhaseId);

ALTER TABLE Karte
    ADD CONSTRAINT FK_Karte_AktioKarte
        FOREIGN KEY (AktioKarteId) REFERENCES Karte(KarteId);

ALTER TABLE Phase
    ADD CONSTRAINT FK_Phase_StartKarte
        FOREIGN KEY (StartKarteId) REFERENCES Karte(KarteId);

ALTER TABLE Phase
    ADD CONSTRAINT FK_Phase_EndKarte
        FOREIGN KEY (EndKarteId) REFERENCES Karte(KarteId);

ALTER TABLE SessionSpieler
    ADD CONSTRAINT FK_SessionSpieler_Session
        FOREIGN KEY (SessionId) REFERENCES Session(SessionID);

ALTER TABLE SessionSpieler
    ADD CONSTRAINT FK_SessionSpieler_Spieler
        FOREIGN KEY (SpielerId) REFERENCES Benutzer(BenutzerId);

ALTER TABLE SessionSpieler
    ADD CONSTRAINT FK_SessionSpieler_Rollen
        FOREIGN KEY (RolleId) REFERENCES Rollen(RolleId);

ALTER TABLE Einladung
    ADD CONSTRAINT FK_Einladung_Session
        FOREIGN KEY (SessionId) REFERENCES Session(SessionID);

ALTER TABLE Einladung
    ADD CONSTRAINT FK_Einladung_Von
        FOREIGN KEY (EingeladenVon) REFERENCES Benutzer(BenutzerId);

ALTER TABLE Einladung
    ADD CONSTRAINT FK_Einladung_An
        FOREIGN KEY (EingeladenAn) REFERENCES Benutzer(BenutzerId);

ALTER TABLE `Option`
    ADD CONSTRAINT FK_Option_Karte
        FOREIGN KEY (KarteId) REFERENCES Karte(KarteId);

ALTER TABLE Protokoll
    ADD CONSTRAINT FK_Protokoll_Session
        FOREIGN KEY (SessionId) REFERENCES Session(SessionID);

ALTER TABLE Protokoll
    ADD CONSTRAINT FK_Protokoll_Benutzer
        FOREIGN KEY (BenutzerId) REFERENCES Benutzer(BenutzerId);

ALTER TABLE Spielverlauf
    ADD CONSTRAINT FK_Spielverlauf_Session
        FOREIGN KEY (SessionId) REFERENCES Session(SessionID);

ALTER TABLE Spielverlauf
    ADD CONSTRAINT FK_Spielverlauf_Karte
        FOREIGN KEY (KarteId) REFERENCES Karte(KarteId);

ALTER TABLE Spielverlauf
    ADD CONSTRAINT FK_Spielverlauf_Option
        FOREIGN KEY (OptionId) REFERENCES `Option`(OptionId);

ALTER TABLE Spielverlauf
    ADD CONSTRAINT FK_Spielverlauf_Spieler
        FOREIGN KEY (SpielerId) REFERENCES Benutzer(BenutzerId);
 