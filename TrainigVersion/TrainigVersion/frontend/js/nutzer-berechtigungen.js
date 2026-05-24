// nutzer-berechtigungen.js
// CyberSpace NIS2 — Formular F-009: Nutzer-Berechtigungen
// Sprint 6 | US 0.3.1 (SCRUM-260 F-009 UI, 261 Letzter-Admin-Warnung)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// MOCK-DATEN — Benutzerliste
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/benutzer  → View_BenutzerUebersicht (nur für Admins)
// -------------------------------------------------------
var benutzer = [
    { id: 1, name: "Karen Garcia",    email: "karen@htl.at",   rolle: "ADMINISTRATOR", registriert: "01.02.2026" },
    { id: 2, name: "Ekaterine Hahna", email: "eka@htl.at",     rolle: "ADMINISTRATOR", registriert: "01.02.2026" },
    { id: 3, name: "Aya Helli",       email: "aya@htl.at",     rolle: "MODERATOR",     registriert: "03.02.2026" },
    { id: 4, name: "Max Mustermann",  email: "max@firma.at",   rolle: "SPIELER",       registriert: "10.03.2026" },
    { id: 5, name: "Erika Beispiel",  email: "erika@firma.at", rolle: "SPIELER",       registriert: "12.03.2026" }
];

// ID des aktuell eingeloggten Benutzers (Mock: Karen)
var eigeneId = 1;

// -------------------------------------------------------
// SEITE LADEN — Tabelle aufbauen
// -------------------------------------------------------
window.onload = function() {
    tabelleAufbauen();
};

// -------------------------------------------------------
// TABELLE AUFBAUEN — eine Zeile pro Benutzer
// -------------------------------------------------------
function tabelleAufbauen() {
    var tbody = document.getElementById("nutzerBody");
    tbody.innerHTML = "";

    var rollen = ["SPIELER", "MODERATOR", "ADMINISTRATOR"];

    for (var i = 0; i < benutzer.length; i++) {
        var b = benutzer[i];

        // Dropdown-Optionen bauen, aktuelle Rolle vorausgewählt
        var optionenHtml = "";
        for (var j = 0; j < rollen.length; j++) {
            var selected = "";
            if (rollen[j] === b.rolle) {
                selected = " selected";
            }
            optionenHtml = optionenHtml + "<option value='" + rollen[j] + "'" + selected + ">" + rollen[j] + "</option>";
        }

        var zeile = document.createElement("tr");
        zeile.innerHTML =
            "<td>" + b.name + "</td>" +
            "<td>" + b.email + "</td>" +
            "<td>" + b.registriert + "</td>" +
            "<td><select class='rolle-select' id='rolle" + b.id + "'>" + optionenHtml + "</select></td>" +
            "<td><button class='aendern-btn' onclick='berechtigungAendern(" + b.id + ")'>Ändern</button></td>";

        tbody.appendChild(zeile);
    }
}

// -------------------------------------------------------
// BERECHTIGUNG ÄNDERN
// -------------------------------------------------------
function berechtigungAendern(id) {
    var neueRolle = document.getElementById("rolle" + id).value;

    // Passenden Benutzer finden
    var b = null;
    for (var i = 0; i < benutzer.length; i++) {
        if (benutzer[i].id === id) {
            b = benutzer[i];
        }
    }
    if (b === null) {
        return;
    }

    // Schutz: letzter Administrator darf sich nicht selbst herabstufen
    if (id === eigeneId && b.rolle === "ADMINISTRATOR" && neueRolle !== "ADMINISTRATOR") {
        if (anzahlAdmins() <= 1) {
            // Auswahl zurücksetzen und Warnung zeigen
            document.getElementById("rolle" + id).value = "ADMINISTRATOR";
            document.getElementById("adminWarnung").style.display = "flex";
            return;
        }
    }

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // PUT /api/benutzer/{id}/berechtigung  (SP_BerechtigungAendern, TRG_LetzterAdminSchutz)
    console.warn("Mock-Modus: Berechtigung geändert:", b.name, "->", neueRolle);

    b.rolle = neueRolle;
    meldungZeigen(b.name + " ist jetzt " + neueRolle + ".");
}

// -------------------------------------------------------
// ANZAHL der Administratoren zählen
// -------------------------------------------------------
function anzahlAdmins() {
    var anzahl = 0;
    for (var i = 0; i < benutzer.length; i++) {
        if (benutzer[i].rolle === "ADMINISTRATOR") {
            anzahl = anzahl + 1;
        }
    }
    return anzahl;
}

// -------------------------------------------------------
// ERFOLGSMELDUNG anzeigen
// -------------------------------------------------------
function meldungZeigen(text) {
    var alert = document.getElementById("alertSuccess");
    alert.textContent = text;
    alert.classList.add("show");
}

// -------------------------------------------------------
// WARNUNG schließen
// -------------------------------------------------------
function warnungSchliessen() {
    document.getElementById("adminWarnung").style.display = "none";
}
