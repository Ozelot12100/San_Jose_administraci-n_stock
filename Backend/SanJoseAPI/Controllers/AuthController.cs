using Microsoft.AspNetCore.Mvc;
using SanJoseAPI.DTOs;
using SanJoseAPI.Services;
using SanJoseAPI.Utils;
using System.Threading.Tasks;

namespace SanJoseAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginRequestDto request)
        {
            var usuario = await _authService.AutenticarUsuarioAsync(request.NombreUsuario, request.Contrasena);

            if (usuario == null)
            {
                return Ok(new { mensaje = AppConstants.CredencialesIncorrectas, exito = false, usuario = (object?)null });
            }

            return Ok(new {
                mensaje = "Inicio de sesión exitoso",
                exito = true,
                usuario = new {
                    id = usuario.Id,
                    nombreUsuario = usuario.NombreUsuario,
                    rol = usuario.Rol.ToString(),
                    activo = usuario.Activo,
                    id_area = usuario.IdArea
                }
            });
        }

        [HttpPost("login-simple")]
        public async Task<IActionResult> LoginSimple([FromBody] LoginRequestDto request)
        {
            // Reutiliza la lógica del login normal
            return await Login(request);
        }
    }
} 