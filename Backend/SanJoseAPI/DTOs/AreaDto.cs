using System.ComponentModel.DataAnnotations;

namespace SanJoseAPI.DTOs
{
    public class AreaDto
    {
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string NombreArea { get; set; }
    }
} 