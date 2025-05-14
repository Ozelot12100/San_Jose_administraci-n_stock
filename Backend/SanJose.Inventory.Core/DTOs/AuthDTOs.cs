using System.ComponentModel.DataAnnotations;

namespace SanJose.Inventory.Core.DTOs;

public class LoginRequest
{
    [Required]
    public string Usuario { get; set; } = null!;

    [Required]
    public string Contrasena { get; set; } = null!;
}

public class LoginResponse
{
    public string Token { get; set; } = null!;
    public UsuarioDTO Usuario { get; set; } = null!;
}

public class UsuarioDTO
{
    public int Id { get; set; }
    public string Usuario { get; set; } = null!;
    public string Rol { get; set; } = null!;
    public bool Activo { get; set; }
} 