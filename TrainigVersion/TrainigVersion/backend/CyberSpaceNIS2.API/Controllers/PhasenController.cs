using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CyberSpaceNIS2.API.Data;
using CyberSpaceNIS2.API.DTOs;
using CyberSpaceNIS2.API.Models;

namespace CyberSpaceNIS2.API.Controllers;

[ApiController]
[Route("api/phasen")]
public class PhasenController : ControllerBase
{
    private readonly AppDbContext _db;

    public PhasenController(AppDbContext db)
    {
        _db = db;
    }

    [HttpPost]
    public async Task<IActionResult> CreatePhase([FromBody] CreatePhaseRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Titel))
            return BadRequest(new { message = "Titel ist Pflichtfeld." });

        if (request.Reihenfolge < 1 || request.Reihenfolge > 5)
            return BadRequest(new { message = "Reihenfolge muss zwischen 1 und 5 liegen." });

        if (request.MinPunkte < 1)
            return BadRequest(new { message = "MinPunkte muss groesser als 0 sein." });

        var szenario = await _db.Szenario.FirstOrDefaultAsync(s => s.SzenarioId == request.SzenarioId);
        if (szenario == null)
            return BadRequest(new { message = "Szenario nicht gefunden." });

        var phase = new Phase
        {
            SzenarioId = request.SzenarioId,
            Titel = request.Titel,
            Beschreibung = request.Beschreibung,
            Reihenfolge = request.Reihenfolge,
            ZeitlimitSek = request.ZeitlimitSek,
            MinPunkte = request.MinPunkte
        };

        _db.Phase.Add(phase);
        await _db.SaveChangesAsync();

        return Created($"/api/phasen/{phase.PhaseId}", phase);
    }

    [HttpGet]
    public async Task<IActionResult> GetAllePhases()
    {
        var phasen = await _db.Phase.OrderBy(p => p.SzenarioId).ThenBy(p => p.Reihenfolge).ToListAsync();
        return Ok(phasen);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetPhase(int id)
    {
        var phase = await _db.Phase.FirstOrDefaultAsync(p => p.PhaseId == id);
        if (phase == null)
            return NotFound(new { message = "Phase nicht gefunden." });
        return Ok(phase);
    }
}