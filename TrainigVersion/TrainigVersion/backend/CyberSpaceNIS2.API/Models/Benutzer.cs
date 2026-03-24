namespace CyberSpaceNIS2.API.Models;

public class Benutzer
{
    public int BenutzerId { get; set; }
    public string Benutzername { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswortHash { get; set; } = string.Empty;
    public string Rolle { get; set; } = "Spieler";
    public DateTime ErstelltAm { get; set; } = DateTime.UtcNow;
    public int FehlgeschlagenLogin { get; set; } = 0;
    public DateTime? GesperrtBis { get; set; }
    public int? Punkte { get; set; }
    public string? Abzeichen { get; set; }
    public string? Abteilung { get; set; }
}