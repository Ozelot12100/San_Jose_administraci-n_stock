using Microsoft.EntityFrameworkCore;
using SanJoseAPI.Data;
using SanJoseAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SanJoseAPI.Repositories
{
    public class InsumoRepository : Repository<Insumo>, IInsumoRepository
    {
        private readonly AppDbContext _context;

        public InsumoRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Insumo>> GetInsumosConProveedorAsync()
        {
            return await _context.Insumos.Include(i => i.Proveedor).ToListAsync();
        }

        public async Task<Insumo> GetInsumoPorIdConProveedorAsync(int id)
        {
            return await _context.Insumos
                .Include(i => i.Proveedor)
                .FirstOrDefaultAsync(i => i.Id == id);
        }

        public async Task<IEnumerable<Insumo>> GetInsumosPorCaducidadAsync(int dias)
        {
            return new List<Insumo>();
        }
    }
} 