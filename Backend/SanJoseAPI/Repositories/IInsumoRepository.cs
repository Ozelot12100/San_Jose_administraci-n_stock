using SanJoseAPI.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SanJoseAPI.Repositories
{
    public interface IInsumoRepository : IRepository<Insumo>
    {
        Task<IEnumerable<Insumo>> GetInsumosConProveedorAsync();
        Task<Insumo> GetInsumoPorIdConProveedorAsync(int id);
        Task<IEnumerable<Insumo>> GetInsumosPorCaducidadAsync(int dias);
    }
} 