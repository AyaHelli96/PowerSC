// formular-rolle.js
// CyberSpace NIS2 — Formular F-004: Spielrolle konfigurieren
// Sprint 3 | US 1.4.1 (SCRUM-124 Formular F-004 UI, SCRUM-125 Farben konsistent)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// FARB-ZUORDNUNG — die 5 erlaubten Rollen-Farben + Hex
// (passend zur Tabelle Rollen: Grau, Blau, Rot, Gruen, Lila)
// -------------------------------------------------------
function holeHex(farbe) {
    if (farbe === "Grau")  return "#95A5A6";
    if (farbe === "Blau")  return "#3498DB";
    if (farbe === "Rot")   return "#C0392B";
    if (farbe === "Gruen") return "#2ECC71";
    if (farbe === "Lila")  return "#8E44AD";
    return "#E0E0E0";
}

// -------------------------------------------------------
// FARB-VORSCHAU aktualisieren, wenn eine Farbe gewählt wird
// -------------------------------------------------------
function farbeAktualisieren() {
    var farbe = document.getElementById("farbe").value;
    var hex = holeHex(farbe);

    document.getElementById("farbPunkt").style.background = hex;

    if (farbe === "") {
        document.getElementById("farbHexText").textContent = "—";
    } else {
        document.getElementById("farbHexText").textContent = hex;
    }
}

// -------------------------------------------------------
// FORMULAR ABSCHICKEN
// -------------------------------------------------------
document.getElementById("rolleForm").onsubmit = function(e) {
    e.preventDefault();

    if (validieren() === true) {
        speichernRolle();
    }
};

// -------------------------------------------------------
// VALIDIERUNG
// -------------------------------------------------------
function validieren() {
    var ok = true;

    // Name
    var name = document.getElementById("rollenName").value;
    if (name === "" || name.length > 50) {
        zeigeError("rollenName", "nameError");
        ok = false;
    } else {
        versteckeError("rollenName", "nameError");
    }

    // Beschreibung (optional, aber max. 200)
    var beschreibung = document.getElementById("beschreibung").value;
    if (beschreibung.length > 200) {
        zeigeError("beschreibung", "beschreibungError");
        ok = false;
    } else {
        versteckeError("beschreibung", "beschreibungError");
    }

    // Farbe
    var farbe = document.getElementById("farbe").value;
    if (farbe === "") {
        zeigeError("farbe", "farbeError");
        ok = false;
    } else {
        versteckeError("farbe", "farbeError");
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
function speichernRolle() {
    var btn = document.getElementById("submitBtn");
    btn.disabled = true;
    btn.textContent = "Wird gespeichert...";

    var farbe = document.getElementById("farbe").value;

    var daten = {
        name: document.getElementById("rollenName").value,
        beschreibung: document.getElementById("beschreibung").value,
        farbe: farbe,
        farbeHex: holeHex(farbe)
    };

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // POST /api/rollen  (Tabelle Rollen, max. 5 durch TRG_5RollenSchutz)
    // apiRequest("POST", "/api/rollen", daten, onErfolg, onFehler);

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
