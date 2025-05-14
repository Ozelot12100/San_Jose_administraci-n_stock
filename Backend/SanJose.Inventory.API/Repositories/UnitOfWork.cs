using SanJose.Inventory.API.Data;
using SanJose.Inventory.Core.Entities;
using SanJose.Inventory.Core.Interfaces;

namespace SanJose.Inventory.API.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;
    private IRepository<Usuario>? _usuarios;
    private IRepository<Area>? _areas;
    private IRepository<Proveedor>? _proveedores;
    private IRepository<Insumo>? _insumos;
    private IRepository<Movimiento>? _movimientos;

    public UnitOfWork(ApplicationDbContext context)
    {
        _context = context;
    }

    public IRepository<Usuario> Usuarios => _usuarios ??= new Repository<Usuario>(_context);
    public IRepository<Area> Areas => _areas ??= new Repository<Area>(_context);
    public IRepository<Proveedor> Proveedores => _proveedores ??= new Repository<Proveedor>(_context);
    public IRepository<Insumo> Insumos => _insumos ??= new Repository<Insumo>(_context);
    public IRepository<Movimiento> Movimientos => _movimientos ??= new Repository<Movimiento>(_context);

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }

    public void Dispose()
    {
        _context.Dispose();
    }
} 