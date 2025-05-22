using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanJoseAPI.Models
{
    [Table("movimientos")]
    public class Movimiento
    {
        [Key]
        [Column("id_movimiento")]
        public int Id { get; set; }

        [Required]
        [Column("tipo_movimiento")]
        [StringLength(20)]
        public string TipoMovimiento { get; set; }

        [Column("fecha")]
        public DateTime Fecha { get; set; } = DateTime.Now;

        [Required]
        [Column("cantidad")]
        public int Cantidad { get; set; }

        [Column("id_insumo")]
        public int IdInsumo { get; set; }

        [Column("id_usuario")]
        public int IdUsuario { get; set; }

        [Column("id_area")]
        public int IdArea { get; set; }

        // Relaciones
        [ForeignKey("IdInsumo")]
        public Insumo Insumo { get; set; }

        [ForeignKey("IdUsuario")]
        public Usuario Usuario { get; set; }

        [ForeignKey("IdArea")]
        public Area Area { get; set; }
    }
} 