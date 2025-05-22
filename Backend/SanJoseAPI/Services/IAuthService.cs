using SanJoseAPI.Models;
using System.Threading.Tasks;

namespace SanJoseAPI.Services
{
    public interface IAuthService
    {
        Task<Usuario> AutenticarUsuarioAsync(string nombreUsuario, string contrasena);
    }
} 