using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJoseAPI.Models
{
    [Table("proveedores")]
    public class Proveedor
    {
        [Key]
        [Column("id_proveedor")]
        public int Id { get; set; }

        [Required]
        [Column("nombre_proveedor")]
        [StringLength(100)]
        public string NombreProveedor { get; set; }

        [Column("telefono")]
        [StringLength(20)]
        public string Telefono { get; set; }

        [Column("direccion")]
        public string Direccion { get; set; }

        // Relaciones
        public ICollection<Insumo> Insumos { get; set; }
    }
} 