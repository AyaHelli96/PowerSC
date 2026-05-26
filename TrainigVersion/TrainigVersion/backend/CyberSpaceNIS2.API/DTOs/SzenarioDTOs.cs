namespace CyberSpaceNIS2.API.DTOs;

public class CreateSzenarioRequest
{
    public string Titel { get; set; } = string.Empty;
    public string? Beschreibung { get; set; }
    public string SchwierigkeitsGrad { get; set; } = "Mittel";
    public string Zielgruppe { get; set; } = "Alle";
    public int MinSpieler { get; set; } = 2;
    public int MaxSpieler { get; set; } = 6;
    public string? Nis2Artikel { get; set; }
    public int DauerMinuten { get; set; } = 30;
    public int AnzahlPhasen { get; set; } = 1;
    public int ErstelltVon { get; set; }
}
public class UpdateSzenarioRequest
{
    public string Titel { get; set; } = string.Empty;
    public string? Beschreibung { get; set; }
    public string SchwierigkeitsGrad { get; set; } = "Mittel";
    public string Zielgruppe { get; set; } = "Alle";
    public int MinSpieler { get; set; } = 2;
    public int MaxSpieler { get; set; } = 6;
    public string? Nis2Artikel { get; set; }
    public int DauerMinuten { get; set; } = 30;
    public int AnzahlPhasen { get; set; } = 1;
}
public class SzenarioResponse
{
    public int SzenarioId { get; set; }
    public string Titel { get; set; } = string.Empty;
    public string? Beschreibung { get; set; }
    public string SchwierigkeitsGrad { get; set; } = string.Empty;
    public string Zielgruppe { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public int MinSpieler { get; set; }
    public int MaxSpieler { get; set; }
    public int MinPunkte { get; set; }
    public string? Nis2Artikel { get; set; }
    public int DauerMinuten { get; set; }
    public int AnzahlPhasen { get; set; }
    public DateTime ErstelltAm { get; set; }
    public int ErstelltVon { get; set; }
}
