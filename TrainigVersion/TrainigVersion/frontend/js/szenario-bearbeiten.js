// szenario-bearbeiten.js
// CyberSpace NIS2 — Formular F-007: Szenario bearbeiten
// Sprint 6 | US 1.1.2 (SCRUM-230 Formular F-007 UI, 231 Versions-Historie UI)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// MOCK-DATEN — bestehende Szenarien (zum Vorausfüllen)
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/szenarien/{id}  → Daten + GET .../versionen (View_SzenarioVersionierung)
// -------------------------------------------------------
var szenarienDaten = [
    {
        id: 1, titel: "Ransomware-Angriff NIS2 v2",
        beschreibung: "Ein Verschlüsselungs-Trojaner legt die Systeme lahm.",
        nis2: "Art. 21, 23", schwierigkeit: "Schwer", status: "Aktiv",
        zielgruppe: "IT-Personal", dauer: 45, phasen: 5,
        historie: [
            { zeit: "12.03.2026 14:20", wer: "Karen Garcia", was: "Szenario erstellt" },
            { zeit: "15.03.2026 09:10", wer: "Ekaterine Hahna", was: "Beschreibung geändert" }
        ]
    },
    {
        id: 2, titel: "Phishing-Welle",
        beschreibung: "Mitarbeiter erhalten gefälschte E-Mails.",
        nis2: "Art. 21", schwierigkeit: "Einfach", status: "Entwurf",
        zielgruppe: "Alle", dauer: 25, phasen: 3,
        historie: [
            { zeit: "10.03.2026 11:00", wer: "Karen Garcia", was: "Szenario erstellt" }
        ]
    }
];

var aktuellesSzenario = null;

// -------------------------------------------------------
// SEITE LADEN — ID aus URL lesen, Formular vorausfüllen
// -------------------------------------------------------
window.onload = function() {
    var id = parseInt(getParameter("id"));
    if (isNaN(id)) {
        id = 1;   // Fallback für Tests
    }

    // Passendes Szenario finden
    for (var i = 0; i < szenarienDaten.length; i++) {
        if (szenarienDaten[i].id === id) {
            aktuellesSzenario = szenarienDaten[i];
        }
    }
    if (aktuellesSzenario === null) {
        aktuellesSzenario = szenarienDaten[0];
    }

    formularFuellen();
    historieFuellen();
};

// -------------------------------------------------------
// URL-PARAMETER auslesen (z.B. ?id=1)
// -------------------------------------------------------
function getParameter(name) {
    var suche = window.location.search;
    var teile = suche.replace("?", "").split("&");
    for (var i = 0; i < teile.length; i++) {
        var paar = teile[i].split("=");
        if (paar[0] === name) {
            return paar[1];
        }
    }
    return "";
}

// -------------------------------------------------------
// FORMULAR vorausfüllen
// -------------------------------------------------------
function formularFuellen() {
    var s = aktuellesSzenario;
    document.getElementById("szenarioTitel").value = s.titel;
    document.getElementById("beschreibung").value = s.beschreibung;
    document.getElementById("nis2Artikel").value = s.nis2;
    document.getElementById("schwierigkeitsgrad").value = s.schwierigkeit;
    document.getElementById("status").value = s.status;
    document.getElementById("zielgruppe").value = s.zielgruppe;
    document.getElementById("dauer").value = s.dauer;
    document.getElementById("anzahlPhasen").value = s.phasen;

    // Warnung anzeigen, wenn das Szenario aktiv ist
    if (s.status === "Aktiv") {
        document.getElementById("aktivWarnung").style.display = "block";
    }
}

// -------------------------------------------------------
// VERSIONS-HISTORIE füllen (ST-231)
// -------------------------------------------------------
function historieFuellen() {
    var liste = document.getElementById("historieListe");
    liste.innerHTML = "";

    var historie = aktuellesSzenario.historie;
    for (var i = 0; i < historie.length; i++) {
        var eintrag = document.createElement("div");
        eintrag.className = "historie-eintrag";
        eintrag.innerHTML =
            "<span>" + historie[i].wer + " — " + historie[i].was + "</span>" +
            "<span class='historie-eintrag__zeit'>" + historie[i].zeit + "</span>";
        liste.appendChild(eintrag);
    }
}

// -------------------------------------------------------
// FORMULAR ABSCHICKEN
// -------------------------------------------------------
document.getElementById("bearbeitenForm").onsubmit = function(e) {
    e.preventDefault();
    if (validieren() === true) {
        speichern();
    }
};

// -------------------------------------------------------
// VALIDIERUNG (gleiche Regeln wie F-001)
// -------------------------------------------------------
function validieren() {
    var ok = true;

    var titel = document.getElementById("szenarioTitel").value;
    if (titel === "" || titel.length > 100) { zeigeError("szenarioTitel", "titelError"); ok = false; }
    else { versteckeError("szenarioTitel", "titelError"); }

    var beschreibung = document.getElementById("beschreibung").value;
    if (beschreibung === "" || beschreibung.length > 500) { zeigeError("beschreibung", "beschreibungError"); ok = false; }
    else { versteckeError("beschreibung", "beschreibungError"); }

    var nis2 = document.getElementById("nis2Artikel").value;
    if (nis2 === "") { zeigeError("nis2Artikel", "nis2Error"); ok = false; }
    else { versteckeError("nis2Artikel", "nis2Error"); }

    var schwierigkeit = document.getElementById("schwierigkeitsgrad").value;
    if (schwierikeitLeer(schwierigkeit)) { zeigeError("schwierigkeitsgrad", "schwierigkeitError"); ok = false; }
    else { versteckeError("schwierigkeitsgrad", "schwierigkeitError"); }

    var status = document.getElementById("status").value;
    if (status === "") { zeigeError("status", "statusError"); ok = false; }
    else { versteckeError("status", "statusError"); }

    var dauer = parseInt(document.getElementById("dauer").value);
    if (isNaN(dauer) || dauer < 15 || dauer > 120) { zeigeError("dauer", "dauerError"); ok = false; }
    else { versteckeError("dauer", "dauerError"); }

    var phasen = parseInt(document.getElementById("anzahlPhasen").value);
    if (isNaN(phasen) || phasen < 1 || phasen > 10) { zeigeError("anzahlPhasen", "phasenError"); ok = false; }
    else { versteckeError("anzahlPhasen", "phasenError"); }

    return ok;
}

function schwierikeitLeer(wert) {
    if (wert === "") {
        return true;
    }
    return false;
}

// -------------------------------------------------------
// HILFSFUNKTIONEN
// -------------------------------------------------------
function zeigeError(feldId, errorId) {
    document.getElementById(feldId).classList.add("is-invalid");
    document.getElementById(errorId).style.display = "block";
}

function versteckeError(feldId, errorId) {
    document.getElementById(feldId).classList.remove("is-invalid");
    document.getElementById(errorId).style.display = "none";
}

// -------------------------------------------------------
// SPEICHERN — API-Aufruf (Mock bis Backend fertig)
// -------------------------------------------------------
function speichern() {
    var btn = document.getElementById("submitBtn");
    btn.disabled = true;
    btn.textContent = "Wird gespeichert...";

    var daten = {
        id: aktuellesSzenario.id,
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
    // PUT /api/szenarien/{id}  (SP_SzenarioBearbeitenPruefen, TRG_SzenarioVersionierung)
    console.warn("Mock-Modus: Änderungen gespeichert:", daten);

    setTimeout(function() {
        document.getElementById("alertSuccess").style.display = "block";
        setTimeout(function() {
            window.location.href = "admin-dashboard.html";
        }, 1500);
    }, 500);
}
