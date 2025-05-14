using SanJose.Inventory.Core.DTOs;

namespace SanJose.Inventory.Core.Services;

public interface IAreaService
{
    Task<IEnumerable<AreaDTO>> GetAllAsync();
    Task<AreaDTO?> GetByIdAsync(int id);
    Task<AreaDTO> CreateAsync(CreateAreaDTO areaDto);
    Task UpdateAsync(int id, UpdateAreaDTO areaDto);
    Task DeleteAsync(int id);
    Task<bool> ExistsAsync(int id);
    Task<bool> ExistsByNameAsync(string nombre, int? excludeId = null);
} 