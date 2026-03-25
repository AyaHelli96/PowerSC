using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CyberSpaceNIS2.API.Data;
using CyberSpaceNIS2.API.DTOs;
using CyberSpaceNIS2.API.Models;

namespace CyberSpaceNIS2.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly IConfiguration _config;

    public AuthController(AppDbContext db, IConfiguration config)
    {
        _db = db;
        _config = config;
    }

    // POST /api/auth/register → Karen's register.js sendet hierher
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        // Prüfen ob E-Mail schon existiert → 409
        if (await _db.Benutzer.AnyAsync(b => b.Email == request.Email))
            return Conflict(new { message = "Diese E-Mail-Adresse ist bereits registriert." });

        var benutzer = new Benutzer
        {
            Benutzername = $"{request.Vorname} {request.Nachname}",
            Email = request.Email,
            PasswortHash = BCrypt.Net.BCrypt.HashPassword(request.Passwort),
            Rolle = "Spieler",
            Punkte = 0
        };

        _db.Benutzer.Add(benutzer);
        await _db.SaveChangesAsync();

        return Ok(new { message = "Registrierung erfolgreich!" });
    }

    // POST /api/auth/login → Karen's login.js sendet hierher
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var benutzer = await _db.Benutzer.FirstOrDefaultAsync(b => b.Email == request.Email);

        if (benutzer == null)
            return Unauthorized(new { message = "E-Mail oder Passwort falsch." });

        // 5-Minuten-Sperre prüfen
        if (benutzer.GesperrtBis.HasValue && benutzer.GesperrtBis > DateTime.UtcNow)
            return StatusCode(423, new { message = "Konto gesperrt. Bitte warten." });

        // Passwort prüfen mit BCrypt
        if (!BCrypt.Net.BCrypt.Verify(request.Passwort, benutzer.PasswortHash))
        {
            benutzer.FehlgeschlagenLogin++;
            if (benutzer.FehlgeschlagenLogin >= 3)
                benutzer.GesperrtBis = DateTime.UtcNow.AddMinutes(5);

            await _db.SaveChangesAsync();
            return Unauthorized(new { message = "E-Mail oder Passwort falsch." });
        }

        // Login erfolgreich → Reset Fehlversuche
        benutzer.FehlgeschlagenLogin = 0;
        benutzer.GesperrtBis = null;
        await _db.SaveChangesAsync();

        // JWT-Token generieren
        var token = GenerateJwtToken(benutzer);

        // Rolle in das Format das login.js erwartet: SPIELER, MODERATOR, ADMINISTRATOR
        var rolleUpperCase = benutzer.Rolle.ToUpper() switch
        {
            "ADMIN" => "ADMINISTRATOR",
            _ => benutzer.Rolle.ToUpper()
        };

        return Ok(new LoginResponse
        {
            Token = token,
            Rolle = rolleUpperCase
        });
    }

    private string GenerateJwtToken(Benutzer benutzer)
    {
        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_config["Jwt:Key"] ?? "SuperGeheimerSchluesselMindestens32Zeichen!")
        );

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, benutzer.BenutzerId.ToString()),
            new Claim(ClaimTypes.Email, benutzer.Email),
            new Claim(ClaimTypes.Role, benutzer.Rolle)
        };

        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"] ?? "CyberSpaceNIS2",
            audience: _config["Jwt:Audience"] ?? "CyberSpaceNIS2",
            claims: claims,
            expires: DateTime.UtcNow.AddHours(8),
            signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256)
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}