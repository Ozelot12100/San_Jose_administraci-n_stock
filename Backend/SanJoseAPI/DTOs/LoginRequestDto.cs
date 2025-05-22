using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace SanJoseAPI.DTOs
{
    public class LoginRequestDto
    {
        [Required]
        [JsonPropertyName("usuario")]
        public string NombreUsuario { get; set; }

        [Required]
        [JsonPropertyName("password")]
        public string Contrasena { get; set; }
    }
} 