using Microsoft.EntityFrameworkCore;
using SanJoseAPI.Models;

namespace SanJoseAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Area> Areas { get; set; }
        public DbSet<Proveedor> Proveedores { get; set; }
        public DbSet<Insumo> Insumos { get; set; }
        public DbSet<Movimiento> Movimientos { get; set; }
        public DbSet<Usuario> Usuarios { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configuración de las relaciones entre entidades
            modelBuilder.Entity<Insumo>()
                .HasOne(i => i.Proveedor)
                .WithMany(p => p.Insumos)
                .HasForeignKey(i => i.IdProveedor)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<Movimiento>()
                .HasOne(m => m.Insumo)
                .WithMany(i => i.Movimientos)
                .HasForeignKey(m => m.IdInsumo)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Movimiento>()
                .HasOne(m => m.Area)
                .WithMany(a => a.Movimientos)
                .HasForeignKey(m => m.IdArea)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Movimiento>()
                .HasOne(m => m.Usuario)
                .WithMany()
                .HasForeignKey(m => m.IdUsuario)
                .OnDelete(DeleteBehavior.Cascade);

            // Configuración de tipos de datos específicos
            modelBuilder.Entity<Movimiento>()
                .Property(m => m.TipoMovimiento)
                .HasConversion<string>();

            modelBuilder.Entity<Usuario>()
                .Property(u => u.Rol)
                .HasConversion<string>();
        }
    }
} 