using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CyberSpaceNIS2.API.Data;
using CyberSpaceNIS2.API.DTOs;
using CyberSpaceNIS2.API.Models;

namespace CyberSpaceNIS2.API.Controllers;

[ApiController]
[Route("api/session")]
public class SessionController : ControllerBase
{
    private readonly AppDbContext _db;

    public SessionController(AppDbContext db)
    {
        _db = db;
    }

    // POST /api/session → Neue Session erstellen
    [HttpPost]
    public async Task<IActionResult> CreateSession([FromBody] CreateSessionRequest request)
    {
        // Szenario muss existieren und aktiv sein
        var szenario = await _db.Szenario.FirstOrDefaultAsync(s => s.SzenarioId == request.SzenarioId);
        if (szenario == null)
            return BadRequest(new { message = "Szenario nicht gefunden." });
        if (szenario.Status != "Aktiv")
            return BadRequest(new { message = "Nur aktive Szenarien koennen gestartet werden." });

        // Moderator muss existieren
        var moderator = await _db.Benutzer.FirstOrDefaultAsync(b => b.BenutzerId == request.ModeratorId);
        if (moderator == null)
            return BadRequest(new { message = "Moderator nicht gefunden." });

        var session = new SpielSession
        {
            SzenarioId = request.SzenarioId,
            ModeratorId = request.ModeratorId,
            Status = "Offen"
        };

        _db.Session.Add(session);
        await _db.SaveChangesAsync();

        return Created($"/api/session/{session.SessionId}", MapToResponse(session));
    }

    // GET /api/session → Alle Sessions auflisten
    [HttpGet]
    public async Task<IActionResult> GetAlleSessions()
    {
        var sessions = await _db.Session.ToListAsync();
        return Ok(sessions.Select(MapToResponse));
    }

    // GET /api/session/aktiv → Nur aktive Sessions (US 2.1.1)
    [HttpGet("aktiv")]
    public async Task<IActionResult> GetAktiveSessions()
    {
        var sessions = await _db.Session
            .Where(s => s.Status == "Offen" || s.Status == "Laufend")
            .ToListAsync();
        return Ok(sessions.Select(MapToResponse));
    }

    // GET /api/session/{id} → Einzelne Session
    [HttpGet("{id}")]
    public async Task<IActionResult> GetSession(int id)
    {
        var session = await _db.Session.FirstOrDefaultAsync(s => s.SessionId == id);
        if (session == null)
            return NotFound(new { message = "Session nicht gefunden." });

        return Ok(MapToResponse(session));
    }

    // PATCH /api/session/{id}/starten → Spiel starten (US 2.2.3)
    [HttpPatch("{id}/starten")]
    public async Task<IActionResult> SessionStarten(int id)
    {
        var session = await _db.Session.FirstOrDefaultAsync(s => s.SessionId == id);
        if (session == null)
            return NotFound(new { message = "Session nicht gefunden." });

        if (session.Status != "Offen")
            return BadRequest(new { message = "Nur offene Sessions koennen gestartet werden." });

        session.Status = "Laufend";
        session.StartZeit = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(MapToResponse(session));
    }

    // PATCH /api/session/{id}/pausieren → Spiel pausieren (US 2.2.1)
    [HttpPatch("{id}/pausieren")]
    public async Task<IActionResult> SessionPausieren(int id)
    {
        var session = await _db.Session.FirstOrDefaultAsync(s => s.SessionId == id);
        if (session == null)
            return NotFound(new { message = "Session nicht gefunden." });

        if (session.Status != "Laufend")
            return BadRequest(new { message = "Nur laufende Sessions koennen pausiert werden." });

        session.Status = "Offen";
        await _db.SaveChangesAsync();

        return Ok(MapToResponse(session));
    }

    // PATCH /api/session/{id}/beenden → Spiel beenden (US 2.2.2)
    [HttpPatch("{id}/beenden")]
    public async Task<IActionResult> SessionBeenden(int id)
    {
        var session = await _db.Session.FirstOrDefaultAsync(s => s.SessionId == id);
        if (session == null)
            return NotFound(new { message = "Session nicht gefunden." });

        if (session.Status == "Beendet")
            return BadRequest(new { message = "Session ist bereits beendet." });

        session.Status = "Beendet";
        session.EndZeit = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(MapToResponse(session));
    }

    // PATCH /api/session/{id}/abbrechen → Spiel abbrechen
    [HttpPatch("{id}/abbrechen")]
    public async Task<IActionResult> SessionAbbrechen(int id)
    {
        var session = await _db.Session.FirstOrDefaultAsync(s => s.SessionId == id);
        if (session == null)
            return NotFound(new { message = "Session nicht gefunden." });

        if (session.Status == "Beendet")
            return BadRequest(new { message = "Beendete Sessions koennen nicht abgebrochen werden." });

        session.Status = "Abgebrochen";
        session.EndZeit = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(MapToResponse(session));
    }

    // GET /api/session/{id}/ergebnis → Spielergebnis (US 3.3.1 + US 3.3.2)
    [HttpGet("{id}/ergebnis")]
    public async Task<IActionResult> GetErgebnis(int id)
    {
        var session = await _db.Session.FirstOrDefaultAsync(s => s.SessionId == id);
        if (session == null)
            return NotFound(new { message = "Session nicht gefunden." });

        if (session.Status != "Beendet")
            return BadRequest(new { message = "Ergebnis nur fuer beendete Sessions verfuegbar." });

        var szenario = await _db.Szenario.FirstOrDefaultAsync(s => s.SzenarioId == session.SzenarioId);

        return Ok(new
        {
            sessionId = session.SessionId,
            szenarioTitel = szenario?.Titel ?? "Unbekannt",
            status = session.Status,
            startZeit = session.StartZeit,
            endZeit = session.EndZeit,
            message = "Session erfolgreich abgeschlossen!"
        });
    }

    // Helper
    private static SessionResponse MapToResponse(SpielSession s)
    {
        return new SessionResponse
        {
            SessionId = s.SessionId,
            SzenarioId = s.SzenarioId,
            ModeratorId = s.ModeratorId,
            Status = s.Status,
            StartZeit = s.StartZeit,
            EndZeit = s.EndZeit,
            ErstelltAm = s.ErstelltAm
        };
    }
}