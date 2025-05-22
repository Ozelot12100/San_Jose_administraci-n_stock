using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJoseAPI.Models
{
    [Table("areas")]
    public class Area
    {
        [Key]
        [Column("id_area")]
        public int Id { get; set; }

        [Required]
        [Column("nombre_area")]
        [StringLength(50)]
        public string NombreArea { get; set; }

        // Relaciones
        public ICollection<Movimiento> Movimientos { get; set; }
    }
} 