using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using SanaaOffers.MVC.ViewModels;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffers.MVC.Controllers
{
    public class MerchantsController : Controller
    {
        private readonly IRepository<Merchant> _merchantRepo;
        private readonly IRepository<User> _userRepo;

        public MerchantsController(IRepository<Merchant> merchantRepo, IRepository<User> userRepo)
        {
            _merchantRepo = merchantRepo;
            _userRepo = userRepo;
        }

        // GET: Merchants
        public async Task<IActionResult> Index(string? filter = "all")
        {
            ViewData["ActivePage"] = "Merchants";
            var allMerchants = (await _merchantRepo.GetAllAsync(m => m.User!, m => m.Offers)).ToList();

            ViewBag.TotalCount = allMerchants.Count;
            ViewBag.PendingCount = allMerchants.Count(m => !m.IsApproved);
            ViewBag.ApprovedCount = allMerchants.Count(m => m.IsApproved && !m.IsCurrentlySuspended);
            ViewBag.SuspendedCount = allMerchants.Count(m => m.IsCurrentlySuspended);
            ViewBag.CurrentFilter = filter ?? "all";

            var filtered = filter switch
            {
                "pending" => allMerchants.Where(m => !m.IsApproved).ToList(),
                "approved" => allMerchants.Where(m => m.IsApproved && !m.IsCurrentlySuspended).ToList(),
                "suspended" => allMerchants.Where(m => m.IsCurrentlySuspended).ToList(),
                _ => allMerchants
            };

            return View(filtered);
        }

        // POST: Merchants/Approve/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Approve(int id)
        {
            var merchant = await _merchantRepo.GetByIdAsync(id);
            if (merchant != null)
            {
                merchant.IsApproved = true;
                merchant.IsSuspended = false;
                merchant.SuspensionReason = null;
                merchant.SuspendedUntil = null;
                await _merchantRepo.UpdateAsync(merchant);
                TempData["SuccessMessage"] = $"تمت الموافقة وتوثيق المتجر \"{merchant.StoreName}\" بنجاح، وأصبح قادراً على نشر العروض.";
            }
            return RedirectToAction(nameof(Index));
        }

        // POST: Merchants/Reject/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Reject(int id, string? reason)
        {
            var merchant = await _merchantRepo.GetByIdAsync(id);
            if (merchant != null)
            {
                merchant.IsApproved = false;
                merchant.IsSuspended = true;
                merchant.SuspensionReason = string.IsNullOrWhiteSpace(reason) ? "تم رفض طلب الانضمام لعدم استيفاء الشروط" : reason.Trim();
                await _merchantRepo.UpdateAsync(merchant);
                TempData["SuccessMessage"] = $"تم رفض طلب المتجر \"{merchant.StoreName}\" بنجاح.";
            }
            return RedirectToAction(nameof(Index));
        }

        // POST: Merchants/Suspend/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Suspend(int id, int durationDays, string? reason, bool isPermanent = false)
        {
            var merchant = await _merchantRepo.GetByIdAsync(id);
            if (merchant != null)
            {
                merchant.IsSuspended = true;
                merchant.SuspensionReason = string.IsNullOrWhiteSpace(reason) ? "مخالفة سياسات المنصة وشروط العروض" : reason.Trim();
                if (isPermanent || durationDays <= 0)
                {
                    merchant.SuspendedUntil = null; // إيقاف دائم
                }
                else
                {
                    merchant.SuspendedUntil = DateTime.UtcNow.AddDays(durationDays);
                }

                await _merchantRepo.UpdateAsync(merchant);
                var durationText = isPermanent || durationDays <= 0 ? "نهائياً" : $"لمدة {durationDays} يوم";
                TempData["SuccessMessage"] = $"تم إيقاف المتجر \"{merchant.StoreName}\" عن نشر العروض {durationText}.";
            }
            return RedirectToAction(nameof(Index));
        }

        // POST: Merchants/Unsuspend/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Unsuspend(int id)
        {
            var merchant = await _merchantRepo.GetByIdAsync(id);
            if (merchant != null)
            {
                merchant.IsSuspended = false;
                merchant.SuspensionReason = null;
                merchant.SuspendedUntil = null;
                await _merchantRepo.UpdateAsync(merchant);
                TempData["SuccessMessage"] = $"تم رفع الإيقاف عن المتجر \"{merchant.StoreName}\" بنجاح ويمكنه نشر العروض الآن.";
            }
            return RedirectToAction(nameof(Index));
        }

        // POST: Merchants/ToggleApproval/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ToggleApproval(int id)
        {
            var merchant = await _merchantRepo.GetByIdAsync(id);
            if (merchant != null)
            {
                merchant.IsApproved = !merchant.IsApproved;
                if (merchant.IsApproved)
                {
                    merchant.IsSuspended = false;
                }
                await _merchantRepo.UpdateAsync(merchant);
                TempData["SuccessMessage"] = merchant.IsApproved 
                    ? $"تم اعتماد المتجر \"{merchant.StoreName}\" بنجاح." 
                    : $"تم إلغاء اعتماد المتجر \"{merchant.StoreName}\".";
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: Merchants/Details/5
        public async Task<IActionResult> Details(int id)
        {
            ViewData["ActivePage"] = "Merchants";
            var merchant = await _merchantRepo.GetByIdAsync(id, m => m.User!, m => m.Offers);
            if (merchant == null)
            {
                TempData["ErrorMessage"] = "التاجر المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }
            return View(merchant);
        }

        // GET: Merchants/Create
        public async Task<IActionResult> Create()
        {
            ViewData["ActivePage"] = "Merchants";
            var users = await _userRepo.GetAllAsync();
            var merchantUsers = users.Where(u => u.Role == UserRole.Merchant || u.Role == UserRole.Admin).ToList();
            if (!merchantUsers.Any()) merchantUsers = users.ToList();

            var vm = new MerchantFormViewModel
            {
                UserList = new SelectList(merchantUsers, "Id", "FullName")
            };
            return View(vm);
        }

        // POST: Merchants/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(MerchantFormViewModel model)
        {
            ViewData["ActivePage"] = "Merchants";
            if (!ModelState.IsValid)
            {
                var users = await _userRepo.GetAllAsync();
                model.UserList = new SelectList(users, "Id", "FullName", model.UserId);
                return View(model);
            }

            var merchant = new Merchant
            {
                StoreName = model.StoreName.Trim(),
                Phone = model.Phone?.Trim(),
                Address = model.Address?.Trim(),
                Latitude = model.Latitude,
                Longitude = model.Longitude,
                IsApproved = model.IsApproved,
                UserId = model.UserId,
                CreatedAt = DateTime.UtcNow
            };

            await _merchantRepo.AddAsync(merchant);
            TempData["SuccessMessage"] = $"تمت إضافة المتجر \"{merchant.StoreName}\" بنجاح.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Merchants/Edit/5
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["ActivePage"] = "Merchants";
            var merchant = await _merchantRepo.GetByIdAsync(id);
            if (merchant == null)
            {
                TempData["ErrorMessage"] = "التاجر المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }

            var users = await _userRepo.GetAllAsync();
            var vm = new MerchantFormViewModel
            {
                Id = merchant.Id,
                StoreName = merchant.StoreName,
                Phone = merchant.Phone,
                Address = merchant.Address,
                Latitude = merchant.Latitude,
                Longitude = merchant.Longitude,
                IsApproved = merchant.IsApproved,
                UserId = merchant.UserId,
                UserList = new SelectList(users, "Id", "FullName", merchant.UserId)
            };

            return View(vm);
        }

        // POST: Merchants/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, MerchantFormViewModel model)
        {
            ViewData["ActivePage"] = "Merchants";
            if (id != model.Id)
            {
                return NotFound();
            }

            if (!ModelState.IsValid)
            {
                var users = await _userRepo.GetAllAsync();
                model.UserList = new SelectList(users, "Id", "FullName", model.UserId);
                return View(model);
            }

            var merchant = await _merchantRepo.GetByIdAsync(id);
            if (merchant == null)
            {
                TempData["ErrorMessage"] = "التاجر المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }

            merchant.StoreName = model.StoreName.Trim();
            merchant.Phone = model.Phone?.Trim();
            merchant.Address = model.Address?.Trim();
            merchant.Latitude = model.Latitude;
            merchant.Longitude = model.Longitude;
            merchant.IsApproved = model.IsApproved;
            merchant.UserId = model.UserId;

            await _merchantRepo.UpdateAsync(merchant);
            TempData["SuccessMessage"] = $"تم تحديث بيانات المتجر \"{merchant.StoreName}\" بنجاح.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Merchants/Delete/5
        public async Task<IActionResult> Delete(int id)
        {
            ViewData["ActivePage"] = "Merchants";
            var merchant = await _merchantRepo.GetByIdAsync(id, m => m.User!, m => m.Offers);
            if (merchant == null)
            {
                TempData["ErrorMessage"] = "التاجر المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }
            return View(merchant);
        }

        // POST: Merchants/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var merchant = await _merchantRepo.GetByIdAsync(id);
            if (merchant != null)
            {
                await _merchantRepo.DeleteAsync(id);
                TempData["SuccessMessage"] = $"تم حذف المتجر \"{merchant.StoreName}\" وجميع العروض التابعة له بنجاح.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}