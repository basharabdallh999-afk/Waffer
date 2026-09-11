using System.ComponentModel.DataAnnotations;

namespace SanaaOffersApi.Domain.Entities
{
    public enum UserRole
    {
        Consumer = 0,
        Merchant = 1,
        Admin = 2
    }

    public class User
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required, MaxLength(150)]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? Phone { get; set; }

        [Required]
        public UserRole Role { get; set; } = UserRole.Consumer;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation: a user with role Merchant can own multiple merchant stores
        public ICollection<Merchant> Merchants { get; set; } = new List<Merchant>();
    }
}
