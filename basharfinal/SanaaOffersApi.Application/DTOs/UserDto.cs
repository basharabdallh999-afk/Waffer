using SanaaOffersApi.Domain.Entities;

namespace SanaaOffersApi.Application.DTOs
{
    public class UserCreateDto
    {
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public UserRole Role { get; set; } = UserRole.Consumer;
    }
}
