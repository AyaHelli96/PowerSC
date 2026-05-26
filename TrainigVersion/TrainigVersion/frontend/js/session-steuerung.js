// session-steuerung.js
// CyberSpace NIS2 — Session-Steuerung (Moderator)
// Sprint 3 | US 2.2.1 Pausieren | US 2.2.2 Beenden | US 2.2.3 Status/Zustandsautomat
// Zustandsautomat: Warten -> Aktiv -> Pausiert -> Aktiv -> Beendet
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// MOCK-DATEN — eine laufende Session
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/sessions/{id}  → liefert View_SessionStatus + Spielerliste
// -------------------------------------------------------
var session = {
    id: 1,
    name: "Schulung IT-Team",
    szenario: "Ransomware-Angriff NIS2 v2",
    status: "Warten",          // Warten / Aktiv / Pausiert / Beendet
    aktuellePhase: 1,
    gesamtPhasen: 5,
    gesamtPunkte: 0
};

var spieler = [
    { name: "Max Mustermann",  rolle: "IT-Leitung",     farbe: "#3498DB", status: "Aktiv",       punkte: 0 },
    { name: "Erika Beispiel",  rolle: "Kommunikation",  farbe: "#2ECC71", status: "Aktiv",       punkte: 0 },
    { name: "Tom Test",        rolle: "Geschäftsführung", farbe: "#C0392B", status: "Aktiv",     punkte: 0 },
    { name: "Lisa Lustig",     rolle: "Rechtsabteilung", farbe: "#8E44AD", status: "Eingeladen", punkte: 0 }
];

// -------------------------------------------------------
// SEITE LADEN — Session-ID aus der URL lesen und Ansicht aufbauen
// -------------------------------------------------------
window.onload = function() {
    var id = getParameter("id");
    if (id !== "" && id !== "neu") {
        session.id = parseInt(id);
    }
    // Eine neue Session startet immer im Status "Warten"
    if (id === "neu") {
        session.status = "Warten";
    }

    ansichtAktualisieren();
    spielerlisteAufbauen();
};

// -------------------------------------------------------
// URL-PARAMETER auslesen (z.B. ?id=1)
// -------------------------------------------------------
function getParameter(name) {
    var suche = window.location.search;          // z.B. "?id=1"
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
// ANSICHT AKTUALISIEREN — Info-Card + passende Buttons
// -------------------------------------------------------
function ansichtAktualisieren() {
    // Info-Card füllen
    document.getElementById("sessionName").textContent = session.name;
    document.getElementById("szenarioTitel").textContent = session.szenario;
    document.getElementById("aktuellePhase").textContent =
        "Phase " + session.aktuellePhase + " / " + session.gesamtPhasen;
    document.getElementById("anzahlSpieler").textContent = spieler.length;
    document.getElementById("gesamtPunkte").textContent = session.gesamtPunkte;

    // Status-Badge
    var badge = document.getElementById("statusBadge");
    badge.textContent = session.status;
    badge.className = "status-badge status-badge--" + session.status.toLowerCase();

    // Buttons je nach Status (Zustandsautomat)
    buttonsAnzeigen();
}

// -------------------------------------------------------
// BUTTONS je nach Status einblenden (US 2.2.3)
// -------------------------------------------------------
function buttonsAnzeigen() {
    var bereich = document.getElementById("steuerungButtons");
    bereich.innerHTML = "";

    if (session.status === "Warten") {
        bereich.innerHTML =
            "<button class='btn btn--start' onclick='starten()'>▶️ Session starten</button>";
    } else if (session.status === "Aktiv") {
        bereich.innerHTML =
            "<button class='btn btn--pause' onclick='pausieren()'>⏸️ Pausieren</button>" +
            "<button class='btn btn--danger' onclick='beendenDialog()'>⏹️ Beenden</button>";
    } else if (session.status === "Pausiert") {
        bereich.innerHTML =
            "<button class='btn btn--start' onclick='fortsetzen()'>▶️ Fortsetzen</button>" +
            "<button class='btn btn--danger' onclick='beendenDialog()'>⏹️ Beenden</button>";
    } else if (session.status === "Beendet") {
        bereich.innerHTML =
            "<div class='beendet-hinweis'>Diese Session wurde beendet. " +
            "Gesamtpunkte: " + session.gesamtPunkte + "</div>";
    }
}

// -------------------------------------------------------
// SPIELERLISTE aufbauen
// -------------------------------------------------------
function spielerlisteAufbauen() {
    var tbody = document.getElementById("spielerBody");
    tbody.innerHTML = "";

    for (var i = 0; i < spieler.length; i++) {
        var sp = spieler[i];
        var zeile = document.createElement("tr");

        zeile.innerHTML =
            "<td>" + sp.name + "</td>" +
            "<td><span class='rollen-punkt' style='background:" + sp.farbe + ";'></span>" + sp.rolle + "</td>" +
            "<td>" + sp.status + "</td>" +
            "<td>" + sp.punkte + "</td>";

        tbody.appendChild(zeile);
    }
}

// -------------------------------------------------------
// AKTIONEN — Zustandsübergänge
// -------------------------------------------------------
function starten() {
    // TODO: POST /api/sessions/{id}/start  (ruft SP_SessionStarten auf)
    console.warn("Mock-Modus: Session " + session.id + " gestartet.");
    session.status = "Aktiv";
    ansichtAktualisieren();
}

function pausieren() {
    // TODO: POST /api/sessions/{id}/pause  (setzt Status='Pausiert', PausierZeit)
    console.warn("Mock-Modus: Session " + session.id + " pausiert.");
    session.status = "Pausiert";
    ansichtAktualisieren();
}

function fortsetzen() {
    // TODO: POST /api/sessions/{id}/resume  (setzt Status='Aktiv', FortsetzungsZeit)
    console.warn("Mock-Modus: Session " + session.id + " fortgesetzt.");
    session.status = "Aktiv";
    ansichtAktualisieren();
}

// -------------------------------------------------------
// BEENDEN — mit Bestätigungsdialog (US 2.2.2)
// -------------------------------------------------------
function beendenDialog() {
    document.getElementById("beendenDialog").style.display = "flex";
}

function beendenBestaetigen() {
    // TODO: POST /api/sessions/{id}/end  (setzt Status='Beendet', Endzeit)
    console.warn("Mock-Modus: Session " + session.id + " beendet.");
    session.status = "Beendet";
    dialogSchliessen();
    ansichtAktualisieren();
}

function dialogSchliessen() {
    document.getElementById("beendenDialog").style.display = "none";
}

// Escape-Taste schließt den Dialog
document.onkeydown = function(e) {
    if (e.key === "Escape") {
        dialogSchliessen();
    }
};
