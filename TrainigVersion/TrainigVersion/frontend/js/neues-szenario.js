// neues-szenario.js
// CyberSpace NIS2 — Formular F-001: Neues Szenario erstellen
// SCRUM-77: ST-5 Formular F-001 UI Karen
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// Formular abschicken
document.getElementById("neuesSzenarioForm").onsubmit = function(e) {
    e.preventDefault();

    if (validieren() === true) {
        speichernSzenario();
    }
};

// -------------------------------------------------------
// VALIDIERUNG — alle Pflichtfelder prüfen
// -------------------------------------------------------
function validieren() {
    var ok = true;

    // Titel
    var titel = document.getElementById("szenarioTitel").value;
    if (titel === "" || titel.length > 100) {
        zeigeError("szenarioTitel", "titelError");
        ok = false;
    } else {
        versteckeError("szenarioTitel", "titelError");
    }

    // Beschreibung
    var beschreibung = document.getElementById("beschreibung").value;
    if (beschreibung === "" || beschreibung.length > 500) {
        zeigeError("beschreibung", "beschreibungError");
        ok = false;
    } else {
        versteckeError("beschreibung", "beschreibungError");
    }

    // NIS2-Artikel
    var nis2 = document.getElementById("nis2Artikel").value;
    if (nis2 === "") {
        zeigeError("nis2Artikel", "nis2Error");
        ok = false;
    } else {
        versteckeError("nis2Artikel", "nis2Error");
    }

    // Schwierigkeitsgrad
    var schwierigkeit = document.getElementById("schwierigkeitsgrad").value;
    if (schwierigkeit === "") {
        zeigeError("schwierigkeitsgrad", "schwierigkeitError");
        ok = false;
    } else {
        versteckeError("schwierigkeitsgrad", "schwierigkeitError");
    }

    // Status
    var status = document.getElementById("status").value;
    if (status === "") {
        zeigeError("status", "statusError");
        ok = false;
    } else {
        versteckeError("status", "statusError");
    }

    // Dauer
    var dauer = parseInt(document.getElementById("dauer").value);
    if (isNaN(dauer) || dauer < 15 || dauer > 120) {
        zeigeError("dauer", "dauerError");
        ok = false;
    } else {
        versteckeError("dauer", "dauerError");
    }

    // Anzahl Phasen
    var phasen = parseInt(document.getElementById("anzahlPhasen").value);
    if (isNaN(phasen) || phasen < 1 || phasen > 10) {
        zeigeError("anzahlPhasen", "phasenError");
        ok = false;
    } else {
        versteckeError("anzahlPhasen", "phasenError");
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
function speichernSzenario() {
    var btn = document.getElementById("submitBtn");
    btn.disabled = true;
    btn.textContent = "Wird gespeichert...";

    // Formulardaten sammeln
    var daten = {
        titel: document.getElementById("szenarioTitel").value,
        beschreibung: document.getElementById("beschreibung").value,
        nis2Artikel: document.getElementById("nis2Artikel").value,
        schwierigkeitsgrad: document.getElementById("schwierigkeitsgrad").value,
        status: document.getElementById("status").value,
        zielgruppe: document.getElementById("zielgruppe").value,
        dauer: parseInt(document.getElementById("dauer").value),
        anzahlPhasen: parseInt(document.getElementById("anzahlPhasen").value)
    };

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // apiRequest("POST", "/api/szenarien", daten, onErfolg, onFehler);

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

    // Nach 2 Sekunden zurück zum Dashboard
    setTimeout(function() {
        window.location.href = "admin-dashboard.html";
    }, 2000);
}

// Fehler-Callback
function onFehler(fehlermeldung) {
    var btn = document.getElementById("submitBtn");
    btn.disabled = false;
    btn.textContent = "Speichern";

    var errorAlert = document.getElementById("alertError");
    var errorText = document.getElementById("alertErrorText");
    errorText.textContent = fehlermeldung;
    errorAlert.style.display = "block";
}
