using Microsoft.EntityFrameworkCore;
using SanJoseAPI.Data;
using SanJoseAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SanJoseAPI.Repositories
{
    public class MovimientoRepository : Repository<Movimiento>, IMovimientoRepository
    {
        private readonly AppDbContext _context;

        public MovimientoRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Movimiento>> GetMovimientosConDetallesAsync()
        {
            return await _context.Movimientos
                .Include(m => m.Insumo)
                .Include(m => m.Area)
                .Include(m => m.Usuario)
                .OrderByDescending(m => m.Fecha)
                .ToListAsync();
        }

        public async Task<IEnumerable<Movimiento>> GetMovimientosPorAreaAsync(int areaId)
        {
            return await _context.Movimientos
                .Include(m => m.Insumo)
                .Include(m => m.Area)
                .Include(m => m.Usuario)
                .Where(m => m.IdArea == areaId)
                .OrderByDescending(m => m.Fecha)
                .ToListAsync();
        }

        public async Task<IEnumerable<Movimiento>> GetMovimientosPorFechaAsync(DateTime fechaInicio, DateTime fechaFin)
        {
            return await _context.Movimientos
                .Include(m => m.Insumo)
                .Include(m => m.Area)
                .Include(m => m.Usuario)
                .Where(m => m.Fecha >= fechaInicio && m.Fecha <= fechaFin)
                .OrderByDescending(m => m.Fecha)
                .ToListAsync();
        }

        public async Task<IEnumerable<Movimiento>> GetMovimientosPorInsumoAsync(int insumoId)
        {
            return await _context.Movimientos
                .Include(m => m.Insumo)
                .Include(m => m.Area)
                .Include(m => m.Usuario)
                .Where(m => m.IdInsumo == insumoId)
                .OrderByDescending(m => m.Fecha)
                .ToListAsync();
        }
    }
} 