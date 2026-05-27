namespace CyberSpaceNIS2.API.Models;

public class Rolle
{
    public int RolleId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Beschreibung { get; set; }
    public string? Farbe { get; set; }
    public string? FarbeHex { get; set; }
}