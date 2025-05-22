using Microsoft.EntityFrameworkCore;
using SanJoseAPI.Data;
using SanJoseAPI.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SanJoseAPI.Repositories
{
    public class AreaRepository : Repository<Area>, IAreaRepository
    {
        private readonly AppDbContext _context;

        public AreaRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Area>> GetAreasActivasAsync()
        {
            return await _context.Areas.ToListAsync();
        }
    }
} 