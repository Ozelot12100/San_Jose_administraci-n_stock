using SanJoseAPI.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SanJoseAPI.Repositories
{
    public interface IMovimientoRepository : IRepository<Movimiento>
    {
        Task<IEnumerable<Movimiento>> GetMovimientosConDetallesAsync();
        Task<IEnumerable<Movimiento>> GetMovimientosPorInsumoAsync(int insumoId);
        Task<IEnumerable<Movimiento>> GetMovimientosPorAreaAsync(int areaId);
        Task<IEnumerable<Movimiento>> GetMovimientosPorFechaAsync(DateTime fechaInicio, DateTime fechaFin);
    }
} 