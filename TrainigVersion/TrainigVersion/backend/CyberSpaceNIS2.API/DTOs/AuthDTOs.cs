namespace CyberSpaceNIS2.API.DTOs;

public class RegisterRequest
{
    public string Vorname { get; set; } = string.Empty;
    public string Nachname { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Passwort { get; set; } = string.Empty;
}

public class LoginRequest
{
    public string Email { get; set; } = string.Empty;
    public string Passwort { get; set; } = string.Empty;
    public bool AngemeldetBleiben { get; set; }
}

public class LoginResponse
{
    public string Token { get; set; } = string.Empty;
    public string Rolle { get; set; } = string.Empty;
}