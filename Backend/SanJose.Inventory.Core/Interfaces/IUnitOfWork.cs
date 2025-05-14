namespace SanJose.Inventory.Core.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IRepository<Usuario> Usuarios { get; }
    IRepository<Area> Areas { get; }
    IRepository<Proveedor> Proveedores { get; }
    IRepository<Insumo> Insumos { get; }
    IRepository<Movimiento> Movimientos { get; }
    
    Task<int> SaveChangesAsync();
} 