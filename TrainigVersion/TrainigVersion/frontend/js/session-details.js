// session-details.js
// CyberSpace NIS2 — Session-Details (Moderator)
// Sprint 6 | US 2.1.2 (SCRUM-269 Detail-Ansicht UI, 270 Status Farben UI)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// MOCK-DATEN — Session-Details
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/sessions/{id}/details  → View_SessionDetails + View_LetzteAktionen
// -------------------------------------------------------
var session = {
    name: "Schulung IT-Team",
    szenario: "Ransomware-Angriff NIS2 v2",
    aktuellePhase: 3,
    gesamtPhasen: 5
};

var spieler = [
    { name: "Max Mustermann",  rolle: "IT-Leitung",       farbe: "#3498DB", punkte: 120, status: "Aktiv" },
    { name: "Erika Beispiel",  rolle: "Kommunikation",    farbe: "#2ECC71", punkte: 90,  status: "Aktiv" },
    { name: "Tom Test",        rolle: "Geschäftsführung", farbe: "#C0392B", punkte: 60,  status: "Inaktiv" },
    { name: "Lisa Lustig",     rolle: "Rechtsabteilung",  farbe: "#8E44AD", punkte: 30,  status: "Disconnected" }
];

var aktionen = [
    { zeit: "14:32", wer: "Max Mustermann", was: "Option A gewählt (+50)" },
    { zeit: "14:30", wer: "Erika Beispiel", was: "Option B gewählt (-30)" },
    { zeit: "14:28", wer: "Tom Test",       was: "Phase 2 abgeschlossen" },
    { zeit: "14:25", wer: "Max Mustermann", was: "Karte gezogen" },
    { zeit: "14:22", wer: "Lisa Lustig",    was: "Verbindung verloren" }
];

// -------------------------------------------------------
// SEITE LADEN
// -------------------------------------------------------
window.onload = function() {
    infoFuellen();
    spielerFuellen();
    aktionenFuellen();
};

// -------------------------------------------------------
// SESSION-INFO + Fortschritt
// -------------------------------------------------------
function infoFuellen() {
    document.getElementById("sessionName").textContent = session.name;
    document.getElementById("szenarioTitel").textContent = session.szenario;
    document.getElementById("phaseText").textContent =
        "Phase " + session.aktuellePhase + "/" + session.gesamtPhasen;

    var prozent = Math.round((session.aktuellePhase / session.gesamtPhasen) * 100);
    document.getElementById("prozentText").textContent = prozent + "%";
    document.getElementById("progressFill").style.width = prozent + "%";
}

// -------------------------------------------------------
// SPIELERLISTE — mit Status-Farben (ST-270)
// -------------------------------------------------------
function spielerFuellen() {
    var tbody = document.getElementById("spielerBody");
    tbody.innerHTML = "";

    for (var i = 0; i < spieler.length; i++) {
        var sp = spieler[i];

        // Status-Klasse je nach Zustand
        var statusKlasse = "status--aktiv";
        if (sp.status === "Inaktiv") {
            statusKlasse = "status--inaktiv";
        } else if (sp.status === "Disconnected") {
            statusKlasse = "status--disconnected";
        }

        var zeile = document.createElement("tr");
        zeile.innerHTML =
            "<td>" + sp.name + "</td>" +
            "<td><span class='rollen-punkt' style='background:" + sp.farbe + ";'></span>" + sp.rolle + "</td>" +
            "<td>" + sp.punkte + "</td>" +
            "<td><span class='status " + statusKlasse + "'>" +
                "<span class='status__punkt'></span>" + sp.status + "</span></td>";

        tbody.appendChild(zeile);
    }
}

// -------------------------------------------------------
// AKTIONEN-LOG (letzte 10)
// -------------------------------------------------------
function aktionenFuellen() {
    var liste = document.getElementById("aktionenListe");
    liste.innerHTML = "";

    for (var i = 0; i < aktionen.length; i++) {
        var a = aktionen[i];
        var eintrag = document.createElement("div");
        eintrag.className = "aktion-eintrag";
        eintrag.innerHTML =
            "<span>" + a.wer + " — " + a.was + "</span>" +
            "<span class='aktion-eintrag__zeit'>" + a.zeit + "</span>";
        liste.appendChild(eintrag);
    }
}
