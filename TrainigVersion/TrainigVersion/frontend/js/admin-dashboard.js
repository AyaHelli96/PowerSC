// admin-dashboard.js
// CyberSpace NIS2 — Admin Dashboard
// SCRUM-102, SCRUM-103, SCRUM-104, SCRUM-105
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

var sortRichtung = "asc";
var sortSpalte = "";
var loeschenId = null;

// -------------------------------------------------------
// SUCHE — filtert Tabelle in Echtzeit (SCRUM-105)
// -------------------------------------------------------
function filterTabelle(suchtext) {
    var tabelle = document.getElementById("tabellBody");
    var zeilen = tabelle.getElementsByTagName("tr");
    var anzahlSichtbar = 0;

    for (var i = 0; i < zeilen.length; i++) {
        var titel = zeilen[i].getAttribute("data-titel").toLowerCase();
        suchtext = suchtext.toLowerCase();

        if (titel.indexOf(suchtext) >= 0) {
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
// SORTIERUNG — Bubble Sort nach Spalte (SCRUM-105)
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

            if (spalte === "titel") {
                wertA = zeilenArray[b].getAttribute("data-titel").toLowerCase();
                wertB = zeilenArray[b + 1].getAttribute("data-titel").toLowerCase();
            } else if (spalte === "status") {
                wertA = zeilenArray[b].getAttribute("data-status").toLowerCase();
                wertB = zeilenArray[b + 1].getAttribute("data-status").toLowerCase();
            } else if (spalte === "phasen") {
                wertA = parseInt(zeilenArray[b].cells[2].textContent);
                wertB = parseInt(zeilenArray[b + 1].cells[2].textContent);
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

    // Sortierte Zeilen wieder in Tabelle einfügen
    for (var j = 0; j < zeilenArray.length; j++) {
        tbody.appendChild(zeilenArray[j]);
    }
}

// -------------------------------------------------------
// AKTIONS-ICONS (SCRUM-104)
// -------------------------------------------------------
function bearbeiten(id) {
    window.location.href = "szenario-bearbeiten.html?id=" + id;
}

function kopieren(id) {
    alert("Szenario " + id + " wurde kopiert.");
}

function speichern(id) {
    alert("Szenario " + id + " wurde gespeichert.");
}

function loeschen(id) {
    loeschenId = id;
    document.getElementById("loeschDialog").style.display = "flex";
}

function loeschenBestaetigen() {
    if (loeschenId !== null) {
        // TODO: API-Aufruf wenn Ekatherines Backend fertig ist
        alert("Szenario " + loeschenId + " wurde gelöscht.");
        loeschenId = null;
    }
    dialogSchliessen();
}

function dialogSchliessen() {
    document.getElementById("loeschDialog").style.display = "none";
    loeschenId = null;
}

// Escape-Taste schließt Dialog
document.onkeydown = function(e) {
    if (e.key === "Escape") {
        dialogSchliessen();
    }
};
