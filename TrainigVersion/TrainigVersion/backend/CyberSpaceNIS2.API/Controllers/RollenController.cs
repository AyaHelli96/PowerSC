using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CyberSpaceNIS2.API.Data;
using CyberSpaceNIS2.API.DTOs;
using CyberSpaceNIS2.API.Models;

namespace CyberSpaceNIS2.API.Controllers;

[ApiController]
[Route("api/rollen")]
public class RollenController : ControllerBase
{
    private readonly AppDbContext _db;

    public RollenController(AppDbContext db)
    {
        _db = db;
    }

    [HttpPost]
    public async Task<IActionResult> CreateRolle([FromBody] CreateRolleRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
            return BadRequest(new { message = "Name ist Pflichtfeld." });

        var rolle = new Rolle
        {
            Name = request.Name,
            Beschreibung = request.Beschreibung,
            Farbe = request.Farbe,
            FarbeHex = request.FarbeHex
        };

        _db.Rollen.Add(rolle);
        await _db.SaveChangesAsync();

        return Created($"/api/rollen/{rolle.RolleId}", rolle);
    }

    [HttpGet]
    public async Task<IActionResult> GetAlleRollen()
    {
        var rollen = await _db.Rollen.ToListAsync();
        return Ok(rollen);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetRolle(int id)
    {
        var rolle = await _db.Rollen.FirstOrDefaultAsync(r => r.RolleId == id);
        if (rolle == null)
            return NotFound(new { message = "Rolle nicht gefunden." });
        return Ok(rolle);
    }
}