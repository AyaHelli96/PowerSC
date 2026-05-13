USE cyberspace_nis2;
 
-- =====================================
-- VIEWS
-- =====================================

-- Top Spieler nach Punkten
CREATE VIEW View_TopSpieler AS
SELECT
    b.BenutzerId,
    b.Benutzername,
    b.Email,
    COALESCE(SUM(ss.Punkte), 0) AS GesamtPunkte,
    COUNT(ss.SessionId)         AS AnzahlSessions
FROM Benutzer b
         LEFT JOIN SessionSpieler ss ON b.BenutzerId = ss.SpielerId
WHERE b.Rolle = 'Spieler'
GROUP BY b.BenutzerId, b.Benutzername, b.Email
ORDER BY GesamtPunkte DESC;

-- Aktive Sessions mit Details
CREATE VIEW View_AktiveSessions AS
SELECT
    s.SessionID,
    s.SessionName,
    sz.Titel            AS SzenarioTitel,
    sz.SchwierigkeitsGrad,
    b.Benutzername      AS Moderator,
    s.Status,
    s.Startzeit,
    COUNT(ss.SpielerId) AS AnzahlSpieler
FROM Session s
         JOIN Szenario sz          ON s.SzenarioID  = sz.SzenarioId
         JOIN Benutzer b           ON s.ModeratorID = b.BenutzerId
         LEFT JOIN SessionSpieler ss ON s.SessionID = ss.SessionId
WHERE s.Status IN ('Warten', 'Aktiv')
GROUP BY s.SessionID, s.SessionName, sz.Titel, sz.SchwierigkeitsGrad,
         b.Benutzername, s.Status, s.Startzeit;

-- Spielverlauf mit Details
CREATE VIEW View_Spielverlauf AS
SELECT
    sv.SpieverlaufId,
    s.SessionID,
    sz.Titel         AS SzenarioTitel,
    b.Benutzername   AS Spieler,
    k.Titel          AS Karte,
    o.Text           AS GewaehlteOption,
    o.IstRichtig,
    sv.ErhaltePunkte,
    sv.Zeitstempel
FROM Spielverlauf sv
         JOIN Session s       ON sv.SessionId = s.SessionID
         JOIN Szenario sz     ON s.SzenarioID = sz.SzenarioId
         JOIN Benutzer b      ON sv.SpielerId = b.BenutzerId
         JOIN Karte k         ON sv.KarteId   = k.KarteId
         LEFT JOIN `Option` o ON sv.OptionId  = o.OptionId;

-- Moderator Dashboard
CREATE VIEW View_ModeratorDashboard AS
SELECT
    b.BenutzerId   AS ModeratorId,
    b.Benutzername AS Moderator,
    COUNT(s.SessionID)                               AS GesamtSessions,
    SUM(CASE WHEN s.Status = 'Beendet' THEN 1 ELSE 0 END) AS AbgeschlosseneSessions,
    SUM(CASE WHEN s.Status = 'Aktiv'   THEN 1 ELSE 0 END) AS LaufendeSessions
FROM Benutzer b
         LEFT JOIN Session s ON b.BenutzerId = s.ModeratorID
WHERE b.Rolle = 'Moderator'
GROUP BY b.BenutzerId, b.Benutzername;

-- Szenario Dashboard (US 1.6.1)
CREATE VIEW View_SzenarioDashboard AS
SELECT
    s.SzenarioId,
    s.Titel,
    s.Status,
    s.SchwierigkeitsGrad,
    s.ErstelltAm,
    COUNT(DISTINCT p.PhaseId) AS AnzahlPhasen,
    COUNT(DISTINCT k.KarteId) AS AnzahlKarten,
    b.Benutzername            AS ErstelltVon
FROM Szenario s
         LEFT JOIN Phase p    ON s.SzenarioId  = p.SzenarioId
         LEFT JOIN Karte k    ON p.PhaseId     = k.PhaseId
         LEFT JOIN Benutzer b ON s.ErstelltVon = b.BenutzerId
GROUP BY s.SzenarioId, s.Titel, s.Status, s.SchwierigkeitsGrad, s.ErstelltAm, b.Benutzername
ORDER BY s.ErstelltAm DESC;

-- Phasen Übersicht (US 1.3.1)
CREATE VIEW View_PhasenUebersicht AS
SELECT
    p.PhaseId,
    p.SzenarioId,
    s.Titel          AS SzenarioTitel,
    p.Titel          AS PhasenName,
    p.Reihenfolge    AS PhasenNummer,
    p.Beschreibung,
    p.MinPunkte,
    p.ZeitlimitSek,
    ks.Titel         AS StartKarte,
    ke.Titel         AS EndKarte,
    COUNT(k.KarteId) AS AnzahlKarten
