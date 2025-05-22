using Microsoft.AspNetCore.Mvc;
using SanJoseAPI.Models;
using SanJoseAPI.Repositories;
using System.Threading.Tasks;
using SanJoseAPI.DTOs;

namespace SanJoseAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsuariosController : ControllerBase
    {
        private readonly IUsuarioRepository _usuarioRepository;

        public UsuariosController(IUsuarioRepository usuarioRepository)
        {
            _usuarioRepository = usuarioRepository;
        }

        [HttpGet]
        public async Task<IActionResult> GetUsuarios()
        {
            var usuarios = await _usuarioRepository.GetAllAsync();
            return Ok(usuarios);
        }

        [HttpPut("{id}/toggle-estado")]
        public async Task<IActionResult> ToggleEstado(int id, [FromBody] ToggleEstadoRequest request)
        {
            var usuario = await _usuarioRepository.GetByIdAsync(id);
            if (usuario == null)
            {
                return NotFound();
            }

            usuario.Activo = request.Activo;
            await _usuarioRepository.UpdateAsync(usuario);
            return Ok(usuario);
        }

        [HttpPost]
        public async Task<IActionResult> PostUsuario([FromBody] UsuarioDto usuarioDto)
        {
            if (string.IsNullOrWhiteSpace(usuarioDto.Usuario) || string.IsNullOrWhiteSpace(usuarioDto.Rol) || string.IsNullOrWhiteSpace(usuarioDto.Contrasena))
                return BadRequest("Usuario, Rol y Contraseña son obligatorios.");

            // Forzar área para administradores
            int? idArea = usuarioDto.Rol == "administrador" ? 5 : usuarioDto.IdArea;

            var usuario = new Usuario
            {
                NombreUsuario = usuarioDto.Usuario,
                Rol = usuarioDto.Rol,
                Activo = usuarioDto.Activo,
                IdArea = idArea,
                Contrasena = usuarioDto.Contrasena
            };

            await _usuarioRepository.AddAsync(usuario);
            return Ok(usuario);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> PutUsuario(int id, [FromBody] UsuarioDto usuarioDto)
        {
            if (id != usuarioDto.Id)
                return BadRequest();

            var usuario = await _usuarioRepository.GetByIdAsync(id);
            if (usuario == null)
                return NotFound();

            usuario.NombreUsuario = usuarioDto.Usuario;
            usuario.Rol = usuarioDto.Rol;
            usuario.Activo = usuarioDto.Activo;
            // Forzar área para administradores
            usuario.IdArea = usuarioDto.Rol == "administrador" ? 5 : usuarioDto.IdArea;
            // Solo actualizar la contraseña si se recibe un valor no vacío
            if (!string.IsNullOrWhiteSpace(usuarioDto.Contrasena))
                usuario.Contrasena = usuarioDto.Contrasena;

            await _usuarioRepository.UpdateAsync(usuario);
            return Ok(usuario);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUsuario(int id)
        {
            var usuario = await _usuarioRepository.GetByIdAsync(id);
            if (usuario == null)
                return NotFound();

            await _usuarioRepository.DeleteAsync(id);
            return NoContent();
        }
    }

    public class ToggleEstadoRequest
    {
        public bool Activo { get; set; }
    }
} 