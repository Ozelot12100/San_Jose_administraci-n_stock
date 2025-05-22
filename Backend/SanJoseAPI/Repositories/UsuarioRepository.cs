using Microsoft.EntityFrameworkCore;
using SanJoseAPI.Data;
using SanJoseAPI.Models;
using System.Threading.Tasks;

namespace SanJoseAPI.Repositories
{
    public class UsuarioRepository : Repository<Usuario>, IUsuarioRepository
    {
        private readonly AppDbContext _context;

        public UsuarioRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<bool> ExisteUsuarioAsync(string nombreUsuario)
        {
            return await _context.Usuarios.AnyAsync(u => u.NombreUsuario == nombreUsuario);
        }

        public async Task<Usuario> GetUsuarioPorCredencialesAsync(string nombreUsuario, string contrasena)
        {
            // Log de entrada
            Console.WriteLine($"Intentando autenticar usuario: '{nombreUsuario}' con contraseña: '{contrasena}'");

            var usuario = await _context.Usuarios
                .FirstOrDefaultAsync(u => u.NombreUsuario == nombreUsuario 
                                    && u.Contrasena == contrasena 
                                    && u.Activo);

            if (usuario != null)
            {
                Console.WriteLine($"Usuario encontrado: ID={usuario.Id}, usuario={usuario.NombreUsuario}, activo={usuario.Activo}");
            }
            else
            {
                Console.WriteLine("No se encontró usuario con esas credenciales o está inactivo.");
            }

            return usuario;
        }
    }
} 