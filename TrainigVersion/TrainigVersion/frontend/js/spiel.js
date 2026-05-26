// spiel.js
// CyberSpace NIS2 — Spielrunde (Game-Card + Reactio-Feedback)
// Sprint 4 | US 3.2.1 Entscheidungen treffen | US 3.2.2 Erfolgsfeedback | US 3.2.3 Fehlerfeedback
// SCRUM-151 Game-Card UI, 152 Feedback UI, 159 Success-Screen, 160 Auto-Timer,
//          166 Error-Screen, 167 Sound
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien 2025/2026

// -------------------------------------------------------
// REACTIO-TYPEN — Farbe, Icon, Punkte (Reactio-Kartensystem)
// PositiverSchritt = +50 grün | NegativerSchritt = -30 rot
// Wiederherstellung = +20 orange | Sackgasse = -50 grau
// -------------------------------------------------------

// -------------------------------------------------------
// MOCK-DATEN — Actio-Karten mit je 4 Optionen
// TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
// GET  /api/sessions/{id}/karte        → nächste Actio-Karte (View_SpielverlaufDetail)
// POST /api/sessions/{id}/option       → Option submiten (SP_OptionWaehlen, Actio-Reactio-Logik)
// -------------------------------------------------------
var karten = [
    {
        titel: "Verdächtige Verschlüsselung",
        text: "Ein Mitarbeiter meldet, dass plötzlich alle Dateien verschlüsselt sind und eine Lösegeldforderung erscheint. Was ist der erste Schritt?",
        optionen: [
            { text: "Betroffene Systeme sofort vom Netzwerk trennen", typ: "PositiverSchritt", erklaerung: "Richtig! Die Isolierung verhindert die weitere Ausbreitung der Ransomware.", nis2: "Art. 21 (Risikomanagement)" },
            { text: "Sofort das Lösegeld bezahlen", typ: "NegativerSchritt", erklaerung: "Eine Zahlung garantiert keine Entschlüsselung und ermutigt die Angreifer. Zuerst isolieren und melden.", nis2: "" },
            { text: "System einfach neu starten und abwarten", typ: "Sackgasse", erklaerung: "Ein Neustart kann Beweise vernichten und die Lage verschlimmern. Sackgasse.", nis2: "" },
            { text: "Den Backup-Status überprüfen", typ: "Wiederherstellung", erklaerung: "Eine sinnvolle Wiederherstellungsmaßnahme — aber zuerst sollte isoliert werden.", nis2: "" }
        ]
    },
    {
        titel: "Meldepflicht nach NIS2",
        text: "Die Systeme sind isoliert. Innerhalb welcher Frist muss der erhebliche Sicherheitsvorfall gemäß NIS2 gemeldet werden?",
        optionen: [
            { text: "Frühwarnung innerhalb von 24 Stunden an die Behörde", typ: "PositiverSchritt", erklaerung: "Richtig! NIS2 verlangt eine Frühwarnung binnen 24 Stunden.", nis2: "Art. 23 (Berichtspflichten)" },
            { text: "Den Vorfall gar nicht melden", typ: "NegativerSchritt", erklaerung: "Erhebliche Vorfälle sind meldepflichtig. Nichtmeldung verstößt gegen NIS2.", nis2: "" },
            { text: "Erst nach vollständiger Behebung melden", typ: "Sackgasse", erklaerung: "Zu spät — die Frühwarnung muss früh erfolgen, nicht erst nach der Behebung.", nis2: "" },
            { text: "Nur intern dokumentieren", typ: "NegativerSchritt", erklaerung: "Interne Doku reicht nicht; die zuständige Behörde muss informiert werden.", nis2: "" }
        ]
    },
    {
        titel: "Nachbereitung des Vorfalls",
        text: "Der Vorfall ist eingedämmt und gemeldet. Was gehört zur Nachbereitung?",
        optionen: [
            { text: "Lessons Learned dokumentieren und Maßnahmen ableiten", typ: "PositiverSchritt", erklaerung: "Richtig! Die Nachbereitung verbessert die künftige Reaktionsfähigkeit.", nis2: "Art. 21 (kontinuierliche Verbesserung)" },
            { text: "Den Vorfall vergessen und weitermachen", typ: "Sackgasse", erklaerung: "Ohne Nachbereitung wiederholen sich Fehler. Sackgasse.", nis2: "" },
            { text: "Backups wiederherstellen und Systeme testen", typ: "Wiederherstellung", erklaerung: "Eine gute Wiederherstellungsmaßnahme als Teil der Nachbereitung.", nis2: "" },
            { text: "Alle Logs löschen", typ: "NegativerSchritt", erklaerung: "Logs sind wichtige Beweise und für die Analyse nötig — niemals löschen.", nis2: "" }
        ]
    }
];

