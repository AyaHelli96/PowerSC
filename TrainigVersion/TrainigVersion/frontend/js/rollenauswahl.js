// rollenauswahl.js
// CyberSpace NIS2 — Rollenauswahl (Spieler)
// Sprint 3 | US 2.3.1 (SCRUM-131 Screen, 132 Rollen-Karte Design, 133 Weiterleitung)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// MOCK-DATEN — verfügbare/vergebene Rollen
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/sessions/{id}/rollen  → liefert View_VerfuegbareRollen
// -------------------------------------------------------
var rollen = [
    { id: 1, name: "IT-Leitung",       beschreibung: "Leitet die technische Reaktion auf den Vorfall.", farbe: "#3498DB", status: "Verfuegbar" },
    { id: 2, name: "Kommunikation",    beschreibung: "Verantwortlich für interne und externe Meldungen.", farbe: "#2ECC71", status: "Verfuegbar" },
    { id: 3, name: "Geschäftsführung", beschreibung: "Trifft strategische Entscheidungen im Krisenfall.", farbe: "#C0392B", status: "Vergeben" },
    { id: 4, name: "Rechtsabteilung",  beschreibung: "Prüft Meldepflichten nach NIS2 (Art. 23).", farbe: "#8E44AD", status: "Verfuegbar" },
    { id: 5, name: "Protokollführung", beschreibung: "Dokumentiert alle Schritte des Incident Response.", farbe: "#95A5A6", status: "Verfuegbar" }
];

var szenarioId = "";

// -------------------------------------------------------
// SEITE LADEN — Szenario-ID aus URL lesen, Rollen anzeigen
// -------------------------------------------------------
window.onload = function() {
    szenarioId = getParameter("szenario");
    rollenAufbauen();
};

// -------------------------------------------------------
// URL-PARAMETER auslesen (z.B. ?szenario=1)
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
// ROLLEN AUFBAUEN — eine Karte pro Rolle (ST-6 Rollen-Karte Design)
// -------------------------------------------------------
function rollenAufbauen() {
    var raster = document.getElementById("rollenRaster");
    raster.innerHTML = "";

    for (var i = 0; i < rollen.length; i++) {
        var r = rollen[i];
        var verfuegbar = (r.status === "Verfuegbar");

        var karte = document.createElement("div");
        karte.className = "rollen-karte";
        karte.style.borderLeftColor = r.farbe;

        if (verfuegbar) {
            karte.className = karte.className + " rollen-karte--verfuegbar";
        } else {
            karte.className = karte.className + " rollen-karte--vergeben";
        }

        // Status-Text + Button je nach Verfügbarkeit
        var statusHtml = "";
        var buttonHtml = "";
        if (verfuegbar) {
            statusHtml = "<div class='rollen-status rollen-status--verfuegbar'>Verfügbar</div>";
            buttonHtml = "<button class='btn btn--success btn--block' onclick='rolleWaehlen(" + r.id + ")'>Auswählen</button>";
        } else {
            statusHtml = "<div class='rollen-status rollen-status--vergeben'>Vergeben</div>";
            buttonHtml = "<button class='btn btn--success btn--block' disabled>Nicht verfügbar</button>";
        }

        karte.innerHTML =
            "<div class='rollen-karte__kopf'>" +
                "<span class='rollen-punkt' style='background:" + r.farbe + ";'></span>" +
                "<h2 class='rollen-karte__name'>" + r.name + "</h2>" +
            "</div>" +
            "<p class='rollen-karte__text'>" + r.beschreibung + "</p>" +
            statusHtml +
            buttonHtml;

        raster.appendChild(karte);
    }
}

// -------------------------------------------------------
// ROLLE WÄHLEN — Auswahl bestätigen (ST-7 Weiterleitung nach Wahl)
// -------------------------------------------------------
function rolleWaehlen(id) {
    var gewaehlt = null;
    for (var i = 0; i < rollen.length; i++) {
        if (rollen[i].id === id) {
            gewaehlt = rollen[i];
        }
    }

    if (gewaehlt === null) {
        return;
    }

    var daten = {
        szenarioId: szenarioId,
        rolleId: gewaehlt.id
    };

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // POST /api/sessions/{id}/rolle-waehlen  (ruft SP_RolleVergeben auf)
    // apiRequest("POST", "/api/sessions/rolle-waehlen", daten, ...);
    console.warn("Mock-Modus: Rolle gewählt:", daten);

    // Bestätigung anzeigen
    document.getElementById("gewaehlteRolle").textContent = gewaehlt.name;
    document.getElementById("bestaetigung").style.display = "flex";

    // TODO (Sprint 4): nach kurzer Wartezeit zum Spiel-Screen weiterleiten
    // setTimeout(function() { window.location.href = "spiel.html?session=" + sessionId; }, 2000);
}
