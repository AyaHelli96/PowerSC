namespace CyberSpaceNIS2.API.Models;

public class Karte
{
    public int KarteId { get; set; }
    public int PhaseId { get; set; }
    public string Titel { get; set; } = string.Empty;        // max 80 Zeichen
    public string? Inhalt { get; set; }                       // max 300 Zeichen
    public string KartenTyp { get; set; } = "Aktion";         // Aktion, Ereignis, Reaktion, Information
    public int Punkte { get; set; } = 0;
    public int Reihenfolge { get; set; } = 1;
    public string? KartenCode { get; set; }                   // Format: ACT:001
    public string? ReaktionsTyp { get; set; }
    public int? AktioKarteId { get; set; }

    // Navigation Property
    public List<Option> Optionen { get; set; } = new();
}