FROM Phase p
         JOIN Szenario s    ON p.SzenarioId   = s.SzenarioId
         LEFT JOIN Karte ks ON p.StartKarteId = ks.KarteId
         LEFT JOIN Karte ke ON p.EndKarteId   = ke.KarteId
         LEFT JOIN Karte k  ON p.PhaseId      = k.PhaseId
GROUP BY p.PhaseId, p.SzenarioId, s.Titel, p.Titel, p.Reihenfolge,
         p.Beschreibung, p.MinPunkte, p.ZeitlimitSek, ks.Titel, ke.Titel
ORDER BY p.SzenarioId, p.Reihenfolge;

-- Rollen Übersicht (US 1.4.1)
CREATE VIEW View_RollenUebersicht AS
SELECT
    r.RolleId,
    r.Name            AS RollenName,
    r.Beschreibung,
    r.Farbe,
    r.FarbeHex,
    COUNT(DISTINCT sr.SzenarioId) AS AnzahlSzenarien,
    GROUP_CONCAT(s.Titel)         AS ZugeordneteSzenarien
FROM Rollen r
         LEFT JOIN SzenarioRolle sr ON r.RolleId     = sr.RolleId
         LEFT JOIN Szenario s       ON sr.SzenarioId = s.SzenarioId
GROUP BY r.RolleId, r.Name, r.Beschreibung, r.Farbe, r.FarbeHex;

-- Verfügbare Rollen (US 2.3.1)
CREATE VIEW View_VerfuegbareRollen AS
SELECT
    r.RolleId,
    r.Name       AS RollenName,
    r.Beschreibung,
    r.Farbe,
    r.FarbeHex,
    ss.SessionId,
    CASE WHEN ss.RolleId IS NOT NULL THEN 'Vergeben' ELSE 'Verfügbar' END AS RollenStatus
FROM Rollen r
         LEFT JOIN SessionSpieler ss ON r.RolleId = ss.RolleId;

-- Aktive Szenarien (US 3.1.1)
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
GROUP BY s.SzenarioId, s.Titel, s.Beschreibung, s.SchwierigkeitsGrad,
         s.Zielgruppe, s.DauerMinuten, s.Nis2Artikel, s.MinSpieler, s.MaxSpieler
ORDER BY CASE s.SchwierigkeitsGrad
             WHEN 'Einfach' THEN 1
             WHEN 'Mittel'  THEN 2
             WHEN 'Schwer'  THEN 3
             END;

-- Spielverlauf Detail (Sprint 4)
CREATE VIEW View_SpielverlaufDetail AS
SELECT
    sv.SpieverlaufId,
    sv.SessionId,
    sv.SpielerId,
    b.Benutzername   AS Spieler,
    k.KarteId,
    k.Titel          AS KarteTitel,
    k.Inhalt         AS KarteText,
    k.KartenTyp,
    k.Punkte         AS MaxPunkte,
    sv.OptionId,
    o.Text           AS GewaehlteOption,
    o.IstRichtig,
    sv.ErhaltePunkte,
    sv.Zeitstempel,
    p.Titel          AS PhaseTitel,
    p.Reihenfolge    AS PhaseNummer,
    sz.Titel         AS SzenarioTitel,
    0                AS AbgeschlossenePhasen,
    0                AS GesamtPhasen,
    0                AS GespielteKarten,
    0                AS GesamtKarten
FROM Spielverlauf sv
         JOIN Session s       ON sv.SessionId = s.SessionID
         JOIN Szenario sz     ON s.SzenarioID = sz.SzenarioId
         JOIN Benutzer b      ON sv.SpielerId = b.BenutzerId
         JOIN Karte k         ON sv.KarteId   = k.KarteId
         JOIN Phase p         ON k.PhaseId    = p.PhaseId
         LEFT JOIN `Option` o ON sv.OptionId  = o.OptionId;

-- Erfolgs Feedback (Sprint 4)
CREATE VIEW View_ErfolgsFeedback AS
SELECT
    sv.SpieverlaufId,
    sv.SessionId,
    sv.SpielerId,
    b.Benutzername   AS Spieler,
    k.Titel          AS KarteTitel,
    o.Text           AS GewaehlteOption,
    o.IstRichtig,
    sv.ErhaltePunkte,
    k.KartenTyp,
    r.ReaktionsTyp,
    r.Inhalt         AS Erklaerung,
    r.Nis2Artikel    AS Nis2Referenz,
    ss.Punkte        AS GesamtPunkte
