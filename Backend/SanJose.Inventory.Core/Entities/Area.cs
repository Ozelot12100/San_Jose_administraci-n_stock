using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJose.Inventory.Core.Entities;

[Table("areas")]
public class Area
{
    [Key]
    [Column("id_area")]
    public int Id { get; set; }

    [Required]
    [Column("nombre")]
    [StringLength(100)]
    public string Nombre { get; set; } = null!;

    [Column("estado")]
    public bool Estado { get; set; } = true;

    // Relaciones
    public virtual ICollection<Movimiento> Movimientos { get; set; } = new List<Movimiento>();
} 