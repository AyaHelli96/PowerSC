// session-erstellen.js
// CyberSpace NIS2 — Formular F-010: Neue Session erstellen
// Sprint 3 | US 2.1.1: Moderator erstellt eine Spielsession
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// MOCK-DATEN — aktive Szenarien (zur Auswahl)
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/szenarien/aktiv  → liefert View_AktiveSzenarien
// -------------------------------------------------------
var aktiveSzenarien = [
    { id: 1, titel: "Ransomware-Angriff NIS2 v2", phasen: 5, maxSpieler: 6 },
    { id: 2, titel: "Phishing-Welle",             phasen: 3, maxSpieler: 4 },
    { id: 3, titel: "Datenleck Kundendaten",      phasen: 4, maxSpieler: 5 }
];

// -------------------------------------------------------
// SEITE LADEN — Szenario-Auswahl befüllen
// -------------------------------------------------------
window.onload = function() {
    var select = document.getElementById("szenario");

    for (var i = 0; i < aktiveSzenarien.length; i++) {
        var sz = aktiveSzenarien[i];
        var option = document.createElement("option");
        option.value = sz.id;
        option.textContent = sz.titel;
        select.appendChild(option);
    }
};

// -------------------------------------------------------
// SZENARIO GEWECHSELT — Phasen-Info und Max. Spieler anzeigen
// -------------------------------------------------------
function szenarioGewaehlt() {
    var select = document.getElementById("szenario");
    var gewaehlteId = parseInt(select.value);

    for (var i = 0; i < aktiveSzenarien.length; i++) {
        if (aktiveSzenarien[i].id === gewaehlteId) {
            document.getElementById("phasenInfo").value = aktiveSzenarien[i].phasen + " Phasen";
            document.getElementById("maxSpieler").value = aktiveSzenarien[i].maxSpieler;
        }
    }
}

// Listener für die Szenario-Auswahl registrieren
document.getElementById("szenario").onchange = function() {
    szenarioGewaehlt();
};

// -------------------------------------------------------
// FORMULAR ABSCHICKEN
// -------------------------------------------------------
document.getElementById("neueSessionForm").onsubmit = function(e) {
    e.preventDefault();

    if (validieren() === true) {
        speichernSession();
    }
};

// -------------------------------------------------------
// VALIDIERUNG — alle Pflichtfelder prüfen
// -------------------------------------------------------
function validieren() {
    var ok = true;

    // Session-Name
    var name = document.getElementById("sessionName").value;
    if (name === "" || name.length > 100) {
        zeigeError("sessionName", "nameError");
        ok = false;
    } else {
        versteckeError("sessionName", "nameError");
    }

    // Szenario
    var szenario = document.getElementById("szenario").value;
    if (szenario === "") {
        zeigeError("szenario", "szenarioError");
        ok = false;
    } else {
        versteckeError("szenario", "szenarioError");
    }

    // Max. Spieler
    var maxSpieler = parseInt(document.getElementById("maxSpieler").value);
    if (isNaN(maxSpieler) || maxSpieler < 2 || maxSpieler > 6) {
        zeigeError("maxSpieler", "maxSpielerError");
        ok = false;
    } else {
        versteckeError("maxSpieler", "maxSpielerError");
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
function speichernSession() {
    var btn = document.getElementById("submitBtn");
    btn.disabled = true;
    btn.textContent = "Wird erstellt...";

    // Formulardaten sammeln
    var daten = {
        sessionName: document.getElementById("sessionName").value,
        szenarioId: parseInt(document.getElementById("szenario").value),
        maxSpieler: parseInt(document.getElementById("maxSpieler").value)
    };

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // POST /api/sessions  → ruft SP_SessionStarten auf, Status = 'Warten'
    // apiRequest("POST", "/api/sessions", daten, onErfolg, onFehler);

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

    // Nach 2 Sekunden zur Session-Steuerung
    setTimeout(function() {
        window.location.href = "session-steuerung.html?id=neu";
    }, 2000);
}

// Fehler-Callback
function onFehler(fehlermeldung) {
    var btn = document.getElementById("submitBtn");
    btn.disabled = false;
    btn.textContent = "Session starten";

    var errorText = document.getElementById("alertErrorText");
    errorText.textContent = fehlermeldung;
    document.getElementById("alertError").style.display = "block";
}
