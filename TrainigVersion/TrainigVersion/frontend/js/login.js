/**
 * CyberSpace NIS2 — Login
 * SCRUM-64: ST-6 Login Formular Karen
 * SCRUM-65: ST-7 Fehlermeldungen Karen
 *
 * Mock-Up Slide 3: E-Mail + Passwort + Angemeldet bleiben
 * Nach 3 Fehlversuchen: 5-Minuten-Sperre
 * Weiterleitung nach Rolle
 */

'use strict';

document.addEventListener('DOMContentLoaded', function() {

  var form = document.getElementById('loginForm');
  var email = document.getElementById('email');
  var passwort = document.getElementById('passwort');
  var submitBtn = document.getElementById('submitBtn');

  /* ============================================================================
     SPERRE NACH 3 FEHLVERSUCHEN (SCRUM-65)
     ============================================================================ */
  var MAX_VERSUCHE = 3;
  var SPERR_DAUER_MS = 5 * 60 * 1000;

  function getLoginState() {
    var stored = localStorage.getItem('nis2_login_state');
    return stored ? JSON.parse(stored) : { versuche: 0, gesperrtBis: null };
  }

  function saveLoginState(state) {
    localStorage.setItem('nis2_login_state', JSON.stringify(state));
  }

  function clearLoginState() {
    localStorage.removeItem('nis2_login_state');
  }

  function isGesperrt() {
    var state = getLoginState();
    if (state.gesperrtBis) {
      if (Date.now() < state.gesperrtBis) return true;
      clearLoginState();
    }
    return false;
  }

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

  function showLockScreen() {
    hideAlerts();
    document.getElementById('alertLocked').classList.add('show');
    submitBtn.disabled = true;
    email.disabled = true;
    passwort.disabled = true;
    startLockTimer();
  }

  function startLockTimer() {
    var state = getLoginState();
    if (!state.gesperrtBis) return;
    var timerEl = document.getElementById('lockTimer');

    var interval = setInterval(function() {
      var rest = state.gesperrtBis - Date.now();
      if (rest <= 0) {
        clearInterval(interval);
        clearLoginState();
        hideAlerts();
        submitBtn.disabled = false;
        email.disabled = false;
        passwort.disabled = false;
        return;
      }
      var min = Math.floor(rest / 60000);
      var sek = Math.floor((rest % 60000) / 1000);
      timerEl.textContent = min + ':' + (sek < 10 ? '0' : '') + sek;
    }, 1000);
  }

  // Beim Laden prüfen
  if (isGesperrt()) showLockScreen();

  /* ============================================================================
     WEITERLEITUNG NACH ROLLE
     ============================================================================ */
  var REDIRECT_MAP = {
    'SPIELER':       '/pages/spieler-dashboard.html',
    'MODERATOR':     '/pages/moderator-dashboard.html',
    'ADMINISTRATOR': '/pages/admin-dashboard.html'
  };

  /* ============================================================================
     FORMULAR
     ============================================================================ */
  email.addEventListener('blur', function() {
    if (!validateEmail(this.value)) { setInvalid(this); } else { setValid(this); }
  });

  passwort.addEventListener('blur', function() {
    if (!this.value) { setInvalid(this); } else { setValid(this); }
  });

  form.addEventListener('submit', async function(e) {
    e.preventDefault();
    hideAlerts();

    if (isGesperrt()) { showLockScreen(); return; }

    var isValid = true;
    if (!validateEmail(email.value)) { setInvalid(email); isValid = false; } else { setValid(email); }
    if (!passwort.value) { setInvalid(passwort); isValid = false; } else { setValid(passwort); }
    if (!isValid) return;

    submitBtn.disabled = true;
    submitBtn.textContent = 'Wird angemeldet...';

    try {
      var result = await apiRequest('/login', {
        email: email.value.trim(),
        passwort: passwort.value,
        angemeldetBleiben: document.getElementById('rememberMe').checked
      });

      clearLoginState();

      // Token speichern
      if (result.token) {
        var storage = document.getElementById('rememberMe').checked ? localStorage : sessionStorage;
        storage.setItem('nis2_token', result.token);
        storage.setItem('nis2_rolle', result.rolle);
      }

      showAlert('alertSuccess');

      setTimeout(function() {
        var url = REDIRECT_MAP[result.rolle] || '/pages/spieler-dashboard.html';
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
      submitBtn.disabled = false;
      submitBtn.textContent = 'Anmelden';
    }
  });

});
