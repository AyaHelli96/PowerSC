// szenario-import.js
// CyberSpace NIS2 — Formular F-006: Szenario importieren
// Sprint 6 | US 1.5.1 (SCRUM-240 Formular F-006 UI, 241 Fehler & Erfolg UI)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// FORMULAR ABSCHICKEN
// -------------------------------------------------------
document.getElementById("importForm").onsubmit = function(e) {
    e.preventDefault();

    var dateiFeld = document.getElementById("datei");

    if (dateiFeld.files.length === 0) {
        ergebnisZeigen(false, "Bitte zuerst eine JSON-Datei auswählen.");
        return;
    }

    var datei = dateiFeld.files[0];

    // Datei lokal einlesen (kein Server nötig)
    var leser = new FileReader();
    leser.onload = function() {
        pruefenUndImportieren(leser.result);
    };
    leser.readAsText(datei);
};

// -------------------------------------------------------
// PRÜFEN — JSON parsen und Pflichtfelder kontrollieren
// -------------------------------------------------------
function pruefenUndImportieren(text) {
    var daten;

    // 1. Ist es gültiges JSON?
    try {
        daten = JSON.parse(text);
    } catch (fehler) {
        ergebnisZeigen(false, "Ungültiges JSON-Format: " + fehler.message);
        return;
    }

    // 2. Pflichtfelder prüfen
    if (!daten.titel) {
        ergebnisZeigen(false, "Pflichtfeld fehlt: 'titel'.");
        return;
    }
    if (!daten.karten) {
        ergebnisZeigen(false, "Pflichtfeld fehlt: 'karten'.");
        return;
    }
    if (!daten.phasen) {
        ergebnisZeigen(false, "Pflichtfeld fehlt: 'phasen'.");
        return;
    }

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // POST /api/szenarien/import  (SP_ImportVorbereiten, SP_ImportAbschliessen)
    // Backend legt Szenario mit Status 'Entwurf' an

    // Anzahl für das Import-Log zählen
    var anzahlKarten = daten.karten.length;
    var anzahlPhasen = daten.phasen.length;
    var anzahlRollen = 0;
    if (daten.rollen) {
        anzahlRollen = daten.rollen.length;
    }

    var meldung = "Szenario \"" + daten.titel + "\" erfolgreich importiert. " +
                  "Karten: " + anzahlKarten + ", Phasen: " + anzahlPhasen +
                  ", Rollen: " + anzahlRollen + ".";
    ergebnisZeigen(true, meldung);
}

// -------------------------------------------------------
// ERGEBNIS ANZEIGEN — Erfolg (grün) oder Fehler (rot)
// -------------------------------------------------------
function ergebnisZeigen(erfolg, meldung) {
    var box = document.getElementById("ergebnis");
    box.textContent = meldung;

    if (erfolg === true) {
        box.className = "import-ergebnis import-ergebnis--erfolg show";
    } else {
        box.className = "import-ergebnis import-ergebnis--fehler show";
    }
}
