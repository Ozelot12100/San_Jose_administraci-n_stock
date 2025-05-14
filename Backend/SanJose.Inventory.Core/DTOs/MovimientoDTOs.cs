using System.ComponentModel.DataAnnotations;

namespace SanJose.Inventory.Core.DTOs;

public class MovimientoDTO
{
    public int Id { get; set; }
    public string Tipo { get; set; } = null!;
    public DateTime Fecha { get; set; }
    public int Cantidad { get; set; }
    public int InsumoId { get; set; }
    public string InsumoNombre { get; set; } = null!;
    public int AreaId { get; set; }
    public string AreaNombre { get; set; } = null!;
}

public class CreateMovimientoDTO
{
    [Required]
    public string Tipo { get; set; } = null!; // "entrada" o "salida"

    [Required]
    [Range(1, int.MaxValue)]
    public int Cantidad { get; set; }

    [Required]
    public int InsumoId { get; set; }

    [Required]
    public int AreaId { get; set; }
}

public class MovimientoReporteDTO
{
    public string InsumoNombre { get; set; } = null!;
    public string Tipo { get; set; } = null!;
    public int CantidadTotal { get; set; }
    public decimal ValorTotal { get; set; }
    public string AreaNombre { get; set; } = null!;
    public DateTime Fecha { get; set; }
} 