// -------------------------------------------------------
// ZUSTAND
// -------------------------------------------------------
var aktuelleKarte = 0;       // Index der aktuellen Karte
var gesamtKarten = karten.length;
var gewaehlteOption = -1;    // -1 = noch nichts gewählt
var punkte = 0;
var autoTimer = null;        // Timer-ID für Auto-Weiter

// -------------------------------------------------------
// SEITE LADEN
// -------------------------------------------------------
window.onload = function() {
    karteAnzeigen();
};

// -------------------------------------------------------
// KARTE ANZEIGEN (US 3.2.1 — Game-Card)
// -------------------------------------------------------
function karteAnzeigen() {
    var karte = karten[aktuelleKarte];
    gewaehlteOption = -1;

    // Phase-Indicator + Punkte
    var phaseNr = aktuelleKarte + 1;
    document.getElementById("phaseIndicator").textContent = "Phase " + phaseNr + "/" + gesamtKarten;
    document.getElementById("punkteAnzeige").textContent = "⭐ " + punkte + " Punkte";

    // Fortschrittsbalken
    var prozent = (aktuelleKarte / gesamtKarten) * 100;
    document.getElementById("progressFill").style.width = prozent + "%";

    // Szenario-Text
    document.getElementById("kartenTitel").textContent = karte.titel;
    document.getElementById("kartenText").textContent = karte.text;

    // Optionen aufbauen (A, B, C, D)
    var buchstaben = ["A", "B", "C", "D"];
    var bereich = document.getElementById("optionen");
    bereich.innerHTML = "";

    for (var i = 0; i < karte.optionen.length; i++) {
        var opt = karte.optionen[i];

        var label = document.createElement("label");
        label.className = "option";
        label.setAttribute("id", "option" + i);
        label.setAttribute("onclick", "optionWaehlen(" + i + ")");

        label.innerHTML =
            "<input type='radio' name='antwort' value='" + i + "'>" +
            "<span class='option__buchstabe'>" + buchstaben[i] + "</span>" +
            "<span class='option__text'>" + opt.text + "</span>";

        bereich.appendChild(label);
    }

    // Bestätigen-Button deaktivieren bis Auswahl
    var btn = document.getElementById("bestaetigenBtn");
    btn.disabled = true;
}

// -------------------------------------------------------
// OPTION WÄHLEN — Markierung + Button aktivieren
// -------------------------------------------------------
function optionWaehlen(index) {
    gewaehlteOption = index;

    // Alle Markierungen zurücksetzen, dann die gewählte markieren
    var karte = karten[aktuelleKarte];
    for (var i = 0; i < karte.optionen.length; i++) {
        var label = document.getElementById("option" + i);
        if (i === index) {
            label.className = "option option--gewaehlt";
        } else {
            label.className = "option";
        }
    }

    // Radio-Button setzen
    var radios = document.getElementsByName("antwort");
    radios[index].checked = true;

    // Bestätigen aktivieren
    document.getElementById("bestaetigenBtn").disabled = false;
}

// -------------------------------------------------------
// BESTÄTIGEN — Option auswerten und Feedback zeigen
// -------------------------------------------------------
function bestaetigen() {
    if (gewaehlteOption === -1) {
        return;
    }

    var opt = karten[aktuelleKarte].optionen[gewaehlteOption];

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // POST /api/sessions/{id}/option {karteId, optionId}
    // → Backend (SP_OptionWaehlen) liefert Reactio-Typ und Punkte zurück
    console.warn("Mock-Modus: Option gewählt:", opt);

    feedbackAnzeigen(opt);
}