FROM Spielverlauf sv
         JOIN Benutzer b        ON sv.SpielerId  = b.BenutzerId
         JOIN `Option` o        ON sv.OptionId   = o.OptionId
         JOIN Karte k           ON sv.KarteId    = k.KarteId
         LEFT JOIN Karte r      ON k.KarteId     = r.AktioKarteId
    AND r.ReaktionsTyp = 'PositiverSchritt'
         JOIN SessionSpieler ss ON sv.SessionId  = ss.SessionId
    AND sv.SpielerId   = ss.SpielerId
WHERE o.IstRichtig = 1;

-- Moderator Sessions (US 2.1.1 - ST-1)
CREATE VIEW View_ModeratorSessions AS
SELECT
    s.SessionID,
    s.SessionName,
    s.Status,
    s.ErstelltAm,
    s.Startzeit,
    s.Endzeit,
    sz.Titel            AS SzenarioTitel,
    sz.SchwierigkeitsGrad,
    b.BenutzerId        AS ModeratorId,
    b.Benutzername      AS Moderator,
    COUNT(ss.SpielerId) AS AnzahlSpieler
FROM Session s
         JOIN Szenario sz          ON s.SzenarioID  = sz.SzenarioId
         JOIN Benutzer b           ON s.ModeratorID = b.BenutzerId
         LEFT JOIN SessionSpieler ss ON s.SessionID = ss.SessionId
GROUP BY s.SessionID, s.SessionName, s.Status, s.ErstelltAm,
         s.Startzeit, s.Endzeit, sz.Titel, sz.SchwierigkeitsGrad,
         b.BenutzerId, b.Benutzername;

-- Pausierte Sessions (US 2.2.1 - ST-4)
CREATE VIEW View_PausierteSessions AS
SELECT
    s.SessionID,
    s.SessionName,
    s.PausierZeit,
    s.PausierGrund,
    s.ErstelltAm,
    sz.Titel            AS SzenarioTitel,
    sz.SchwierigkeitsGrad,
    b.BenutzerId        AS ModeratorId,
    b.Benutzername      AS Moderator,
    COUNT(ss.SpielerId) AS AnzahlSpieler
FROM Session s
         JOIN Szenario sz          ON s.SzenarioID  = sz.SzenarioId
         JOIN Benutzer b           ON s.ModeratorID = b.BenutzerId
         LEFT JOIN SessionSpieler ss ON s.SessionID = ss.SessionId
WHERE s.Status = 'Pausiert'
GROUP BY s.SessionID, s.SessionName, s.PausierZeit, s.PausierGrund,
         s.ErstelltAm, sz.Titel, sz.SchwierigkeitsGrad,
         b.BenutzerId, b.Benutzername;

-- View_SessionStatus (US 2.2.3 - ST-4)
CREATE VIEW View_SessionStatus AS
SELECT
    s.SessionID,
    s.SessionName,
    s.Status,
    s.AktuellePhase,
    s.Startzeit,
    s.Endzeit,
    s.PausierZeit,
    s.PausierGrund,
    s.FortsetzungsZeit,
    sz.Titel            AS SzenarioTitel,
    sz.SchwierigkeitsGrad,
    b.Benutzername      AS Moderator,
    COUNT(ss.SpielerId) AS AnzahlSpieler,
    COALESCE(SUM(ss.Punkte), 0) AS GesamtPunkte
FROM Session s
         JOIN Szenario sz          ON s.SzenarioID  = sz.SzenarioId
         JOIN Benutzer b           ON s.ModeratorID = b.BenutzerId
         LEFT JOIN SessionSpieler ss ON s.SessionID = ss.SessionId
GROUP BY
    s.SessionID, s.SessionName, s.Status,
    s.AktuellePhase, s.Startzeit, s.Endzeit,
    s.PausierZeit, s.PausierGrund, s.FortsetzungsZeit,
    sz.Titel, sz.SchwierigkeitsGrad, b.Benutzername;

-- View_BeendeteSessions (US 2.2.2 - ST-3)
CREATE VIEW View_BeendeteSessions AS
SELECT
    s.SessionID,
    s.SessionName,
    s.Startzeit,
    s.Endzeit,
    s.BeendigungsGrund,
    sz.Titel             AS SzenarioTitel,
    sz.SchwierigkeitsGrad,
    b.Benutzername       AS Moderator,
    COUNT(ss.SpielerId)  AS AnzahlSpieler,
    COALESCE(SUM(ss.Punkte), 0) AS GesamtPunkte,
    TIMESTAMPDIFF(MINUTE, s.Startzeit, s.Endzeit) AS DauerMinuten
