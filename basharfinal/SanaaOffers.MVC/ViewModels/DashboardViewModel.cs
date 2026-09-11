using SanaaOffersApi.Domain.Entities;

namespace SanaaOffers.MVC.ViewModels
{
    public class DashboardViewModel
    {
        public int TotalUsers { get; set; }
        public int TotalMerchants { get; set; }
        public int TotalCategories { get; set; }
        public int TotalOffers { get; set; }

        public int ActiveOffers { get; set; }
        public int FlashSaleOffers { get; set; }
        public int ApprovedMerchants { get; set; }
        public int PendingMerchantsCount { get; set; }
        public int SuspendedMerchantsCount { get; set; }
        public int SponsoredOffersCount { get; set; }
        public int ActiveUsers { get; set; }

        // For Chart.js: last 6 months offer counts
        public List<string> ChartLabels { get; set; } = new();
        public List<int> ChartOfferData { get; set; } = new();

        // Recent offers table
        public List<RecentOfferRow> RecentOffers { get; set; } = new();

        // New Pending Merchants for Admin Review Notifications
        public List<Merchant> PendingMerchants { get; set; } = new();
    }

    public class RecentOfferRow
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        public decimal OriginalPrice { get; set; }
        public decimal DiscountedPrice { get; set; }
        public decimal DiscountPercentage { get; set; }
        public string MerchantName { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public bool IsFlashSale { get; set; }
        public bool IsExpired { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
