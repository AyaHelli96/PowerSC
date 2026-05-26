// spieler-dashboard.js
// CyberSpace NIS2 — Spieler Dashboard (Verfügbare Szenarien)
// Sprint 3 | US 3.1.1 (SCRUM-140 Szenario-Auswahl, 141 Card Design, 142 Filter)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// MOCK-DATEN — aktive Szenarien
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/szenarien/aktiv  → liefert View_AktiveSzenarien
// -------------------------------------------------------
var szenarien = [
    {
        id: 1, titel: "Ransomware-Angriff NIS2 v2",
        beschreibung: "Ein Verschlüsselungs-Trojaner legt die Systeme lahm. Reagiere richtig nach NIS2.",
        schwierigkeit: "Schwer", dauer: 45, phasen: 5, maxSpieler: 6, nis2: "Art. 21, 23"
    },
    {
        id: 2, titel: "Phishing-Welle",
        beschreibung: "Mitarbeiter erhalten gefälschte E-Mails. Erkenne und melde den Vorfall.",
        schwierigkeit: "Einfach", dauer: 25, phasen: 3, maxSpieler: 4, nis2: "Art. 21"
    },
    {
        id: 3, titel: "Datenleck Kundendaten",
        beschreibung: "Sensible Kundendaten sind abgeflossen. Meldepflichten und Eindämmung.",
        schwierigkeit: "Mittel", dauer: 35, phasen: 4, maxSpieler: 5, nis2: "Art. 23"
    }
];

// -------------------------------------------------------
// SEITE LADEN — Karten aufbauen
// -------------------------------------------------------
window.onload = function() {
    kartenAufbauen(szenarien);
};

// -------------------------------------------------------
// KARTEN AUFBAUEN — eine Karte pro Szenario (ST-7 Card Design)
// -------------------------------------------------------
function kartenAufbauen(liste) {
    var raster = document.getElementById("szenarioRaster");
    raster.innerHTML = "";

    for (var i = 0; i < liste.length; i++) {
        var s = liste[i];
        var badgeKlasse = "schwierigkeit-badge--" + s.schwierigkeit.toLowerCase();

        var karte = document.createElement("div");
        karte.className = "szenario-karte";

        karte.innerHTML =
            "<div class='szenario-karte__kopf'>" +
                "<h2 class='szenario-karte__titel'>" + s.titel + "</h2>" +
                "<span class='schwierigkeit-badge " + badgeKlasse + "'>" + s.schwierigkeit + "</span>" +
            "</div>" +
            "<p class='szenario-karte__text'>" + s.beschreibung + "</p>" +
            "<div class='szenario-karte__meta'>" +
                "<span class='meta-info'>⏱️ " + s.dauer + " Min</span>" +
                "<span class='meta-info'>📑 " + s.phasen + " Phasen</span>" +
                "<span class='meta-info'>👥 max. " + s.maxSpieler + "</span>" +
            "</div>" +
            "<div class='nis2-hinweis'>NIS2: " + s.nis2 + "</div>" +
            "<button class='btn btn--success btn--block' onclick='auswaehlen(" + s.id + ")'>Beitreten</button>";

        raster.appendChild(karte);
    }

    pruefeLeer(liste.length);
}

// -------------------------------------------------------
// FILTER ANWENDEN — Suche + Schwierigkeit (ST-8)
// -------------------------------------------------------
function filterAnwenden() {
    var suchtext = document.getElementById("suchfeld").value.toLowerCase();
    var schwierigkeit = document.getElementById("schwierigkeitFilter").value;

    var gefiltert = [];
    for (var i = 0; i < szenarien.length; i++) {
        var s = szenarien[i];
        var titelPasst = s.titel.toLowerCase().indexOf(suchtext) >= 0;
        var schwierigkeitPasst = (schwierigkeit === "" || s.schwierigkeit === schwierigkeit);

        if (titelPasst && schwierigkeitPasst) {
            gefiltert[gefiltert.length] = s;
        }
    }

    kartenAufbauen(gefiltert);
}

// -------------------------------------------------------
// SZENARIO AUSWÄHLEN — weiter zur Rollenauswahl (US 2.3.1)
// -------------------------------------------------------
function auswaehlen(id) {
    window.location.href = "rollenauswahl.html?szenario=" + id;
}

// -------------------------------------------------------
// ABMELDEN
// -------------------------------------------------------
function abmelden() {
    localStorage.removeItem("nis2_token");
    localStorage.removeItem("nis2_rolle");
    sessionStorage.removeItem("nis2_token");
    sessionStorage.removeItem("nis2_rolle");
    window.location.href = "login.html";
}

// -------------------------------------------------------
// HILFSFUNKTION — Meldung wenn keine Ergebnisse
// -------------------------------------------------------
function pruefeLeer(anzahl) {
    var keineMsg = document.getElementById("keineErgebnisse");
    if (anzahl === 0) {
        keineMsg.style.display = "block";
    } else {
        keineMsg.style.display = "none";
    }
}
