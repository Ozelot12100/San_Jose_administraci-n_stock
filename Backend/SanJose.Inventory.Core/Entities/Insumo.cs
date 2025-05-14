using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJose.Inventory.Core.Entities;

[Table("insumos")]
public class Insumo
{
    [Key]
    [Column("id_insumo")]
    public int Id { get; set; }

    [Required]
    [Column("nombre")]
    [StringLength(100)]
    public string Nombre { get; set; } = null!;

    [Column("tipo")]
    [StringLength(50)]
    public string? Tipo { get; set; }

    [Column("presentacion")]
    [StringLength(50)]
    public string? Presentacion { get; set; }

    [Column("cantidad")]
    public int Cantidad { get; set; } = 0;

    [Column("precio")]
    [Precision(10, 2)]
    public decimal Precio { get; set; }

    [Column("fecha_caducidad")]
    public DateOnly? FechaCaducidad { get; set; }

    [Column("id_proveedor")]
    public int? ProveedorId { get; set; }

    // Relaciones
    [ForeignKey("ProveedorId")]
    public virtual Proveedor? Proveedor { get; set; }
    public virtual ICollection<Movimiento> Movimientos { get; set; } = new List<Movimiento>();
} 