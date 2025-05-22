using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace SanJoseAPI.DTOs
{
    public class MovimientoDto
    {
        public int Id { get; set; }

        [Required]
        [StringLength(20)]
        [JsonPropertyName("tipo_movimiento")]
        public string TipoMovimiento { get; set; }

        public DateTime Fecha { get; set; } = DateTime.Now;

        [Required]
        public int Cantidad { get; set; }

        [JsonPropertyName("id_insumo")]
        [Required]
        public int IdInsumo { get; set; }

        [JsonPropertyName("id_usuario")]
        [Required]
        public int IdUsuario { get; set; }

        [JsonPropertyName("id_area")]
        [Required]
        public int IdArea { get; set; }

        // Propiedades de navegación para incluir detalles
        public InsumoDto Insumo { get; set; }
        public UsuarioDto Usuario { get; set; }
        public AreaDto Area { get; set; }
    }
} 