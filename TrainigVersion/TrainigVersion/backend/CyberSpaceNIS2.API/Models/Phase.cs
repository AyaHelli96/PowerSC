namespace CyberSpaceNIS2.API.Models;

public class Phase
{
    public int PhaseId { get; set; }
    public int SzenarioId { get; set; }
    public string Titel { get; set; } = string.Empty;
    public string? Beschreibung { get; set; }
    public int Reihenfolge { get; set; } = 1;
    public int? ZeitlimitSek { get; set; }
    public int? StartKarteId { get; set; }
    public int? EndKarteId { get; set; }
    public int MinPunkte { get; set; } = 1;
}