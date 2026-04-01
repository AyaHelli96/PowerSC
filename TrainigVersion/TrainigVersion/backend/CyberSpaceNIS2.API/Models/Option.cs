namespace CyberSpaceNIS2.API.Models;

public class Option
{
    public int OptionId { get; set; }
    public int KarteId { get; set; }
    public string Text { get; set; } = string.Empty;   // max 100 Zeichen
    public bool IstRichtig { get; set; } = false;
    public int Punkte { get; set; } = 0;
}