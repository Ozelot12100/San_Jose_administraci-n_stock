using SanJoseAPI.Models;
using SanJoseAPI.Repositories;
using System.Threading.Tasks;

namespace SanJoseAPI.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUsuarioRepository _usuarioRepository;

        public AuthService(IUsuarioRepository usuarioRepository)
        {
            _usuarioRepository = usuarioRepository;
        }

        public async Task<Usuario> AutenticarUsuarioAsync(string nombreUsuario, string contrasena)
        {
            return await _usuarioRepository.GetUsuarioPorCredencialesAsync(nombreUsuario, contrasena);
        }
    }
} 