/**
 * CyberSpace NIS2 — Registrierung
 * SCRUM-57: ST-4 Frontend Formular Karen
 * SCRUM-71: ST-5 Fehlermeldungen UI Passwort
 *
 * Mock-Up Slide 2: 4 Felder (Vorname, Nachname, E-Mail, Passwort)
 * Alle neuen Benutzer starten als SPIELER
 */

'use strict';

document.addEventListener('DOMContentLoaded', function() {

  var form = document.getElementById('registerForm');
  var vorname = document.getElementById('vorname');
  var nachname = document.getElementById('nachname');
  var email = document.getElementById('email');
  var passwort = document.getElementById('passwort');
  var submitBtn = document.getElementById('submitBtn');

  /* --- Passwort-Stärke live (SCRUM-71) --- */
  passwort.addEventListener('input', function() {
    updatePasswordStrength(this.value);
  });

  /* --- Live-Validierung bei blur --- */
  vorname.addEventListener('blur', function() {
    if (!validateName(this.value)) { setInvalid(this); } else { setValid(this); }
  });

  nachname.addEventListener('blur', function() {
    if (!validateName(this.value)) { setInvalid(this); } else { setValid(this); }
  });

  email.addEventListener('blur', function() {
    if (!validateEmail(this.value)) { setInvalid(this); } else { setValid(this); }
  });

  passwort.addEventListener('blur', function() {
    var result = validatePassword(this.value);
    if (!result.valid) { setInvalid(this, result.errors[0]); } else { setValid(this); }
  });

  /* --- Submit --- */
  form.addEventListener('submit', async function(e) {
    e.preventDefault();
    hideAlerts();
    var isValid = true;

    if (!validateName(vorname.value)) { setInvalid(vorname); isValid = false; } else { setValid(vorname); }
    if (!validateName(nachname.value)) { setInvalid(nachname); isValid = false; } else { setValid(nachname); }
    if (!validateEmail(email.value)) { setInvalid(email); isValid = false; } else { setValid(email); }

    var pwResult = validatePassword(passwort.value);
    if (!pwResult.valid) { setInvalid(passwort, pwResult.errors[0]); isValid = false; } else { setValid(passwort); }

    if (!isValid) return;

    submitBtn.disabled = true;
    submitBtn.textContent = 'Wird erstellt...';

    try {
      var result = await apiRequest('/register', {
        vorname: vorname.value.trim(),
        nachname: nachname.value.trim(),
        email: email.value.trim(),
        passwort: passwort.value
      });

      showAlert('alertSuccess');
      form.reset();
      resetValidation(form);
      updatePasswordStrength('');

      setTimeout(function() { window.location.href = 'login.html'; }, 2000);

    } catch (error) {
      var message = 'Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut.';
      if (error.status === 409) {
        message = 'Diese E-Mail-Adresse ist bereits registriert.';
        setInvalid(email, message);
      } else if (error.message) {
        message = error.message;
      }
      showAlert('alertError', message);
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Registrieren';
    }
  });

});
