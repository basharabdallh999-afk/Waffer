using Microsoft.AspNetCore.Mvc;
using SanaaOffers.MVC.ViewModels;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffers.MVC.Controllers
{
    public class CategoriesController : Controller
    {
        private readonly IRepository<Category> _categoryRepo;

        public CategoriesController(IRepository<Category> categoryRepo)
        {
            _categoryRepo = categoryRepo;
        }

        // GET: Categories
        public async Task<IActionResult> Index()
        {
            ViewData["ActivePage"] = "Categories";
            var categories = await _categoryRepo.GetAllAsync(c => c.Offers);
            return View(categories);
        }

        // GET: Categories/Details/5
        public async Task<IActionResult> Details(int id)
        {
            ViewData["ActivePage"] = "Categories";
            var category = await _categoryRepo.GetByIdAsync(id, c => c.Offers);
            if (category == null)
            {
                TempData["ErrorMessage"] = "التصنيف المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }
            return View(category);
        }

        // GET: Categories/Create
        public IActionResult Create()
        {
            ViewData["ActivePage"] = "Categories";
            return View(new CategoryFormViewModel());
        }

        // POST: Categories/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(CategoryFormViewModel model)
        {
            ViewData["ActivePage"] = "Categories";
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var category = new Category
            {
                Name = model.Name.Trim(),
                Description = model.Description?.Trim(),
                Icon = string.IsNullOrWhiteSpace(model.Icon) ? "bi-tag" : model.Icon.Trim()
            };

            await _categoryRepo.AddAsync(category);
            TempData["SuccessMessage"] = $"تمت إضافة التصنيف \"{category.Name}\" بنجاح.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Categories/Edit/5
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["ActivePage"] = "Categories";
            var category = await _categoryRepo.GetByIdAsync(id);
            if (category == null)
            {
                TempData["ErrorMessage"] = "التصنيف المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }

            var model = new CategoryFormViewModel
            {
                Id = category.Id,
                Name = category.Name,
                Description = category.Description,
                Icon = category.Icon
            };

            return View(model);
        }

        // POST: Categories/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, CategoryFormViewModel model)
        {
            ViewData["ActivePage"] = "Categories";
            if (id != model.Id)
            {
                return NotFound();
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var category = await _categoryRepo.GetByIdAsync(id);
            if (category == null)
            {
                TempData["ErrorMessage"] = "التصنيف المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }

            category.Name = model.Name.Trim();
            category.Description = model.Description?.Trim();
            category.Icon = string.IsNullOrWhiteSpace(model.Icon) ? "bi-tag" : model.Icon.Trim();

            await _categoryRepo.UpdateAsync(category);
            TempData["SuccessMessage"] = $"تم تحديث بيانات التصنيف \"{category.Name}\" بنجاح.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Categories/Delete/5
        public async Task<IActionResult> Delete(int id)
        {
            ViewData["ActivePage"] = "Categories";
            var category = await _categoryRepo.GetByIdAsync(id, c => c.Offers);
            if (category == null)
            {
                TempData["ErrorMessage"] = "التصنيف المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }
            return View(category);
        }

        // POST: Categories/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var category = await _categoryRepo.GetByIdAsync(id, c => c.Offers);
            if (category != null)
            {
                if (category.Offers != null && category.Offers.Any())
                {
                    TempData["ErrorMessage"] = $"لا يمكن حذف التصنيف \"{category.Name}\" لوجود عروض مرتبطة به ({category.Offers.Count} عرض).";
                    return RedirectToAction(nameof(Index));
                }

                await _categoryRepo.DeleteAsync(id);
                TempData["SuccessMessage"] = $"تم حذف التصنيف \"{category.Name}\" بنجاح.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}