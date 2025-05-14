using Microsoft.EntityFrameworkCore;
using SanJose.Inventory.Core.Entities;

namespace SanJose.Inventory.API.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Usuario> Usuarios { get; set; } = null!;
    public DbSet<Area> Areas { get; set; } = null!;
    public DbSet<Proveedor> Proveedores { get; set; } = null!;
    public DbSet<Insumo> Insumos { get; set; } = null!;
    public DbSet<Movimiento> Movimientos { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configuración de Usuario
        modelBuilder.Entity<Usuario>()
            .HasIndex(u => u.NombreUsuario)
            .IsUnique();

        // Configuración de Area
        modelBuilder.Entity<Area>()
            .HasIndex(a => a.Nombre)
            .IsUnique();

        // Configuración de Proveedor
        modelBuilder.Entity<Proveedor>()
            .HasIndex(p => p.Nombre)
            .IsUnique();

        // Configuración de Insumo
        modelBuilder.Entity<Insumo>()
            .HasIndex(i => i.Nombre)
            .IsUnique();

        // Configuración de Movimiento
        modelBuilder.Entity<Movimiento>()
            .HasOne(m => m.Insumo)
            .WithMany(i => i.Movimientos)
            .HasForeignKey(m => m.InsumoId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Movimiento>()
            .HasOne(m => m.Area)
            .WithMany(a => a.Movimientos)
            .HasForeignKey(m => m.AreaId)
            .OnDelete(DeleteBehavior.Restrict);

        // Datos iniciales
        modelBuilder.Entity<Usuario>().HasData(
            new Usuario
            {
                Id = 1,
                NombreUsuario = "admin",
                Contrasena = BCrypt.Net.BCrypt.HashPassword("admin"),
                Rol = "admin",
                Activo = true
            }
        );

        modelBuilder.Entity<Area>().HasData(
            new Area { Id = 1, Nombre = "Urgencias", Estado = true },
            new Area { Id = 2, Nombre = "Quirófano", Estado = true }
        );
    }
} 