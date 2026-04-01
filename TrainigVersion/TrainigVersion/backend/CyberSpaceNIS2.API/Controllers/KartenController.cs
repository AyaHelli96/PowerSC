using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CyberSpaceNIS2.API.Data;
using CyberSpaceNIS2.API.DTOs;
using CyberSpaceNIS2.API.Models;

namespace CyberSpaceNIS2.API.Controllers;

[ApiController]
[Route("api/karten")]
public class KartenController : ControllerBase
{
    private readonly AppDbContext _db;

    public KartenController(AppDbContext db)
    {
        _db = db;
    }

    // POST /api/karten/actio → Neue Actio-Karte erstellen
    [HttpPost("actio")]
    public async Task<IActionResult> CreateActioKarte([FromBody] CreateKarteRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Titel) || request.Titel.Length > 80)
            return BadRequest(new { message = "Titel ist Pflichtfeld (max. 80 Zeichen)." });

        if (request.Inhalt != null && request.Inhalt.Length > 300)
            return BadRequest(new { message = "Kartentext darf max. 300 Zeichen haben." });

        if (request.Optionen == null || request.Optionen.Count == 0)
            return BadRequest(new { message = "Mindestens eine Option ist erforderlich." });

        foreach (var opt in request.Optionen)
        {
            if (string.IsNullOrWhiteSpace(opt.Text) || opt.Text.Length > 100)
                return BadRequest(new { message = "Jede Option muss einen Text haben (max. 100 Zeichen)." });
        }

        if (!request.Optionen.Any(o => o.IstRichtig))
            return BadRequest(new { message = "Mindestens eine Option muss als korrekt markiert sein." });

        var anzahlActio = await _db.Karte.CountAsync(k => k.KartenTyp == "Aktion");
        var kartenCode = $"ACT:{(anzahlActio + 1):D3}";

        var karte = new Karte
        {
            PhaseId = request.PhaseId,
            Titel = request.Titel,
            Inhalt = request.Inhalt,
            KartenTyp = "Aktion",
            Punkte = request.Punkte,
            KartenCode = kartenCode,
            Reihenfolge = anzahlActio + 1
        };

        _db.Karte.Add(karte);
        await _db.SaveChangesAsync();

        foreach (var optRequest in request.Optionen)
        {
            var option = new Option
            {
                KarteId = karte.KarteId,
                Text = optRequest.Text,
                IstRichtig = optRequest.IstRichtig,
                Punkte = optRequest.Punkte
            };
            _db.Option.Add(option);
        }
        await _db.SaveChangesAsync();

        var response = new KarteResponse
        {
            KarteId = karte.KarteId,
            KartenCode = kartenCode,
            Titel = karte.Titel,
            Inhalt = karte.Inhalt,
            KartenTyp = karte.KartenTyp,
            Punkte = karte.Punkte,
            Optionen = request.Optionen.Select(o => new OptionResponse
            {
                Text = o.Text,
                IstRichtig = o.IstRichtig,
                Punkte = o.Punkte
            }).ToList()
        };

        return Created($"/api/karten/{karte.KarteId}", response);
    }

    // POST /api/karten/reactio → Neue Reactio-Karte erstellen
    [HttpPost("reactio")]
    public async Task<IActionResult> CreateReactioKarte([FromBody] CreateReactioKarteRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Titel) || request.Titel.Length > 80)
            return BadRequest(new { message = "Titel ist Pflichtfeld (max. 80 Zeichen)." });

        if (request.Inhalt != null && request.Inhalt.Length > 300)
            return BadRequest(new { message = "Kartentext darf max. 300 Zeichen haben." });

        var erlaubteTypen = new[] { "PositiverSchritt", "NegativerSchritt", "Wiederherstellung", "Sackgasse" };
        if (!erlaubteTypen.Contains(request.ReaktionsTyp))
            return BadRequest(new { message = "ReaktionsTyp muss sein: PositiverSchritt, NegativerSchritt, Wiederherstellung oder Sackgasse." });

        var erlaubtePunkte = new Dictionary<string, int>
        {
            { "PositiverSchritt", 50 },
            { "NegativerSchritt", -30 },
            { "Wiederherstellung", 20 },
            { "Sackgasse", -50 }
        };

        if (erlaubtePunkte[request.ReaktionsTyp] != request.Punkte)
            return BadRequest(new { message = $"Punkte fuer {request.ReaktionsTyp} muessen {erlaubtePunkte[request.ReaktionsTyp]} sein." });

        var aktioKarte = await _db.Karte.FirstOrDefaultAsync(k => k.KarteId == request.AktioKarteId && k.KartenTyp == "Aktion");
        if (aktioKarte == null)
            return BadRequest(new { message = "Die verknuepfte Actio-Karte wurde nicht gefunden." });

        var anzahlReactio = await _db.Karte.CountAsync(k => k.KartenTyp == "Reaktion");
        var kartenCode = $"REA:{(anzahlReactio + 1):D3}";

        var karte = new Karte
        {
            PhaseId = request.PhaseId,
            Titel = request.Titel,
            Inhalt = request.Inhalt,
            KartenTyp = "Reaktion",
            Punkte = request.Punkte,
            KartenCode = kartenCode,
            ReaktionsTyp = request.ReaktionsTyp,
            AktioKarteId = request.AktioKarteId,
            Reihenfolge = anzahlReactio + 1
        };

        _db.Karte.Add(karte);
        await _db.SaveChangesAsync();

        return Created($"/api/karten/{karte.KarteId}", new KarteResponse
        {
            KarteId = karte.KarteId,
            KartenCode = kartenCode,
            Titel = karte.Titel,
            Inhalt = karte.Inhalt,
            KartenTyp = karte.KartenTyp,
            Punkte = karte.Punkte,
            Optionen = new List<OptionResponse>()
        });
    }

    // GET /api/karten → Alle Karten auflisten
    [HttpGet]
    public async Task<IActionResult> GetAlleKarten()
    {
        var karten = await _db.Karte
            .Include(k => k.Optionen)
            .ToListAsync();

        var response = karten.Select(k => new KarteResponse
        {
            KarteId = k.KarteId,
            KartenCode = k.KartenCode ?? "",
            Titel = k.Titel,
            Inhalt = k.Inhalt,
            KartenTyp = k.KartenTyp,
            Punkte = k.Punkte,
            Optionen = k.Optionen.Select(o => new OptionResponse
            {
                OptionId = o.OptionId,
                Text = o.Text,
                IstRichtig = o.IstRichtig,
                Punkte = o.Punkte
            }).ToList()
        });

        return Ok(response);
    }

    // GET /api/karten/{id} → Einzelne Karte abrufen
    [HttpGet("{id}")]
    public async Task<IActionResult> GetKarte(int id)
    {
        var karte = await _db.Karte
            .Include(k => k.Optionen)
            .FirstOrDefaultAsync(k => k.KarteId == id);

        if (karte == null)
            return NotFound(new { message = "Karte nicht gefunden." });

        var response = new KarteResponse
        {
            KarteId = karte.KarteId,
            KartenCode = karte.KartenCode ?? "",
            Titel = karte.Titel,
            Inhalt = karte.Inhalt,
            KartenTyp = karte.KartenTyp,
            Punkte = karte.Punkte,
            Optionen = karte.Optionen.Select(o => new OptionResponse
            {
                OptionId = o.OptionId,
                Text = o.Text,
                IstRichtig = o.IstRichtig,
                Punkte = o.Punkte
            }).ToList()
        };

        return Ok(response);
    }
}