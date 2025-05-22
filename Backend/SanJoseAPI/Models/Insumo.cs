using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJoseAPI.Models
{
    [Table("insumos")]
    public class Insumo
    {
        [Key]
        [Column("id_insumo")]
        public int Id { get; set; }

        [Required]
        [Column("nombre_insumo")]
        [StringLength(100)]
        public string NombreInsumo { get; set; }

        [Column("descripcion")]
        public string Descripcion { get; set; }

        [Column("unidad")]
        [StringLength(20)]
        public string Unidad { get; set; }

        [Column("stock")]
        public int Stock { get; set; } = 0;

        [Column("stock_minimo")]
        public int StockMinimo { get; set; } = 0;

        [Column("id_proveedor")]
        public int? IdProveedor { get; set; }

        // Relaciones
        [ForeignKey("IdProveedor")]
        public Proveedor Proveedor { get; set; }

        public ICollection<Movimiento> Movimientos { get; set; }
    }
} 