using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SanJose.Inventory.Core.DTOs;
using SanJose.Inventory.Core.Services;

namespace SanJose.Inventory.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        try
        {
            var response = await _authService.LoginAsync(request);
            return Ok(response);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new { mensaje = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { mensaje = "Error interno del servidor" });
        }
    }

    [HttpGet("verificar-token")]
    [Authorize]
    public async Task<ActionResult> VerificarToken()
    {
        var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");
        var esValido = await _authService.VerifyTokenAsync(token);
        
        if (!esValido)
        {
            return Unauthorized(new { mensaje = "Token inválido o expirado" });
        }

        return Ok(new { mensaje = "Token válido" });
    }
} 