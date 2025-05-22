using System;
using System.ComponentModel.DataAnnotations;

namespace SanJoseAPI.DTOs
{
    public class InsumoDto
    {
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string NombreInsumo { get; set; }

        public string Descripcion { get; set; }

        [StringLength(20)]
        public string Unidad { get; set; }

        public int Stock { get; set; } = 0;

        public int StockMinimo { get; set; } = 0;

        public int? IdProveedor { get; set; }
        public ProveedorDto? Proveedor { get; set; }
    }
} 