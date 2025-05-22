using SanJoseAPI.Data;
using SanJoseAPI.Models;

namespace SanJoseAPI.Repositories
{
    public class ProveedorRepository : Repository<Proveedor>, IProveedorRepository
    {
        private readonly AppDbContext _context;

        public ProveedorRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        // Implementaciones específicas para Proveedor
    }
} 