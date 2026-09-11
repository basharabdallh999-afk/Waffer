using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using SanaaOffers.MVC.Models;
using SanaaOffers.MVC.ViewModels;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffers.MVC.Controllers
{
    public class HomeController : Controller
    {
        private readonly IRepository<Offer> _offerRepo;
        private readonly IRepository<Category> _categoryRepo;
        private readonly IRepository<Merchant> _merchantRepo;

        public HomeController(
            IRepository<Offer> offerRepo,
            IRepository<Category> categoryRepo,
            IRepository<Merchant> merchantRepo)
        {
            _offerRepo = offerRepo;
            _categoryRepo = categoryRepo;
            _merchantRepo = merchantRepo;
        }

        public async Task<IActionResult> Index(string? category, string? search, bool? flashOnly)
        {
            ViewData["ActivePage"] = "Home";

            var categories = (await _categoryRepo.GetAllAsync()).ToList();
            var merchants = (await _merchantRepo.GetAllAsync(m => m.Offers)).Where(m => m.IsApproved).ToList();
            var allOffers = (await _offerRepo.GetAllAsync(o => o.Merchant!, o => o.Category!)).ToList();

            var query = allOffers.Where(o => !o.IsExpired);

            if (!string.IsNullOrWhiteSpace(category))
            {
                query = query.Where(o => o.Category != null && o.Category.Name == category);
            }

            if (!string.IsNullOrWhiteSpace(search))
            {
                var s = search.Trim().ToLower();
                query = query.Where(o => o.Title.ToLower().Contains(s) || 
                                         (o.Description != null && o.Description.ToLower().Contains(s)) ||
                                         (o.Merchant != null && o.Merchant.StoreName.ToLower().Contains(s)));
            }

            if (flashOnly == true)
            {
                query = query.Where(o => o.IsFlashSale);
            }

            var vm = new HomeViewModel
            {
                Categories = categories,
                Merchants = merchants,
                FlashSales = allOffers.Where(o => o.IsFlashSale && !o.IsExpired).OrderByDescending(o => o.CreatedAt).Take(6).ToList(),
                AllOffers = query.OrderByDescending(o => o.CreatedAt).ToList(),
                TotalOffersCount = allOffers.Count,
                TotalMerchantsCount = merchants.Count,
                TotalCategoriesCount = categories.Count,
                SelectedCategory = category,
                SearchQuery = search
            };

            return View(vm);
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}