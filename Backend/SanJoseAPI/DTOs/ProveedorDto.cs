using System.ComponentModel.DataAnnotations;

namespace SanJoseAPI.DTOs
{
    public class ProveedorDto
    {
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string NombreProveedor { get; set; }

        [StringLength(20)]
        public string Telefono { get; set; }

        public string Direccion { get; set; }
    }
} 