namespace CyberSpaceNIS2.API.Models;



public class Szenario
{
    public int SzenarioId { get; set; }
    public string Titel { get; set; } = string.Empty;
    public string? Beschreibung { get; set; }
    public string SchwierigkeitsGrad { get; set; } = "Mittel";
    public string Zielgruppe { get; set; } = "Alle";
    public string Status { get; set; } = "Entwurf";
    public int MinSpieler { get; set; } = 2;
    public int MaxSpieler { get; set; } = 6;
    public int MinPunkte { get; set; } = 0;
    public DateTime ErstelltAm { get; set; } = DateTime.UtcNow;
    public int ErstelltVon { get; set; }
    public string? Nis2Artikel { get; set; }
    public int DauerMinuten { get; set; } = 30;
    public int AnzahlPhasen { get; set; } = 1;

}