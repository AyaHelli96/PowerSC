// game-over.js
// CyberSpace NIS2 — Game-Over-Screen
// Sprint 5 | US 3.3.2 (SCRUM-221 Game Over Screen UI, 222 Verbesserungshinweis UI)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// SEITE LADEN — Punkte aus der URL lesen und anzeigen
// (spiel.js leitet z.B. so weiter: game-over.html?punkte=320&max=1000)
// -------------------------------------------------------
window.onload = function() {
    var punkte = parseInt(getParameter("punkte"));
    var max = parseInt(getParameter("max"));

    // Falls keine Werte übergeben wurden: Mock-Werte
    if (isNaN(punkte)) {
        punkte = 320;
    }
    if (isNaN(max) || max === 0) {
        max = 1000;
    }

    // Compliance-Prozent berechnen
    var prozent = Math.round((punkte / max) * 100);

    document.getElementById("ergebnisPunkte").textContent = punkte + "/" + max;
    document.getElementById("ergebnisCompliance").textContent = prozent + "% NIS2-Compliance";

    // Verbesserungshinweis anzeigen (gleiche Logik wie View_GameOverAnalyse)
    document.getElementById("verbesserungText").textContent = holeHinweis(prozent);
};

// -------------------------------------------------------
// VERBESSERUNGSHINWEIS — je nach Compliance-Prozent (ST-222)
// -------------------------------------------------------
function holeHinweis(prozent) {
    if (prozent < 30) {
        return "Kritisch: Grundlagen NIS2 wiederholen.";
    } else if (prozent < 50) {
        return "Verbesserungsbedarf: Incident Response trainieren.";
    } else {
        return "Fast geschafft: Feinabstimmung bei den Compliance-Maßnahmen.";
    }
}

// -------------------------------------------------------
// URL-PARAMETER auslesen (z.B. ?punkte=320)
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
function nochmal() {
    window.location.href = "spiel.html";
}

function zurueck() {
    window.location.href = "spieler-dashboard.html";
}
