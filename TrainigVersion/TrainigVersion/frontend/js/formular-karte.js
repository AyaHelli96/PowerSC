// formular-karte.js
// CyberSpace NIS2 — Formular F-002: Karte erstellen
// SCRUM-85: Formular F-002 UI (Actio)
// SCRUM-93: Formular F-002 Reaktion (Reactio)
// SCRUM-94: Farben UI — Farbcodierung Karten
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// KARTENTYP WECHSELN (SCRUM-85 + SCRUM-93)
// Zeigt/versteckt Felder je nach Actio oder Reactio
// -------------------------------------------------------
function kartenTypWechseln(typ) {
    var header = document.getElementById("karteHeader");
    var titel = document.getElementById("karteTitle");
    var optionenBlock = document.getElementById("optionenBlock");
    var reaktionstypBlock = document.getElementById("reaktionstypBlock");

    if (typ === "Actio") {
        // Actio: Optionen A-D anzeigen, Reaktionstyp verstecken
        optionenBlock.style.display = "block";
        reaktionstypBlock.style.display = "none";

        // Header Farbe: Dunkelblau für Actio
        header.className = "formular-card__header header--actio";
        titel.textContent = "F-002: ACTIO-KARTE ERSTELLEN";

    } else if (typ === "Reactio") {
        // Reactio: Reaktionstyp anzeigen, Optionen verstecken
        optionenBlock.style.display = "none";
        reaktionstypBlock.style.display = "block";

        // Header Farbe: wird durch reaktionsTypWechseln() gesetzt
        titel.textContent = "F-002: REACTIO-KARTE ERSTELLEN";

    } else {
        // Kein Typ gewählt: alles verstecken
        optionenBlock.style.display = "none";
        reaktionstypBlock.style.display = "none";
        header.className = "formular-card__header";
        titel.textContent = "F-002: KARTE ERSTELLEN";
    }
}

// -------------------------------------------------------
// REAKTIONSTYP WECHSELN — Farbcodierung (SCRUM-94)
// Ändert Header-Farbe und zeigt Farb-Badge
// -------------------------------------------------------
function reaktionsTypWechseln(typ) {
    var header = document.getElementById("karteHeader");
    var farbvorschau = document.getElementById("farbvorschau");
    var badge = document.getElementById("farbvorschauBadge");

    if (typ === "positiv") {
        header.className = "formular-card__header header--positiv";
        badge.className = "reaktions-badge badge--positiv";
        badge.textContent = "✅ Positiver Schritt — +50 Punkte";
        farbvorschau.style.display = "block";

    } else if (typ === "negativ") {
        header.className = "formular-card__header header--negativ";
        badge.className = "reaktions-badge badge--negativ";
        badge.textContent = "❌ Negativer Schritt — -30 Punkte";
        farbvorschau.style.display = "block";

    } else if (typ === "recovery") {
        header.className = "formular-card__header header--recovery";
        badge.className = "reaktions-badge badge--recovery";
        badge.textContent = "🔄 Wiederherstellung — +20 Punkte";
        farbvorschau.style.display = "block";

    } else if (typ === "sackgasse") {
        header.className = "formular-card__header header--sackgasse";
        badge.className = "reaktions-badge badge--sackgasse";
        badge.textContent = "🚫 Sackgasse — -50 Punkte";
        farbvorschau.style.display = "block";

    } else {
        farbvorschau.style.display = "none";
    }
}

// -------------------------------------------------------
// FORMULAR ABSCHICKEN
// -------------------------------------------------------
document.getElementById("karteForm").onsubmit = function(e) {
    e.preventDefault();

    if (validieren() === true) {
        speichernKarte();
    }
};

// -------------------------------------------------------
// VALIDIERUNG
// -------------------------------------------------------
function validieren() {
    var ok = true;

    // Karten-ID
    var kartenId = document.getElementById("kartenId").value;
    if (kartenId === "") {
        zeigeError("kartenId", "kartenIdError");
        ok = false;
    } else {
        versteckeError("kartenId", "kartenIdError");
    }

    // Kartentyp
    var kartentyp = document.getElementById("kartentyp").value;
    if (kartentyp === "") {
        zeigeError("kartentyp", "kartentypError");
        ok = false;
    } else {
        versteckeError("kartentyp", "kartentypError");
    }

    // Reaktionstyp (nur wenn Reactio)
    if (kartentyp === "Reactio") {
        var reaktionstyp = document.getElementById("reaktionstyp").value;
        if (reaktionstyp === "") {
            zeigeError("reaktionstyp", "reaktionstypError");
            ok = false;
        } else {
            versteckeError("reaktionstyp", "reaktionstypError");
        }
    }

    // Karten-Titel
    var kartenTitel = document.getElementById("kartenTitel").value;
    if (kartenTitel === "" || kartenTitel.length > 80) {
        zeigeError("kartenTitel", "kartenTitelError");
        ok = false;
    } else {
        versteckeError("kartenTitel", "kartenTitelError");
    }

    // Kartentext
    var kartentext = document.getElementById("kartentext").value;
    if (kartentext === "" || kartentext.length > 300) {
        zeigeError("kartentext", "kartentextError");
        ok = false;
    } else {
        versteckeError("kartentext", "kartentextError");
    }

    // Optionen A und B (nur wenn Actio)
    if (kartentyp === "Actio") {
        var optionA = document.getElementById("optionA").value;
        if (optionA === "") {
            zeigeError("optionA", "optionAError");
            ok = false;
        } else {
            versteckeError("optionA", "optionAError");
        }

        var optionB = document.getElementById("optionB").value;
        if (optionB === "") {
            zeigeError("optionB", "optionBError");
            ok = false;
        } else {
            versteckeError("optionB", "optionBError");
        }
    }

    return ok;
}

// -------------------------------------------------------
// HILFSFUNKTIONEN
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
// SPEICHERN
// -------------------------------------------------------
function speichernKarte() {
    var btn = document.getElementById("submitBtn");
    btn.disabled = true;
    btn.textContent = "Wird gespeichert...";

    var daten = {
        kartenId: document.getElementById("kartenId").value,
        kartentyp: document.getElementById("kartentyp").value,
        kartenTitel: document.getElementById("kartenTitel").value,
        kartentext: document.getElementById("kartentext").value
    };

    // Reaktionstyp nur bei Reactio
    if (daten.kartentyp === "Reactio") {
        daten.reaktionstyp = document.getElementById("reaktionstyp").value;
    }

    // Optionen nur bei Actio
    if (daten.kartentyp === "Actio") {
        daten.optionA = document.getElementById("optionA").value;
        daten.optionB = document.getElementById("optionB").value;
        daten.optionC = document.getElementById("optionC").value;
        daten.optionD = document.getElementById("optionD").value;
    }

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // apiRequest("POST", "/api/karten", daten, onErfolg, onFehler);

    // Mock-Response
    console.warn("Mock-Modus: API nicht verfügbar. Daten:", daten);
    setTimeout(function() {
        onErfolg();
    }, 500);
}

function onErfolg() {
    var successAlert = document.getElementById("alertSuccess");
    successAlert.style.display = "block";

    setTimeout(function() {
        window.location.href = "admin-dashboard.html";
    }, 2000);
}

function onFehler(fehlermeldung) {
    var btn = document.getElementById("submitBtn");
    btn.disabled = false;
    btn.textContent = "Speichern";

    var errorText = document.getElementById("alertErrorText");
    errorText.textContent = fehlermeldung;
    document.getElementById("alertError").style.display = "block";
}
