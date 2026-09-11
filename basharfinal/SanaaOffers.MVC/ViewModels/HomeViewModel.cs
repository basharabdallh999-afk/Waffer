using SanaaOffersApi.Domain.Entities;

namespace SanaaOffers.MVC.ViewModels
{
    public class HomeViewModel
    {
        public List<Category> Categories { get; set; } = new();
        public List<Merchant> Merchants { get; set; } = new();
        public List<Offer> FlashSales { get; set; } = new();
        public List<Offer> AllOffers { get; set; } = new();
        public int TotalOffersCount { get; set; }
        public int TotalMerchantsCount { get; set; }
        public int TotalCategoriesCount { get; set; }
        public string? SelectedCategory { get; set; }
        public string? SearchQuery { get; set; }
    }
}