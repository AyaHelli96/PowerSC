// formular-phase.js
// CyberSpace NIS2 — Formular F-003: Spielphase definieren
// Sprint 3 | US 1.3.1 (SCRUM-114 Formular F-003 UI, SCRUM-115 Phasen Vorschläge)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// MOCK-DATEN — Szenarien (zur Auswahl)
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/szenarien  → liefert alle Szenarien
// -------------------------------------------------------
var szenarienListe = [
    { id: 1, titel: "Ransomware-Angriff NIS2 v2" },
    { id: 2, titel: "Phishing-Welle" },
    { id: 3, titel: "Datenleck Kundendaten" }
];

// -------------------------------------------------------
// SEITE LADEN — Szenario-Auswahl befüllen
// -------------------------------------------------------
window.onload = function() {
    var select = document.getElementById("szenario");

    for (var i = 0; i < szenarienListe.length; i++) {
        var sz = szenarienListe[i];
        var option = document.createElement("option");
        option.value = sz.id;
        option.textContent = sz.titel;
        select.appendChild(option);
    }
};

// -------------------------------------------------------
// VORSCHLAG übernehmen — füllt das Titel-Feld (ST-9)
// -------------------------------------------------------
function titelUebernehmen(text) {
    document.getElementById("phasenTitel").value = text;
    versteckeError("phasenTitel", "titelError");
}

// -------------------------------------------------------
// FORMULAR ABSCHICKEN
// -------------------------------------------------------
document.getElementById("phaseForm").onsubmit = function(e) {
    e.preventDefault();

    if (validieren() === true) {
        speichernPhase();
    }
};

// -------------------------------------------------------
// VALIDIERUNG
// -------------------------------------------------------
function validieren() {
    var ok = true;

    // Szenario
    var szenario = document.getElementById("szenario").value;
    if (szenario === "") {
        zeigeError("szenario", "szenarioError");
        ok = false;
    } else {
        versteckeError("szenario", "szenarioError");
    }

    // Titel
    var titel = document.getElementById("phasenTitel").value;
    if (titel === "" || titel.length > 100) {
        zeigeError("phasenTitel", "titelError");
        ok = false;
    } else {
        versteckeError("phasenTitel", "titelError");
    }

    // Beschreibung (optional, max. 200)
    var beschreibung = document.getElementById("beschreibung").value;
    if (beschreibung.length > 200) {
        zeigeError("beschreibung", "beschreibungError");
        ok = false;
    } else {
        versteckeError("beschreibung", "beschreibungError");
    }

    // Reihenfolge (1–5)
    var reihenfolge = parseInt(document.getElementById("reihenfolge").value);
    if (isNaN(reihenfolge) || reihenfolge < 1 || reihenfolge > 5) {
        zeigeError("reihenfolge", "reihenfolgeError");
        ok = false;
    } else {
        versteckeError("reihenfolge", "reihenfolgeError");
    }

    // Min. Punkte (> 0)
    var minPunkte = parseInt(document.getElementById("minPunkte").value);
    if (isNaN(minPunkte) || minPunkte < 1) {
        zeigeError("minPunkte", "minPunkteError");
        ok = false;
    } else {
        versteckeError("minPunkte", "minPunkteError");
    }

    return ok;
}

// -------------------------------------------------------
// HILFSFUNKTIONEN — Fehler anzeigen / verstecken
// -------------------------------------------------------
function zeigeError(feldId, errorId) {
    var feld = document.getElementById(feldId);
    var fehler = document.getElementById(errorId);
    feld.classList.add("is-invalid");
    fehler.style.display = "block";
}

function versteckeError(feldId, errorId) {
    var feld = document.getElementById(feldId);
    var fehler = document.getElementById(errorId);
    feld.classList.remove("is-invalid");
    fehler.style.display = "none";
}

// -------------------------------------------------------
// SPEICHERN — API-Aufruf (Mock bis Backend fertig)
// -------------------------------------------------------
function speichernPhase() {
    var btn = document.getElementById("submitBtn");
    btn.disabled = true;
    btn.textContent = "Wird gespeichert...";

    // Zeitlimit ist optional
    var zeitlimitWert = document.getElementById("zeitlimit").value;
    var zeitlimit = null;
    if (zeitlimitWert !== "") {
        zeitlimit = parseInt(zeitlimitWert);
    }

    var daten = {
        szenarioId: parseInt(document.getElementById("szenario").value),
        titel: document.getElementById("phasenTitel").value,
        beschreibung: document.getElementById("beschreibung").value,
        reihenfolge: parseInt(document.getElementById("reihenfolge").value),
        minPunkte: parseInt(document.getElementById("minPunkte").value),
        zeitlimitSek: zeitlimit
    };

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // POST /api/phasen  (Tabelle Phase, Reihenfolge 1-5, MinPunkte > 0)
    // apiRequest("POST", "/api/phasen", daten, onErfolg, onFehler);

    // Mock-Response (bis Backend fertig)
    console.warn("Mock-Modus: API nicht verfügbar. Daten:", daten);
    setTimeout(function() {
        onErfolg();
    }, 500);
}

// Erfolg-Callback
function onErfolg() {
    var successAlert = document.getElementById("alertSuccess");
    successAlert.style.display = "block";

    setTimeout(function() {
        window.location.href = "admin-dashboard.html";
    }, 2000);
}

// Fehler-Callback
function onFehler(fehlermeldung) {
    var btn = document.getElementById("submitBtn");
    btn.disabled = false;
    btn.textContent = "Speichern";

    var errorText = document.getElementById("alertErrorText");
    errorText.textContent = fehlermeldung;
    document.getElementById("alertError").style.display = "block";
}
