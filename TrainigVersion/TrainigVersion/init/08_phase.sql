USE cyberspace_nis2;

CREATE TABLE IF NOT EXISTS Phase (
  PhaseId INT NOT NULL AUTO_INCREMENT,
  PhaseNummer INT NOT NULL,
  Titel VARCHAR(100) NOT NULL,
  Beschreibung VARCHAR(300),
  PRIMARY KEY (PhaseId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO Phase (PhaseNummer, Titel, Beschreibung) VALUES
  (1, 'Phase 1: Erkennung', 'Erkennung von Cyberangriffen'),
  (2, 'Phase 2: Reaktion', 'Reaktion auf Sicherheitsvorf?lle');
