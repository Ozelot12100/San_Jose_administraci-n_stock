using SanJose.Inventory.Core.DTOs;

namespace SanJose.Inventory.Core.Services;

public interface IAuthService
{
    Task<LoginResponse> LoginAsync(LoginRequest request);
    Task<bool> VerifyTokenAsync(string token);
    string GenerateToken(UsuarioDTO usuario);
} 