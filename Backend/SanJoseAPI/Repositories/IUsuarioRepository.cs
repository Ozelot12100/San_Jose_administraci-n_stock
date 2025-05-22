using SanJoseAPI.Models;
using System.Threading.Tasks;

namespace SanJoseAPI.Repositories
{
    public interface IUsuarioRepository : IRepository<Usuario>
    {
        Task<Usuario> GetUsuarioPorCredencialesAsync(string nombreUsuario, string contrasena);
        Task<bool> ExisteUsuarioAsync(string nombreUsuario);
    }
} 