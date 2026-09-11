using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanaaOffersApi.Domain.Entities
{
    public class Offer
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(150)]
        public string Title { get; set; } = string.Empty;

        [MaxLength(1000)]
        public string? Description { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal OriginalPrice { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal DiscountedPrice { get; set; }

        // Relative path under wwwroot/images, e.g. "images/offer_12.jpg"
        [MaxLength(300)]
        public string? ImageUrl { get; set; }

        public DateTime StartDate { get; set; } = DateTime.UtcNow;

        [Required]
        public DateTime EndDate { get; set; }

        // "Flash Sale" feature
        public bool IsFlashSale { get; set; } = false;

        // Sponsored / Paid banner ad (rotates in 3-second carousel)
        public bool IsSponsored { get; set; } = false;

        // Priority order for sponsored banners
        public int DisplayPriority { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        public int ViewsCount { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // FK: Merchant that published the offer
        [Required]
        [ForeignKey(nameof(Merchant))]
        public int MerchantId { get; set; }
        public Merchant? Merchant { get; set; }

        // FK: Category the offer belongs to
        [Required]
        [ForeignKey(nameof(Category))]
        public int CategoryId { get; set; }
        public Category? Category { get; set; }

        [NotMapped]
        public bool IsExpired => EndDate < DateTime.UtcNow;

        [NotMapped]
        public decimal DiscountPercentage =>
            OriginalPrice > 0 ? Math.Round((1 - (DiscountedPrice / OriginalPrice)) * 100, 1) : 0;
    }
}
