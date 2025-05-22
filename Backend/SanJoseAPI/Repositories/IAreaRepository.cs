using SanJoseAPI.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SanJoseAPI.Repositories
{
    public interface IAreaRepository : IRepository<Area>
    {
        Task<IEnumerable<Area>> GetAreasActivasAsync();
    }
} 