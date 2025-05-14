using SanJose.Inventory.Core.DTOs;
using SanJose.Inventory.Core.Entities;
using SanJose.Inventory.Core.Interfaces;
using SanJose.Inventory.Core.Services;

namespace SanJose.Inventory.API.Services;

public class AreaService : IAreaService
{
    private readonly IUnitOfWork _unitOfWork;

    public AreaService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<AreaDTO>> GetAllAsync()
    {
        var areas = await _unitOfWork.Areas.GetAllAsync();
        return areas.Select(a => new AreaDTO
        {
            Id = a.Id,
            Nombre = a.Nombre,
            Estado = a.Estado
        });
    }

    public async Task<AreaDTO?> GetByIdAsync(int id)
    {
        var area = await _unitOfWork.Areas.GetByIdAsync(id);
        if (area == null) return null;

        return new AreaDTO
        {
            Id = area.Id,
            Nombre = area.Nombre,
            Estado = area.Estado
        };
    }

    public async Task<AreaDTO> CreateAsync(CreateAreaDTO areaDto)
    {
        if (await ExistsByNameAsync(areaDto.Nombre))
        {
            throw new InvalidOperationException("Ya existe un área con ese nombre");
        }

        var area = new Area
        {
            Nombre = areaDto.Nombre,
            Estado = areaDto.Estado
        };

        await _unitOfWork.Areas.AddAsync(area);
        await _unitOfWork.SaveChangesAsync();

        return new AreaDTO
        {
            Id = area.Id,
            Nombre = area.Nombre,
            Estado = area.Estado
        };
    }

    public async Task UpdateAsync(int id, UpdateAreaDTO areaDto)
    {
        var area = await _unitOfWork.Areas.GetByIdAsync(id);
        if (area == null)
        {
            throw new KeyNotFoundException("El área no existe");
        }

        if (await ExistsByNameAsync(areaDto.Nombre, id))
        {
            throw new InvalidOperationException("Ya existe un área con ese nombre");
        }

        area.Nombre = areaDto.Nombre;
        area.Estado = areaDto.Estado;

        await _unitOfWork.Areas.UpdateAsync(area);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task DeleteAsync(int id)
    {
        var area = await _unitOfWork.Areas.GetByIdAsync(id);
        if (area == null)
        {
            throw new KeyNotFoundException("El área no existe");
        }

        // Verificar si hay movimientos asociados
        var movimientos = await _unitOfWork.Movimientos.FindAsync(m => m.AreaId == id);
        if (movimientos.Any())
        {
            throw new InvalidOperationException("No se puede eliminar el área porque tiene movimientos asociados");
        }

        await _unitOfWork.Areas.DeleteAsync(id);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task<bool> ExistsAsync(int id)
    {
        return await _unitOfWork.Areas.ExistsAsync(id);
    }

    public async Task<bool> ExistsByNameAsync(string nombre, int? excludeId = null)
    {
        var areas = await _unitOfWork.Areas.FindAsync(a => 
            a.Nombre.ToLower() == nombre.ToLower() && 
            (!excludeId.HasValue || a.Id != excludeId.Value));
        
        return areas.Any();
    }
} 