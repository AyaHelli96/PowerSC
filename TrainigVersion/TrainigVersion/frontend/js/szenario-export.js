// szenario-export.js
// CyberSpace NIS2 — Formular F-008: Szenario exportieren
// Sprint 6 | US 1.5.2 (SCRUM-250 Formular F-008 UI, 251 Download automatisch)
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// MOCK-DATEN — Szenarien zur Auswahl
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET /api/szenarien  → Liste aller Szenarien
// -------------------------------------------------------
var szenarienListe = [
    { id: 1, titel: "Ransomware-Angriff NIS2 v2" },
    { id: 2, titel: "Phishing-Welle" },
    { id: 3, titel: "Datenleck Kundendaten" }
];

// -------------------------------------------------------
// SEITE LADEN — Auswahl befüllen
// -------------------------------------------------------
window.onload = function() {
    var select = document.getElementById("szenario");
    for (var i = 0; i < szenarienListe.length; i++) {
        var option = document.createElement("option");
        option.value = szenarienListe[i].id;
        option.textContent = szenarienListe[i].titel;
        select.appendChild(option);
    }
};

// -------------------------------------------------------
// FORMULAR ABSCHICKEN
// -------------------------------------------------------
document.getElementById("exportForm").onsubmit = function(e) {
    e.preventDefault();

    var select = document.getElementById("szenario");
    if (select.value === "") {
        document.getElementById("szenario").classList.add("is-invalid");
        document.getElementById("szenarioError").style.display = "block";
        return;
    }
    document.getElementById("szenario").classList.remove("is-invalid");
    document.getElementById("szenarioError").style.display = "none";

    exportieren(parseInt(select.value), select.options[select.selectedIndex].text);
};

// -------------------------------------------------------
// EXPORTIEREN — JSON erzeugen und automatisch herunterladen
// -------------------------------------------------------
function exportieren(id, titel) {
    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // GET /api/szenarien/{id}/export  → liefert vollständiges JSON (SP_SzenarioExportDaten)
    // Hier: Mock-JSON mit den wichtigsten Feldern

    var exportObjekt = {
        szenarioId: id,
        titel: titel,
        exportiertAm: new Date().toISOString(),
        karten: [],
        phasen: [],
        rollen: []
    };

    var jsonText = JSON.stringify(exportObjekt, null, 2);

    // Dateiname: [Titel]_[Datum].json
    var datum = new Date();
    var dateiname = titel.replace(/ /g, "_") + "_" + datum.getFullYear() + "-" +
                    (datum.getMonth() + 1) + "-" + datum.getDate() + ".json";

    // Download automatisch starten (ST-251)
    var blob = new Blob([jsonText], { type: "application/json" });
    var url = URL.createObjectURL(blob);
    var link = document.createElement("a");
    link.href = url;
    link.download = dateiname;
    link.click();
    URL.revokeObjectURL(url);

    document.getElementById("alertSuccess").style.display = "block";
}
