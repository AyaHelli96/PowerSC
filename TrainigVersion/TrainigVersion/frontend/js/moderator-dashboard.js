// moderator-dashboard.js
// CyberSpace NIS2 — Moderator Dashboard
// Sprint 3 | US 2.1.1: Session-Übersicht des Moderators
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

var sortRichtung = "asc";
var sortSpalte = "";

// -------------------------------------------------------
// MOCK-DATEN — Sessions des Moderators
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/sessions/moderator  → liefert View_ModeratorSessions
// -------------------------------------------------------
var sessions = [
    { id: 1, name: "Schulung IT-Team",      szenario: "Ransomware-Angriff NIS2 v2", status: "Aktiv",    spieler: 4 },
    { id: 2, name: "Onboarding Abteilung A", szenario: "Phishing-Welle",             status: "Warten",   spieler: 2 },
    { id: 3, name: "Übung Krisenstab",       szenario: "Datenleck Kundendaten",      status: "Pausiert", spieler: 5 },
    { id: 4, name: "Workshop Q1",            szenario: "Ransomware-Angriff NIS2 v1", status: "Beendet",  spieler: 6 }
];

// -------------------------------------------------------
// SEITE LADEN — Tabelle aufbauen
// -------------------------------------------------------
window.onload = function() {
    tabelleAufbauen();
};

// -------------------------------------------------------
// TABELLE AUFBAUEN — eine Zeile pro Session
// -------------------------------------------------------
function tabelleAufbauen() {
    var tbody = document.getElementById("tabellBody");
    tbody.innerHTML = "";

    for (var i = 0; i < sessions.length; i++) {
        var s = sessions[i];
        var statusKlasse = "status-badge--" + s.status.toLowerCase();

        var zeile = document.createElement("tr");
        zeile.setAttribute("data-name", s.name);
        zeile.setAttribute("data-szenario", s.szenario);
        zeile.setAttribute("data-status", s.status.toLowerCase());

        zeile.innerHTML =
            "<td class='titel-zelle'>" + s.name + "</td>" +
            "<td>" + s.szenario + "</td>" +
            "<td><span class='status-badge " + statusKlasse + "'>" + s.status + "</span></td>" +
            "<td class='zahl-zelle'>" + s.spieler + "</td>" +
            "<td class='aktionen-zelle'>" +
                "<button class='aktion-btn' title='Öffnen / Steuern' onclick='oeffnen(" + s.id + ")'>▶️</button>" +
                "<button class='aktion-btn' title='Spieler einladen' onclick='einladen(" + s.id + ")'>📋</button>" +
            "</td>";

        tbody.appendChild(zeile);
    }

    pruefeLeer();
}

// -------------------------------------------------------
// SUCHE — filtert Tabelle in Echtzeit
// -------------------------------------------------------
function filterTabelle(suchtext) {
    var tbody = document.getElementById("tabellBody");
    var zeilen = tbody.getElementsByTagName("tr");
    var anzahlSichtbar = 0;

    suchtext = suchtext.toLowerCase();

    for (var i = 0; i < zeilen.length; i++) {
        var name = zeilen[i].getAttribute("data-name").toLowerCase();

        if (name.indexOf(suchtext) >= 0) {
            zeilen[i].style.display = "";
            anzahlSichtbar = anzahlSichtbar + 1;
        } else {
            zeilen[i].style.display = "none";
        }
    }

    var keineMsg = document.getElementById("keineErgebnisse");
    if (anzahlSichtbar === 0) {
        keineMsg.style.display = "block";
    } else {
        keineMsg.style.display = "none";
    }
}

// -------------------------------------------------------
// SORTIERUNG — Bubble Sort nach Spalte
// -------------------------------------------------------
function sortieren(spalte) {
    if (sortSpalte === spalte && sortRichtung === "asc") {
        sortRichtung = "desc";
    } else {
        sortRichtung = "asc";
    }
    sortSpalte = spalte;

    var tbody = document.getElementById("tabellBody");
    var zeilen = tbody.getElementsByTagName("tr");

    // Zeilen in normales Array kopieren
    var zeilenArray = [];
    for (var i = 0; i < zeilen.length; i++) {
        zeilenArray[i] = zeilen[i];
    }

    // Bubble Sort
    for (var a = 0; a < zeilenArray.length - 1; a++) {
        for (var b = 0; b < zeilenArray.length - 1 - a; b++) {
            var wertA = "";
            var wertB = "";

            if (spalte === "name") {
                wertA = zeilenArray[b].getAttribute("data-name").toLowerCase();
                wertB = zeilenArray[b + 1].getAttribute("data-name").toLowerCase();
            } else if (spalte === "szenario") {
                wertA = zeilenArray[b].getAttribute("data-szenario").toLowerCase();
                wertB = zeilenArray[b + 1].getAttribute("data-szenario").toLowerCase();
            } else if (spalte === "status") {
                wertA = zeilenArray[b].getAttribute("data-status").toLowerCase();
                wertB = zeilenArray[b + 1].getAttribute("data-status").toLowerCase();
            }

            var tauschen = false;
            if (sortRichtung === "asc" && wertA > wertB) {
                tauschen = true;
            }
            if (sortRichtung === "desc" && wertA < wertB) {
                tauschen = true;
            }

            if (tauschen) {
                var temp = zeilenArray[b];
                zeilenArray[b] = zeilenArray[b + 1];
                zeilenArray[b + 1] = temp;
            }
        }
    }

    // Sortierte Zeilen wieder einfügen
    for (var j = 0; j < zeilenArray.length; j++) {
        tbody.appendChild(zeilenArray[j]);
    }
}

// -------------------------------------------------------
// AKTIONEN
// -------------------------------------------------------
function oeffnen(id) {
    // Session-Steuerung öffnen (Phase steuern, starten, pausieren, beenden)
    window.location.href = "session-steuerung.html?id=" + id;
}

function einladen(id) {
    // TODO: Einladungs-Dialog wenn Backend fertig ist (Tabelle Einladung)
    alert("Spieler zu Session " + id + " einladen (folgt in Sprint 4).");
}

function abmelden() {
    // Token löschen und zurück zum Login
    localStorage.removeItem("nis2_token");
    localStorage.removeItem("nis2_rolle");
    sessionStorage.removeItem("nis2_token");
    sessionStorage.removeItem("nis2_rolle");
    window.location.href = "login.html";
}

// -------------------------------------------------------
// HILFSFUNKTION — Meldung wenn keine Sessions vorhanden
// -------------------------------------------------------
function pruefeLeer() {
    var keineMsg = document.getElementById("keineErgebnisse");
    if (sessions.length === 0) {
        keineMsg.style.display = "block";
    } else {
        keineMsg.style.display = "none";
    }
}
