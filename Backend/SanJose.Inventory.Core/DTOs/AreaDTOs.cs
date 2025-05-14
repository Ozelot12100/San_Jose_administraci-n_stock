using System.ComponentModel.DataAnnotations;

namespace SanJose.Inventory.Core.DTOs;

public class AreaDTO
{
    public int Id { get; set; }
    public string Nombre { get; set; } = null!;
    public bool Estado { get; set; }
}

public class CreateAreaDTO
{
    [Required(ErrorMessage = "El nombre del área es requerido")]
    [StringLength(100, ErrorMessage = "El nombre no puede exceder los 100 caracteres")]
    public string Nombre { get; set; } = null!;

    public bool Estado { get; set; } = true;
}

public class UpdateAreaDTO
{
    [Required(ErrorMessage = "El nombre del área es requerido")]
    [StringLength(100, ErrorMessage = "El nombre no puede exceder los 100 caracteres")]
    public string Nombre { get; set; } = null!;

    public bool Estado { get; set; }
} 