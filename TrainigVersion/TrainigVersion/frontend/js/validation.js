// validation.js
// CyberSpace NIS2 – Gemeinsame Validierungsfunktionen
// Wird von login.js und register.js verwendet
// Autorin: Karen Garcia Pinal | HTL Spengergasse Wien | 2025/2026

'use strict';

// Basis-URL der REST API (Ekatherine – ASP.NET Core)
var API_BASE_URL = '/api/auth';

// -------------------------------------------------------
// E-Mail prüfen
// Gibt true zurück wenn die E-Mail gültig ist
// -------------------------------------------------------
function validateEmail(email) {
    var pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return pattern.test(email.trim());
}

// -------------------------------------------------------
// Passwort prüfen
// Gibt ein Objekt zurück: { valid: bool, errors: [] }
// -------------------------------------------------------
function validatePassword(password) {
    var errors = [];

    if (password.length < 8)
        errors.push('Mindestens 8 Zeichen erforderlich');

    if (!/[A-Z]/.test(password))
        errors.push('Mindestens 1 Großbuchstabe erforderlich');

    if (!/[a-z]/.test(password))
        errors.push('Mindestens 1 Kleinbuchstabe erforderlich');

    if (!/[0-9]/.test(password))
        errors.push('Mindestens 1 Zahl erforderlich');

    if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password))
        errors.push('Mindestens 1 Sonderzeichen erforderlich');

    return { valid: errors.length === 0, errors: errors };
}

// -------------------------------------------------------
// Passwortstärke berechnen
// Gibt Stufe zurück: weak / medium / strong
// -------------------------------------------------------
function getPasswordStrength(password) {
    if (!password) return { level: '', text: '', score: 0 };

    var score = 0;

    if (password.length >= 8)  score++;
    if (password.length >= 12) score++;
    if (/[A-Z]/.test(password)) score++;
    if (/[a-z]/.test(password)) score++;
    if (/[0-9]/.test(password)) score++;
    if (/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) score++;

    if (score <= 2) return { level: 'weak',   text: 'Schwach', score: score };
    if (score <= 4) return { level: 'medium', text: 'Mittel',  score: score };
    return               { level: 'strong', text: 'Stark',   score: score };
}

// -------------------------------------------------------
// Name prüfen (min. 2 Zeichen)
// -------------------------------------------------------
function validateName(name) {
    return name.trim().length >= 2;
}

// -------------------------------------------------------
// Eingabefeld als ungültig markieren
// -------------------------------------------------------
function setInvalid(field, message) {
    field.classList.add('is-invalid');
    field.classList.remove('is-valid');

    if (message) {
        var feedback = field.parentElement.querySelector('.invalid-feedback');
        if (feedback) feedback.textContent = message;
    }
}

// -------------------------------------------------------
// Eingabefeld als gültig markieren
// -------------------------------------------------------
function setValid(field) {
    field.classList.remove('is-invalid');
    field.classList.add('is-valid');
}

// -------------------------------------------------------
// Alle Validierungen im Formular zurücksetzen
// -------------------------------------------------------
function resetValidation(form) {
    form.querySelectorAll('.form-control').forEach(function(field) {
        field.classList.remove('is-invalid', 'is-valid');
    });
}

// -------------------------------------------------------
// Meldung anzeigen (alertId = ID des Alert-Elements)
// Hinweis: Spans mit ID (z.B. lockTimer) werden nicht überschrieben
// -------------------------------------------------------
function showAlert(alertId, message) {
    document.querySelectorAll('.alert').forEach(function(a) {
        a.classList.remove('show');
    });

    var el = document.getElementById(alertId);
    if (!el) return;

    if (message) {
        var span = el.querySelector('span:not([id])');
        if (span) span.textContent = message;
    }

    el.classList.add('show');
}

// -------------------------------------------------------
// Alle Meldungen ausblenden
// -------------------------------------------------------
function hideAlerts() {
    document.querySelectorAll('.alert').forEach(function(a) {
        a.classList.remove('show');
    });
}

// -------------------------------------------------------
// Passwortstärke-Anzeige aktualisieren (SCRUM-71)
// -------------------------------------------------------
function updatePasswordStrength(password) {
    var fill = document.getElementById('strengthFill');
    var text = document.getElementById('strengthText');
    if (!fill || !text) return;

    var strength = getPasswordStrength(password);

    fill.className = 'password-strength__fill';

    if (strength.level) {
        fill.classList.add('password-strength__fill--' + strength.level);
        text.textContent = strength.text;
    } else {
        text.textContent = '';
    }
}

// -------------------------------------------------------
// API-Anfrage senden (POST zu Ekatherines REST API)
// Wenn Backend nicht erreichbar → Mock-Modus
// -------------------------------------------------------
async function apiRequest(endpoint, data) {
    try {
        var response = await fetch(API_BASE_URL + endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        var result = await response.json();

        if (!response.ok) {
            throw { status: response.status, message: result.message || 'Ein Fehler ist aufgetreten.' };
        }

        return result;

    } catch (error) {
        if (error instanceof TypeError && error.message.includes('fetch')) {
            console.warn('[CyberSpace] Backend nicht erreichbar – Mock-Modus aktiv.');
            return mockResponse(endpoint, data);
        }
        throw error;
    }
}

// -------------------------------------------------------
// Mock-Antworten für Tests ohne Backend
// TODO: Entfernen wenn Ekatherine die Endpoints fertig hat
// Test-Login: test@test.at / Test1234!
// -------------------------------------------------------
function mockResponse(endpoint, data) {
    console.log('[MOCK]', endpoint, data);

    if (endpoint === '/register') {
        return { success: true, message: 'Registrierung erfolgreich!' };
    }

    if (endpoint === '/login') {
        if (data.email === 'test@test.at' && data.passwort === 'Test1234!') {
            return { success: true, token: 'mock-jwt-token', rolle: 'SPIELER' };
        }
        throw { status: 401, message: 'E-Mail oder Passwort falsch.' };
    }

    return { success: true };
}
