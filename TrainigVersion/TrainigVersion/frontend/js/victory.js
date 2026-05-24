// victory.js
// CyberSpace NIS2 — Victory-Screen (Sieg)
// Sprint 5 | US 3.3.1 (SCRUM-212 Victory Screen UI)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// SEITE LADEN — Punkte aus der URL lesen und anzeigen
// (spiel.js leitet z.B. so weiter: victory.html?punkte=850&max=1000)
// -------------------------------------------------------
window.onload = function() {
    var punkte = parseInt(getParameter("punkte"));
    var max = parseInt(getParameter("max"));

    // Falls keine Werte übergeben wurden: Mock-Werte
    if (isNaN(punkte)) {
        punkte = 850;
    }
    if (isNaN(max) || max === 0) {
        max = 1000;
    }

    // Compliance-Prozent berechnen
    var prozent = Math.round((punkte / max) * 100);

    document.getElementById("ergebnisPunkte").textContent = punkte + "/" + max;
    document.getElementById("ergebnisCompliance").textContent = prozent + "% NIS2-Compliance";
};

// -------------------------------------------------------
// URL-PARAMETER auslesen (z.B. ?punkte=850)
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
// BUTTONS
// -------------------------------------------------------
function statistiken() {
    // TODO (Sprint 6): zur Statistik-Seite weiterleiten (US 3.5.1)
    alert("Statistiken folgen in einem späteren Sprint.");
}

function neuesSpiel() {
    window.location.href = "spieler-dashboard.html";
}
