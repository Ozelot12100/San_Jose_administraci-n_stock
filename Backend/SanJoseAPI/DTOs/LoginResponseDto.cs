namespace SanJoseAPI.DTOs
{
    public class LoginResponseDto
    {
        public int Id { get; set; }
        public string Usuario { get; set; }
        public string Rol { get; set; }
        public bool Exito { get; set; }
        public string Mensaje { get; set; }
        public int? IdArea { get; set; }
    }
} 