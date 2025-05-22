using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJoseAPI.Models
{
    [Table("usuarios")]
    public class Usuario
    {
        [Key]
        [Column("id_usuario")]
        public int Id { get; set; }

        [Required]
        [Column("usuario")]
        [StringLength(50)]
        public string NombreUsuario { get; set; }

        [Column("contrasena")]
        [StringLength(100)]
        public string Contrasena { get; set; }

        [Column("rol")]
        [StringLength(20)]
        public string Rol { get; set; } = "empleado";

        [Column("activo")]
        public bool Activo { get; set; } = true;

        [Column("id_area")]
        public int? IdArea { get; set; }

        // Relaciones
        [ForeignKey("IdArea")]
        public Area Area { get; set; }
    }
} 