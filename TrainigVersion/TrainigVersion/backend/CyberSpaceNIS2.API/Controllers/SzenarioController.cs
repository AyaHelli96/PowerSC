using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CyberSpaceNIS2.API.Data;
using CyberSpaceNIS2.API.DTOs;
using CyberSpaceNIS2.API.Models;

namespace CyberSpaceNIS2.API.Controllers;

[ApiController]
[Route("api/szenarien")]
public class SzenarioController : ControllerBase
{
    private readonly AppDbContext _db;

    public SzenarioController(AppDbContext db)
    {
        _db = db;
    }

    [HttpPost]
    public async Task<IActionResult> CreateSzenario([FromBody] CreateSzenarioRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Titel) || request.Titel.Length > 100)
            return BadRequest(new { message = "Titel ist Pflichtfeld (max. 100 Zeichen)." });

        var erlaubteGrade = new[] { "Einfach", "Mittel", "Schwer" };
        if (!erlaubteGrade.Contains(request.SchwierigkeitsGrad))
            return BadRequest(new { message = "SchwierigkeitsGrad muss Einfach, Mittel oder Schwer sein." });

        var erlaubteZielgruppen = new[] { "Fuehrungskraefte", "IT-Personal", "Alle" };
        if (!erlaubteZielgruppen.Contains(request.Zielgruppe))
            return BadRequest(new { message = "Zielgruppe muss Fuehrungskraefte, IT-Personal oder Alle sein." });

        if (request.DauerMinuten < 15 || request.DauerMinuten > 120)
            return BadRequest(new { message = "Dauer muss zwischen 15 und 120 Minuten liegen." });

        if (request.AnzahlPhasen < 1 || request.AnzahlPhasen > 10)
            return BadRequest(new { message = "AnzahlPhasen muss zwischen 1 und 10 liegen." });

        if (request.MinSpieler < 1 || request.MaxSpieler < request.MinSpieler)
            return BadRequest(new { message = "MinSpieler muss mindestens 1 und MaxSpieler groesser als MinSpieler sein." });

        var ersteller = await _db.Benutzer.FirstOrDefaultAsync(b => b.BenutzerId == request.ErstelltVon);
        if (ersteller == null)
            return BadRequest(new { message = "Ersteller (ErstelltVon) wurde nicht gefunden." });

        var szenario = new Szenario
        {
            Titel = request.Titel,
            Beschreibung = request.Beschreibung,
            SchwierigkeitsGrad = request.SchwierigkeitsGrad,
            Zielgruppe = request.Zielgruppe,
            Status = "Entwurf",
            MinSpieler = request.MinSpieler,
            MaxSpieler = request.MaxSpieler,
            Nis2Artikel = request.Nis2Artikel,
            DauerMinuten = request.DauerMinuten,
            AnzahlPhasen = request.AnzahlPhasen,
            ErstelltVon = request.ErstelltVon
        };

        _db.Szenario.Add(szenario);
        await _db.SaveChangesAsync();

        return Created($"/api/szenarien/{szenario.SzenarioId}", MapToResponse(szenario));
    }

    [HttpGet]
    public async Task<IActionResult> GetAlleSzenarien()
    {
        var szenarien = await _db.Szenario.ToListAsync();
        return Ok(szenarien.Select(MapToResponse));
    }

    [HttpGet("aktiv")]
    public async Task<IActionResult> GetAktiveSzenarien()
    {
        var szenarien = await _db.Szenario
            .Where(s => s.Status == "Aktiv")
            .ToListAsync();
        return Ok(szenarien.Select(MapToResponse));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetSzenario(int id)
    {
        var szenario = await _db.Szenario.FirstOrDefaultAsync(s => s.SzenarioId == id);
        if (szenario == null)
            return NotFound(new { message = "Szenario nicht gefunden." });

        return Ok(MapToResponse(szenario));
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateSzenario(int id, [FromBody] UpdateSzenarioRequest request)
    {
        var szenario = await _db.Szenario.FirstOrDefaultAsync(s => s.SzenarioId == id);
        if (szenario == null)
            return NotFound(new { message = "Szenario nicht gefunden." });

        if (szenario.Status == "Aktiv")
            return BadRequest(new { message = "Aktive Szenarien koennen nicht bearbeitet werden." });

        if (string.IsNullOrWhiteSpace(request.Titel) || request.Titel.Length > 100)
            return BadRequest(new { message = "Titel ist Pflichtfeld (max. 100 Zeichen)." });

        szenario.Titel = request.Titel;
        szenario.Beschreibung = request.Beschreibung;
        szenario.SchwierigkeitsGrad = request.SchwierigkeitsGrad;
        szenario.Zielgruppe = request.Zielgruppe;
        szenario.MinSpieler = request.MinSpieler;
        szenario.MaxSpieler = request.MaxSpieler;
        szenario.Nis2Artikel = request.Nis2Artikel;
        szenario.DauerMinuten = request.DauerMinuten;
        szenario.AnzahlPhasen = request.AnzahlPhasen;

        await _db.SaveChangesAsync();
        return Ok(MapToResponse(szenario));
    }

    [HttpPatch("{id}/veroeffentlichen")]
    public async Task<IActionResult> Veroeffentlichen(int id)
    {
        var szenario = await _db.Szenario.FirstOrDefaultAsync(s => s.SzenarioId == id);
        if (szenario == null)
            return NotFound(new { message = "Szenario nicht gefunden." });

        if (szenario.Status != "Entwurf")
            return BadRequest(new { message = "Nur Entwuerfe koennen veroeffentlicht werden." });

        szenario.Status = "Aktiv";
        await _db.SaveChangesAsync();
        return Ok(MapToResponse(szenario));
    }

    [HttpPatch("{id}/archivieren")]
    public async Task<IActionResult> Archivieren(int id)
    {
        var szenario = await _db.Szenario.FirstOrDefaultAsync(s => s.SzenarioId == id);
        if (szenario == null)
            return NotFound(new { message = "Szenario nicht gefunden." });

        szenario.Status = "Archiviert";
        await _db.SaveChangesAsync();
        return Ok(MapToResponse(szenario));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteSzenario(int id)
    {
        var szenario = await _db.Szenario.FirstOrDefaultAsync(s => s.SzenarioId == id);
        if (szenario == null)
            return NotFound(new { message = "Szenario nicht gefunden." });

        if (szenario.Status == "Aktiv")
            return BadRequest(new { message = "Aktive Szenarien koennen nicht geloescht werden." });

        _db.Szenario.Remove(szenario);
        await _db.SaveChangesAsync();
        return Ok(new { message = "Szenario geloescht." });
    }

    private static SzenarioResponse MapToResponse(Szenario s)
    {
        return new SzenarioResponse
        {
            SzenarioId = s.SzenarioId,
            Titel = s.Titel,
            Beschreibung = s.Beschreibung,
            SchwierigkeitsGrad = s.SchwierigkeitsGrad,
            Zielgruppe = s.Zielgruppe,
            Status = s.Status,
            MinSpieler = s.MinSpieler,
            MaxSpieler = s.MaxSpieler,
            MinPunkte = s.MinPunkte,
            Nis2Artikel = s.Nis2Artikel,
            DauerMinuten = s.DauerMinuten,
            AnzahlPhasen = s.AnzahlPhasen,
            ErstelltAm = s.ErstelltAm,
            ErstelltVon = s.ErstelltVon
        };
    }
}