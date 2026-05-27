namespace CyberSpaceNIS2.API.DTOs;

public class CreatePhaseRequest
{
    public int SzenarioId { get; set; }
    public string Titel { get; set; } = string.Empty;
    public string? Beschreibung { get; set; }
    public int Reihenfolge { get; set; } = 1;
    public int? ZeitlimitSek { get; set; }
    public int MinPunkte { get; set; } = 1;
}

public class CreateRolleRequest
{
    public string Name { get; set; } = string.Empty;
    public string? Beschreibung { get; set; }
    public string? Farbe { get; set; }
    public string? FarbeHex { get; set; }
}