FROM Session s
         JOIN Szenario sz          ON s.SzenarioID  = sz.SzenarioId
         JOIN Benutzer b           ON s.ModeratorID = b.BenutzerId
         LEFT JOIN SessionSpieler ss ON s.SessionID = ss.SessionId
WHERE s.Status = 'Beendet'
GROUP BY
    s.SessionID, s.SessionName,
    s.Startzeit, s.Endzeit, s.BeendigungsGrund,
    sz.Titel, sz.SchwierigkeitsGrad,
    b.Benutzername
ORDER BY s.Endzeit DESC;

-- View_VictoryErgebnis (US 3.3.1 - ST-3)
CREATE VIEW View_VictoryErgebnis AS
SELECT
    ss.SessionId,
    ss.SpielerId,
    b.Benutzername          AS Spieler,
    ss.Punkte               AS ErreichtePunkte,
    s.SessionName,
    sz.Titel                AS SzenarioTitel,
    st.AnzahlSiege,
    st.ComplianceProzent,
    st.LetzterSieg,
    st.BestePunktzahl,
    CASE
        WHEN st.ComplianceProzent >= 70 THEN 'SIEG'
        ELSE 'NIEDERLAGE'
        END                     AS Ergebnis,
    CONCAT(ss.Punkte, '/',
           (SELECT COALESCE(SUM(k.Punkte), 0)
            FROM Phase p
                     JOIN Karte k ON p.PhaseId = k.PhaseId
            WHERE p.SzenarioId = s.SzenarioID
              AND k.KartenTyp != 'Reaktion')
    )                       AS PunktAnzeige
FROM SessionSpieler ss
         JOIN Benutzer b    ON ss.SpielerId  = b.BenutzerId
         JOIN Session s     ON ss.SessionId  = s.SessionID
         JOIN Szenario sz   ON s.SzenarioID  = sz.SzenarioId
         LEFT JOIN Statstik st ON ss.SpielerId = st.BenutzerId
WHERE s.Status = 'Beendet';

-- =====================================
-- View_GameOverAnalyse (US 3.3.2 - ST-4)
-- =====================================
-- Zweck: Game Over Statistiken für jeden Spieler anzeigen
-- Zeigt: Punktzahl, Compliance%, Versuche, Sackgassen, beste Punktzahl

CREATE VIEW View_GameOverAnalyse AS
SELECT
    b.BenutzerId,
    b.Benutzername,
    b.Email,

    -- Letzte Versuch-Daten
    s.LetzterVersuch,
    s.ComplianceProzent AS LetzteCompliance,

    -- Versuchs-Statistiken
    s.AnzahlVersuche AS GesamtVersuche,
    s.AnzahlSackgassen,
    s.AnzahlSiege,

    -- Punkte-Statistiken
    s.BestePunktzahl,
    s.GesamtPunkte,
    ROUND(s.GesamtPunkte / NULLIF(s.GespielteSpiele, 0), 0) AS DurchschnittPunkte,

    -- Erfolgsquote
    ROUND((s.AnzahlSiege * 100.0) / NULLIF(s.GespielteSpiele, 0), 2) AS Erfolgsquote,

    -- Spiele-Statistiken
    s.GespielteSpiele,

    -- Verbesserungsbereiche (basierend auf letzter Compliance)
    CASE
        WHEN s.ComplianceProzent < 30 THEN 'Kritisch: Grundlagen NIS2 wiederholen'
        WHEN s.ComplianceProzent < 50 THEN 'Verbesserungsbedarf: Incident Response trainieren'
        WHEN s.ComplianceProzent < 70 THEN 'Gut: Feinabstimmung bei Compliance-Maßnahmen'
        WHEN s.ComplianceProzent < 90 THEN 'Sehr gut: Details bei Meldepflichten beachten'
        ELSE 'Exzellent: NIS2 Compliance erreicht'
        END AS Verbesserungsbereich,

    -- Status-Indikator
    CASE
        WHEN s.ComplianceProzent >= 70 THEN 'Bestanden'
        ELSE 'Nicht bestanden'
        END AS Status

FROM Benutzer b
         JOIN Statstik s ON b.BenutzerId = s.BenutzerId
WHERE b.Rolle = 'Spieler';