// -------------------------------------------------------
// FEEDBACK ANZEIGEN (US 3.2.2 Success / US 3.2.3 Error)
// Setzt Farbe, Icon, Punkte, Erklärung je nach Reactio-Typ
// -------------------------------------------------------
function feedbackAnzeigen(opt) {
    var box = document.getElementById("feedbackBox");
    var icon = "✅";
    var titel = "Richtig!";
    var punkteAenderung = 0;
    var farbKlasse = "";
    var positiv = false;

    if (opt.typ === "PositiverSchritt") {
        icon = "✅"; titel = "Richtig!"; punkteAenderung = 50; farbKlasse = "feedback--positiv"; positiv = true;
    } else if (opt.typ === "NegativerSchritt") {
        icon = "❌"; titel = "Fehler!"; punkteAenderung = -30; farbKlasse = "feedback--negativ"; positiv = false;
    } else if (opt.typ === "Wiederherstellung") {
        icon = "♻️"; titel = "Wiederherstellung"; punkteAenderung = 20; farbKlasse = "feedback--recovery"; positiv = true;
    } else if (opt.typ === "Sackgasse") {
        icon = "⛔"; titel = "Sackgasse"; punkteAenderung = -50; farbKlasse = "feedback--sackgasse"; positiv = false;
    }

    // Punkte aktualisieren (niemals unter 0)
    punkte = punkte + punkteAenderung;
    if (punkte < 0) {
        punkte = 0;
    }

    // Feedback-Box füllen
    box.className = "feedback " + farbKlasse;
    document.getElementById("feedbackIcon").textContent = icon;
    document.getElementById("feedbackTitel").textContent = titel;

    var vorzeichen = "";
    if (punkteAenderung > 0) {
        vorzeichen = "+";
    }
    document.getElementById("feedbackPunkte").textContent = vorzeichen + punkteAenderung + " Punkte";
    document.getElementById("feedbackText").textContent = opt.erklaerung;

    // NIS2-Referenz nur anzeigen, wenn vorhanden
    var nis2El = document.getElementById("feedbackNis2");
    if (opt.nis2 !== "") {
        nis2El.textContent = "NIS2: " + opt.nis2;
        nis2El.style.display = "block";
    } else {
        nis2El.style.display = "none";
    }

    // Sound-Effekt (optional, ST-167)
    soundAbspielen(positiv);

    // Overlay anzeigen
    document.getElementById("feedbackOverlay").style.display = "flex";

    // Auto-Timer (ST-160): bei positivem Feedback nach 2 Sek automatisch weiter
    if (positiv === true) {
        autoTimer = setTimeout(function() {
            weiter();
        }, 2000);
    }
}

// -------------------------------------------------------
// WEITER — zur nächsten Karte oder zum Ende-Screen
// -------------------------------------------------------
function weiter() {
    // Auto-Timer abbrechen, falls noch aktiv
    if (autoTimer !== null) {
        clearTimeout(autoTimer);
        autoTimer = null;
    }

    document.getElementById("feedbackOverlay").style.display = "none";

    aktuelleKarte = aktuelleKarte + 1;

    if (aktuelleKarte < gesamtKarten) {
        karteAnzeigen();
    } else {
        spielBeenden();
    }
}

// -------------------------------------------------------
// SPIEL BEENDEN — Ergebnis berechnen und weiterleiten
// Victory bei >= 70% der max. Punkte, sonst Game-Over (US 3.3.1 / 3.3.2)
// -------------------------------------------------------
function spielBeenden() {
    document.getElementById("progressFill").style.width = "100%";
    document.getElementById("endePunkte").textContent = punkte + " Punkte";
    document.getElementById("endeOverlay").style.display = "flex";

    // Maximal mögliche Punkte: pro Karte +50 (positiver Schritt)
    var maxPunkte = gesamtKarten * 50;
    var prozent = (punkte / maxPunkte) * 100;

    // TODO: echten API-Aufruf einbauen wenn Ekatherines Backend fertig ist
    // POST /api/sessions/{id}/auswertung  (SP_VictoryBerechnen / SP_GameOverVerarbeiten)
    console.warn("Mock-Modus: Spiel beendet. Punkte:", punkte, "von", maxPunkte);

    // Nach kurzer Anzeige zum passenden Ergebnis-Screen weiterleiten
    setTimeout(function() {
        if (prozent >= 70) {
            window.location.href = "victory.html?punkte=" + punkte + "&max=" + maxPunkte;
        } else {
            window.location.href = "game-over.html?punkte=" + punkte + "&max=" + maxPunkte;
        }
    }, 2500);
}

// -------------------------------------------------------
// SOUND-EFFEKT (optional, ST-167) — einfaches Audio-Element
// Lege dazu zwei kurze Sound-Dateien unter frontend/sounds/ ab:
//   erfolg.mp3 (positiv) und fehler.mp3 (negativ).
// Sind keine Dateien vorhanden, passiert einfach nichts.
// -------------------------------------------------------
function soundAbspielen(positiv) {
    var sound;
    if (positiv === true) {
        sound = document.getElementById("soundErfolg");
    } else {
        sound = document.getElementById("soundFehler");
    }

    if (sound) {
        sound.play();
    }
}
