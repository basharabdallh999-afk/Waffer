using Microsoft.AspNetCore.Http;

namespace SanaaOffersApi.Application.DTOs
{
    public class MerchantCreateDto
    {
        public string StoreName { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string? Address { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public int UserId { get; set; }
    }

    public class MerchantRegisterWithIdDto
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string StoreName { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
    }

    public class SuspendMerchantDto
    {
        public int? DurationDays { get; set; } // null or <=0 means permanent
        public string? Reason { get; set; }
        public bool IsPermanent { get; set; }
    }
}
