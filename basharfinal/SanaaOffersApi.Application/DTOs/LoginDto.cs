namespace SanaaOffersApi.Application.DTOs
{
    public class LoginDto
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class LoginResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public UserResponseDto User { get; set; } = new();
    }

    public class UserResponseDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public bool IsMerchant { get; set; }
        public string? StoreName { get; set; }
        public int? MerchantId { get; set; }
        public bool IsApproved { get; set; } = true;
        public bool IsSuspended { get; set; } = false;
        public string? SuspensionReason { get; set; }
        public DateTime? SuspendedUntil { get; set; }
    }
}
