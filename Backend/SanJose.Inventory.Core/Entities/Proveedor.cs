using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJose.Inventory.Core.Entities;

[Table("proveedores")]
public class Proveedor
{
    [Key]
    [Column("id_proveedor")]
    public int Id { get; set; }

    [Required]
    [Column("nombre")]
    [StringLength(100)]
    public string Nombre { get; set; } = null!;

    [Column("telefono")]
    [StringLength(20)]
    public string? Telefono { get; set; }

    [Column("direccion")]
    public string? Direccion { get; set; }

    // Relaciones
    public virtual ICollection<Insumo> Insumos { get; set; } = new List<Insumo>();
} 