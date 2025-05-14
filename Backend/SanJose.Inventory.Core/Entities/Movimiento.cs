using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJose.Inventory.Core.Entities;

[Table("movimientos")]
public class Movimiento
{
    [Key]
    [Column("id_movimiento")]
    public int Id { get; set; }

    [Required]
    [Column("tipo")]
    [StringLength(10)]
    public string Tipo { get; set; } = null!; // "entrada" o "salida"

    [Column("fecha")]
    public DateTime Fecha { get; set; } = DateTime.Now;

    [Required]
    [Column("cantidad")]
    public int Cantidad { get; set; }

    [Column("id_insumo")]
    public int InsumoId { get; set; }

    [Column("id_area")]
    public int AreaId { get; set; }

    // Relaciones
    [ForeignKey("InsumoId")]
    public virtual Insumo Insumo { get; set; } = null!;

    [ForeignKey("AreaId")]
    public virtual Area Area { get; set; } = null!;
} 