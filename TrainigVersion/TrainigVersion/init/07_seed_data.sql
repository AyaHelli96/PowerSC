USE cyberspace_nis2;
 
-- =====================================
-- SEED DATEN (Testdaten)
-- =====================================
 
-- Benutzer
INSERT INTO Benutzer (Benutzername, Email, PasswortHash, Rolle, FehlgeschlagenLogin, Punkte, Abteilung)
VALUES
    ('admin_aya',     'aya@cyberspace.at',       'hash_admin_123', 'Admin',     0, NULL, NULL),
    ('mod_karen',     'karen@cyberspace.at',      'hash_mod_456',   'Moderator', 0, NULL, 'IT-Security'),
    ('mod_ekaterine', 'ekaterine@cyberspace.at',  'hash_mod_789',   'Moderator', 0, NULL, 'Backend'),
    ('spieler_max',   'max@cyberspace.at',        'hash_sp_001',    'Spieler',   0, 0,    NULL),
    ('spieler_anna',  'anna@cyberspace.at',       'hash_sp_002',    'Spieler',   0, 0,    NULL),
    ('spieler_tom',   'tom@cyberspace.at',        'hash_sp_003',    'Spieler',   0, 0,    NULL);

-- Rollen
INSERT INTO Rollen (Name, Beschreibung, Farbe, FarbeHex)
VALUES
    ('CEO',  'Chief Executive Officer - Gesamtverantwortung',      'Grau',  '#808080'),
    ('CTO',  'Chief Technology Officer - IT-Infrastruktur',        'Blau',  '#0000FF'),
    ('CFO',  'Chief Financial Officer - Finanzen und Budget',      'Rot',   '#FF0000'),
    ('CISO', 'Chief Information Security Officer - IT-Sicherheit', 'Gruen', '#00FF00'),
    ('ERM',  'Enterprise Risk Manager - Risikomanagement',         'Lila',  '#800080');

-- Szenarien
INSERT INTO Szenario (Titel, Beschreibung, SchwierigkeitsGrad, Zielgruppe, Status, MinSpieler, MaxSpieler, MinPunkte, ErstelltVon)
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

-- Phasen
INSERT INTO Phase (SzenarioId, Titel, Beschreibung, Reihenfolge, ZeitlimitSek)
VALUES
    (1, 'Erkennung',        'Ransomware wird entdeckt',        1, 300),
    (1, 'Eindaemmung',      'Ausbreitung stoppen',             2, 600),
    (1, 'Wiederherstellung','Systeme wiederherstellen',        3, 900),
    (3, 'Grundlagen',       'NIS2 Grundbegriffe kennenlernen', 1, 600),
    (3, 'Anwendung',        'Regeln auf Beispiele anwenden',   2, 600);

-- Szenario Rollen
INSERT INTO SzenarioRolle (SzenarioId, RolleId)
VALUES
    (1, 1), (1, 2), (1, 4),
    (3, 1), (3, 4);

-- Karten
INSERT INTO Karte (PhaseId, Titel, Inhalt, KartenTyp, Punkte, Reihenfolge)
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

-- Optionen
INSERT INTO `Option` (KarteId, Text, IstRichtig, Punkte)
VALUES
    (1, 'System sofort herunterfahren',       1, 20),
    (1, 'Weiterarbeiten und ignorieren',       0, 0),
    (1, 'IT-Abteilung benachrichtigen',        1, 15),
    (3, 'Ja, Backup ist sicher',               1, 15),
    (3, 'Nein, kein Backup vorhanden',         0, 0),
    (4, 'EU-Richtlinie fuer Cybersicherheit',  1, 5),
    (4, 'Ein Antivirenprogramm',               0, 0);