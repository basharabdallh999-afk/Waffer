using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using SanaaOffers.MVC.ViewModels;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffers.MVC.Controllers
{
    public class OffersController : Controller
    {
        private readonly IRepository<Offer> _offerRepo;
        private readonly IRepository<Merchant> _merchantRepo;
        private readonly IRepository<Category> _categoryRepo;
        private readonly IImageStorageService _imageService;

        public OffersController(
            IRepository<Offer> offerRepo,
            IRepository<Merchant> merchantRepo,
            IRepository<Category> categoryRepo,
            IImageStorageService imageService)
        {
            _offerRepo = offerRepo;
            _merchantRepo = merchantRepo;
            _categoryRepo = categoryRepo;
            _imageService = imageService;
        }

        // GET: Offers
        public async Task<IActionResult> Index(string? filter = "all")
        {
            ViewData["ActivePage"] = "Offers";
            var allOffers = (await _offerRepo.GetAllAsync(o => o.Merchant!, o => o.Category!)).ToList();

            ViewBag.TotalCount = allOffers.Count;
            ViewBag.ActiveCount = allOffers.Count(o => !o.IsExpired && o.IsActive);
            ViewBag.SponsoredCount = allOffers.Count(o => o.IsSponsored && !o.IsExpired);
            ViewBag.FlashCount = allOffers.Count(o => o.IsFlashSale && !o.IsExpired);
            ViewBag.CurrentFilter = filter ?? "all";

            var filtered = filter switch
            {
                "active" => allOffers.Where(o => !o.IsExpired && o.IsActive).ToList(),
                "sponsored" => allOffers.Where(o => o.IsSponsored).OrderByDescending(o => o.DisplayPriority).ToList(),
                "flash" => allOffers.Where(o => o.IsFlashSale && !o.IsExpired).ToList(),
                _ => allOffers
            };

            return View(filtered);
        }

        // POST: Offers/ToggleSponsored/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ToggleSponsored(int id)
        {
            var offer = await _offerRepo.GetByIdAsync(id);
            if (offer != null)
            {
                offer.IsSponsored = !offer.IsSponsored;
                await _offerRepo.UpdateAsync(offer);
                TempData["SuccessMessage"] = offer.IsSponsored 
                    ? $"تم تعيين العرض \"{offer.Title}\" كإعلان مميز في الشريط الإعلاني." 
                    : $"تم إزالة العرض \"{offer.Title}\" من الشريط الإعلاني المميز.";
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: Offers/Details/5
        public async Task<IActionResult> Details(int id)
        {
            ViewData["ActivePage"] = "Offers";
            var offer = await _offerRepo.GetByIdAsync(id, o => o.Merchant!, o => o.Category!);
            if (offer == null)
            {
                TempData["ErrorMessage"] = "العرض المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }
            return View(offer);
        }

        // GET: Offers/Create
        public async Task<IActionResult> Create()
        {
            ViewData["ActivePage"] = "Offers";
            var merchants = await _merchantRepo.GetAllAsync();
            var categories = await _categoryRepo.GetAllAsync();

            var vm = new OfferFormViewModel
            {
                StartDate = DateTime.Today,
                EndDate = DateTime.Today.AddDays(30),
                MerchantList = new SelectList(merchants, "Id", "StoreName"),
                CategoryList = new SelectList(categories, "Id", "Name")
            };

            return View(vm);
        }

        // POST: Offers/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(OfferFormViewModel model)
        {
            ViewData["ActivePage"] = "Offers";
            if (model.DiscountedPrice >= model.OriginalPrice)
            {
                ModelState.AddModelError("DiscountedPrice", "يجب أن يكون سعر الخصم أقل من السعر الأصلي.");
            }

            if (model.EndDate <= model.StartDate)
            {
                ModelState.AddModelError("EndDate", "يجب أن يكون تاريخ النهاية بعد تاريخ البداية.");
            }

            if (!ModelState.IsValid)
            {
                var merchants = await _merchantRepo.GetAllAsync();
                var categories = await _categoryRepo.GetAllAsync();
                model.MerchantList = new SelectList(merchants, "Id", "StoreName", model.MerchantId);
                model.CategoryList = new SelectList(categories, "Id", "Name", model.CategoryId);
                return View(model);
            }

            string? imageUrl = null;
            if (model.Image != null && model.Image.Length > 0)
            {
                imageUrl = await _imageService.SaveImageAsync(model.Image);
            }

            var offer = new Offer
            {
                Title = model.Title.Trim(),
                Description = model.Description?.Trim(),
                OriginalPrice = model.OriginalPrice,
                DiscountedPrice = model.DiscountedPrice,
                StartDate = DateTime.SpecifyKind(model.StartDate, DateTimeKind.Utc),
                EndDate = DateTime.SpecifyKind(model.EndDate, DateTimeKind.Utc),
                IsFlashSale = model.IsFlashSale,
                IsSponsored = model.IsSponsored,
                DisplayPriority = model.DisplayPriority,
                IsActive = model.IsActive,
                MerchantId = model.MerchantId,
                CategoryId = model.CategoryId,
                ImageUrl = imageUrl,
                CreatedAt = DateTime.UtcNow
            };

            await _offerRepo.AddAsync(offer);
            TempData["SuccessMessage"] = $"تمت إضافة العرض \"{offer.Title}\" بنجاح.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Offers/Edit/5
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["ActivePage"] = "Offers";
            var offer = await _offerRepo.GetByIdAsync(id);
            if (offer == null)
            {
                TempData["ErrorMessage"] = "العرض المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }

            var merchants = await _merchantRepo.GetAllAsync();
            var categories = await _categoryRepo.GetAllAsync();

            var vm = new OfferFormViewModel
            {
                Id = offer.Id,
                Title = offer.Title,
                Description = offer.Description,
                OriginalPrice = offer.OriginalPrice,
                DiscountedPrice = offer.DiscountedPrice,
                StartDate = offer.StartDate,
                EndDate = offer.EndDate,
                IsFlashSale = offer.IsFlashSale,
                IsSponsored = offer.IsSponsored,
                DisplayPriority = offer.DisplayPriority,
                IsActive = offer.IsActive,
                MerchantId = offer.MerchantId,
                CategoryId = offer.CategoryId,
                ExistingImageUrl = offer.ImageUrl,
                MerchantList = new SelectList(merchants, "Id", "StoreName", offer.MerchantId),
                CategoryList = new SelectList(categories, "Id", "Name", offer.CategoryId)
            };

            return View(vm);
        }

        // POST: Offers/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, OfferFormViewModel model)
        {
            ViewData["ActivePage"] = "Offers";
            if (id != model.Id)
            {
                return NotFound();
            }

            if (model.DiscountedPrice >= model.OriginalPrice)
            {
                ModelState.AddModelError("DiscountedPrice", "يجب أن يكون سعر الخصم أقل من السعر الأصلي.");
            }

            if (model.EndDate <= model.StartDate)
            {
                ModelState.AddModelError("EndDate", "يجب أن يكون تاريخ النهاية بعد تاريخ البداية.");
            }

            if (!ModelState.IsValid)
            {
                var merchants = await _merchantRepo.GetAllAsync();
                var categories = await _categoryRepo.GetAllAsync();
                model.MerchantList = new SelectList(merchants, "Id", "StoreName", model.MerchantId);
                model.CategoryList = new SelectList(categories, "Id", "Name", model.CategoryId);
                return View(model);
            }

            var offer = await _offerRepo.GetByIdAsync(id);
            if (offer == null)
            {
                TempData["ErrorMessage"] = "العرض المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }

            if (model.Image != null && model.Image.Length > 0)
            {
                offer.ImageUrl = await _imageService.SaveImageAsync(model.Image);
            }

            offer.Title = model.Title.Trim();
            offer.Description = model.Description?.Trim();
            offer.OriginalPrice = model.OriginalPrice;
            offer.DiscountedPrice = model.DiscountedPrice;
            offer.StartDate = DateTime.SpecifyKind(model.StartDate, DateTimeKind.Utc);
            offer.EndDate = DateTime.SpecifyKind(model.EndDate, DateTimeKind.Utc);
            offer.IsFlashSale = model.IsFlashSale;
            offer.IsSponsored = model.IsSponsored;
            offer.DisplayPriority = model.DisplayPriority;
            offer.IsActive = model.IsActive;
            offer.MerchantId = model.MerchantId;
            offer.CategoryId = model.CategoryId;

            await _offerRepo.UpdateAsync(offer);
            TempData["SuccessMessage"] = $"تم تحديث العرض \"{offer.Title}\" بنجاح.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Offers/Delete/5
        public async Task<IActionResult> Delete(int id)
        {
            ViewData["ActivePage"] = "Offers";
            var offer = await _offerRepo.GetByIdAsync(id, o => o.Merchant!, o => o.Category!);
            if (offer == null)
            {
                TempData["ErrorMessage"] = "العرض المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }
            return View(offer);
        }

        // POST: Offers/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var offer = await _offerRepo.GetByIdAsync(id);
            if (offer != null)
            {
                await _offerRepo.DeleteAsync(id);
                TempData["SuccessMessage"] = $"تم حذف العرض \"{offer.Title}\" بنجاح.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}