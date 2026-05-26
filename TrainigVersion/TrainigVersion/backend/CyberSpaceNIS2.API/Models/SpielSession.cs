namespace CyberSpaceNIS2.API.Models;

public class SpielSession
{
    public int SessionId { get; set; }
    public int SzenarioId { get; set; }
    public int ModeratorId { get; set; }
    public string Status { get; set; } = "Offen";
    public DateTime? StartZeit { get; set; }
    public DateTime? EndZeit { get; set; }
    public DateTime ErstelltAm { get; set; } = DateTime.UtcNow;
}