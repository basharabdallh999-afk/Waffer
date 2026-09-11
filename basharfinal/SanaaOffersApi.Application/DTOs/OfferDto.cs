using Microsoft.AspNetCore.Http;

namespace SanaaOffersApi.Application.DTOs
{
    // Used for POST/PUT requests where the offer image arrives as an uploaded file
    public class OfferCreateDto
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal OriginalPrice { get; set; }
        public decimal DiscountedPrice { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsFlashSale { get; set; }
        public bool IsSponsored { get; set; } = false;
        public int DisplayPriority { get; set; } = 0;
        public bool IsActive { get; set; } = true;
        public int MerchantId { get; set; }
        public int CategoryId { get; set; }
        public IFormFile? Image { get; set; }
    }
}
