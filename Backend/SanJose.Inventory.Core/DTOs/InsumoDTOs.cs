using System.ComponentModel.DataAnnotations;

namespace SanJose.Inventory.Core.DTOs;

public class InsumoDTO
{
    public int Id { get; set; }
    public string Nombre { get; set; } = null!;
    public string? Tipo { get; set; }
    public string? Presentacion { get; set; }
    public int Cantidad { get; set; }
    public decimal Precio { get; set; }
    public DateOnly? FechaCaducidad { get; set; }
    public int? ProveedorId { get; set; }
    public string? ProveedorNombre { get; set; }
}

public class CreateInsumoDTO
{
    [Required]
    [StringLength(100)]
    public string Nombre { get; set; } = null!;

    [StringLength(50)]
    public string? Tipo { get; set; }

    [StringLength(50)]
    public string? Presentacion { get; set; }

    [Required]
    [Range(0, double.MaxValue)]
    public decimal Precio { get; set; }

    public DateOnly? FechaCaducidad { get; set; }

    public int? ProveedorId { get; set; }
}

public class UpdateInsumoDTO
{
    [Required]
    [StringLength(100)]
    public string Nombre { get; set; } = null!;

    [StringLength(50)]
    public string? Tipo { get; set; }

    [StringLength(50)]
    public string? Presentacion { get; set; }

    public DateOnly? FechaCaducidad { get; set; }

    public int? ProveedorId { get; set; }
} 