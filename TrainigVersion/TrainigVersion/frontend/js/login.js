// login.js
// CyberSpace NIS2 – Login Formular
// SCRUM-64: Login Formular | SCRUM-65: Fehlermeldungen
// Nach 3 Fehlversuchen wird das Konto 5 Minuten gesperrt
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien | 2025/2026

'use strict';

document.addEventListener('DOMContentLoaded', function() {

    var form      = document.getElementById('loginForm');
    var email     = document.getElementById('email');
    var passwort  = document.getElementById('passwort');
    var submitBtn = document.getElementById('submitBtn');

    // Maximale Fehlversuche und Sperrdauer
    var MAX_VERSUCHE   = 3;
    var SPERR_DAUER_MS = 5 * 60 * 1000; // 5 Minuten in Millisekunden

    // -------------------------------------------------------
    // Login-Zustand im localStorage lesen
    // -------------------------------------------------------
    function getLoginState() {
        var stored = localStorage.getItem('nis2_login_state');
        return stored ? JSON.parse(stored) : { versuche: 0, gesperrtBis: null };
    }

    // -------------------------------------------------------
    // Login-Zustand im localStorage speichern
    // -------------------------------------------------------
    function saveLoginState(state) {
        localStorage.setItem('nis2_login_state', JSON.stringify(state));
    }

    // -------------------------------------------------------
    // Login-Zustand löschen (nach erfolgreichem Login)
    // -------------------------------------------------------
    function clearLoginState() {
        localStorage.removeItem('nis2_login_state');
    }

    // -------------------------------------------------------
    // Prüfen ob das Konto gesperrt ist
    // -------------------------------------------------------
    function isGesperrt() {
        var state = getLoginState();
        if (state.gesperrtBis) {
            if (Date.now() < state.gesperrtBis) return true;
            clearLoginState();
        }
        return false;
    }

    // -------------------------------------------------------
    // Fehlversuch registrieren
    // Ab 3 Versuchen: Konto sperren
    // -------------------------------------------------------
    function registerFailedAttempt() {
        var state = getLoginState();
        state.versuche++;

        if (state.versuche >= MAX_VERSUCHE) {
            state.gesperrtBis = Date.now() + SPERR_DAUER_MS;
            saveLoginState(state);
            showLockScreen();
        } else {
            saveLoginState(state);
            var rest = MAX_VERSUCHE - state.versuche;
            showAlert('alertError', 'E-Mail oder Passwort falsch. Noch ' + rest + ' Versuch(e).');
        }
    }

    // -------------------------------------------------------
    // Sperrbildschirm anzeigen und Formular deaktivieren
    // -------------------------------------------------------
    function showLockScreen() {
        hideAlerts();
        document.getElementById('alertLocked').classList.add('show');
        submitBtn.disabled = true;
        email.disabled     = true;
        passwort.disabled  = true;
        startLockTimer();
    }

    // -------------------------------------------------------
    // Countdown-Timer für die Sperre starten
    // -------------------------------------------------------
    function startLockTimer() {
        var state   = getLoginState();
        if (!state.gesperrtBis) return;

        var timerEl  = document.getElementById('lockTimer');

        var interval = setInterval(function() {
            var rest = state.gesperrtBis - Date.now();

            if (rest <= 0) {
                clearInterval(interval);
                clearLoginState();
                hideAlerts();
                submitBtn.disabled = false;
                email.disabled     = false;
                passwort.disabled  = false;
                return;
            }

            var min = Math.floor(rest / 60000);
            var sek = Math.floor((rest % 60000) / 1000);
            timerEl.textContent = min + ':' + (sek < 10 ? '0' : '') + sek;

        }, 1000);
    }

    // Beim Laden der Seite prüfen ob Sperre noch aktiv
    if (isGesperrt()) showLockScreen();

    // -------------------------------------------------------
    // Weiterleitung nach Rolle (Pfade relativ zu /pages/)
    // -------------------------------------------------------
    var REDIRECT_MAP = {
        'SPIELER':       'spieler-dashboard.html',
        'MODERATOR':     'moderator-dashboard.html',
        'ADMINISTRATOR': 'admin-dashboard.html'
    };

    // -------------------------------------------------------
    // Live-Validierung beim Verlassen der Felder
    // -------------------------------------------------------
    email.addEventListener('blur', function() {
        if (!validateEmail(this.value)) setInvalid(this);
        else setValid(this);
    });

    passwort.addEventListener('blur', function() {
        if (!this.value) setInvalid(this);
        else setValid(this);
    });

    // -------------------------------------------------------
    // Formular absenden
    // -------------------------------------------------------
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        hideAlerts();

        // Nochmal prüfen ob gesperrt
        if (isGesperrt()) { showLockScreen(); return; }

        // Clientseitige Validierung
        var isValid = true;

        if (!validateEmail(email.value)) { setInvalid(email);   isValid = false; }
        else setValid(email);

        if (!passwort.value) { setInvalid(passwort); isValid = false; }
        else setValid(passwort);

        if (!isValid) return;

        // Button deaktivieren während Anfrage läuft
        submitBtn.disabled    = true;
        submitBtn.textContent = 'Wird angemeldet...';

        try {
            var result = await apiRequest('/login', {
                email:             email.value.trim(),
                passwort:          passwort.value,
                angemeldetBleiben: document.getElementById('rememberMe').checked
            });

            clearLoginState();

            // Token speichern: localStorage wenn "Angemeldet bleiben", sonst sessionStorage
            if (result.token) {
                var storage = document.getElementById('rememberMe').checked
                    ? localStorage
                    : sessionStorage;
                storage.setItem('nis2_token', result.token);
                storage.setItem('nis2_rolle', result.rolle);
            }

            showAlert('alertSuccess');

            // Nach 1 Sekunde weiterleiten
            setTimeout(function() {
                var url = REDIRECT_MAP[result.rolle] || 'spieler-dashboard.html';
                window.location.href = url;
            }, 1000);

        } catch (error) {
            if (error.status === 401) {
                registerFailedAttempt();
            } else if (error.status === 423) {
                showAlert('alertLocked', error.message);
            } else {
                showAlert('alertError', error.message || 'Ein Fehler ist aufgetreten.');
            }
        } finally {
            // Button nur reaktivieren wenn Konto NICHT gesperrt
            if (!isGesperrt()) {
                submitBtn.disabled    = false;
                submitBtn.textContent = 'Anmelden';
            }
        }
    });

});
