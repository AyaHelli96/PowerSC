namespace CyberSpaceNIS2.API.DTOs;

public class CreateKarteRequest
{
    public int PhaseId { get; set; }
    public string Titel { get; set; } = string.Empty;          // max 80
    public string? Inhalt { get; set; }                        // max 300
    public int Punkte { get; set; } = 0;
    public List<CreateOptionRequest> Optionen { get; set; } = new();
}

public class CreateOptionRequest
{
    public string Text { get; set; } = string.Empty;           // max 100
    public bool IstRichtig { get; set; } = false;
    public int Punkte { get; set; } = 0;
}

public class KarteResponse
{
    public int KarteId { get; set; }
    public string KartenCode { get; set; } = string.Empty;     // z.B. ACT:001
    public string Titel { get; set; } = string.Empty;
    public string? Inhalt { get; set; }
    public string KartenTyp { get; set; } = string.Empty;
    public int Punkte { get; set; }
    public List<OptionResponse> Optionen { get; set; } = new();
}

public class OptionResponse
{
    public int OptionId { get; set; }
    public string Text { get; set; } = string.Empty;
    public bool IstRichtig { get; set; }
    public int Punkte { get; set; }
}
public class CreateReactioKarteRequest
{
    public int PhaseId { get; set; }
    public int AktioKarteId { get; set; }                     // Verknüpfung mit Actio-Karte
    public string Titel { get; set; } = string.Empty;          // max 80
    public string? Inhalt { get; set; }                        // max 300
    public string ReaktionsTyp { get; set; } = string.Empty;   // PositiverSchritt, NegativerSchritt, Wiederherstellung, Sackgasse
    public int Punkte { get; set; }                            // +50, -30, +20, -50
}