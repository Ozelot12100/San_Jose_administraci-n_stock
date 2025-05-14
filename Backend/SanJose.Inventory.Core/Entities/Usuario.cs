using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJose.Inventory.Core.Entities;

[Table("usuarios")]
public class Usuario
{
    [Key]
    [Column("id_usuario")]
    public int Id { get; set; }

    [Required]
    [Column("usuario")]
    [StringLength(50)]
    public string NombreUsuario { get; set; } = null!;

    [Required]
    [Column("contrasena")]
    [StringLength(100)]
    public string Contrasena { get; set; } = null!;

    [Required]
    [Column("rol")]
    [StringLength(20)]
    public string Rol { get; set; } = "admin";

    [Column("activo")]
    public bool Activo { get; set; } = true;
} 