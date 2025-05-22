using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace SanJoseAPI.DTOs
{
    public class UsuarioDto
    {
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string Usuario { get; set; }

        [StringLength(20)]
        public string Rol { get; set; }

        public bool Activo { get; set; }

        [JsonPropertyName("id_area")]
        public int? IdArea { get; set; }

        public string Contrasena { get; set; }
    }
} 