namespace CyberSpaceNIS2.API.DTOs;

public class CreateSessionRequest
{
    public int SzenarioId { get; set; }
    public int ModeratorId { get; set; }
}

public class SessionResponse
{
    public int SessionId { get; set; }
    public int SzenarioId { get; set; }
    public int ModeratorId { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime? StartZeit { get; set; }
    public DateTime? EndZeit { get; set; }
    public DateTime ErstelltAm { get; set; }
}