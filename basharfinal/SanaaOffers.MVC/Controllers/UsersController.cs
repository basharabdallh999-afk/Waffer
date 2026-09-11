using Microsoft.AspNetCore.Mvc;
using SanaaOffers.MVC.ViewModels;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffers.MVC.Controllers
{
    public class UsersController : Controller
    {
        private readonly IRepository<User> _userRepo;
        private readonly IPasswordHasher _passwordHasher;

        public UsersController(IRepository<User> userRepo, IPasswordHasher passwordHasher)
        {
            _userRepo = userRepo;
            _passwordHasher = passwordHasher;
        }

        // GET: Users
        public async Task<IActionResult> Index()
        {
            ViewData["ActivePage"] = "Users";
            var users = await _userRepo.GetAllAsync(u => u.Merchants);
            return View(users);
        }

        // GET: Users/Details/5
        public async Task<IActionResult> Details(int id)
        {
            ViewData["ActivePage"] = "Users";
            var user = await _userRepo.GetByIdAsync(id, u => u.Merchants);
            if (user == null)
            {
                TempData["ErrorMessage"] = "المستخدم المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }
            return View(user);
        }

        // GET: Users/Create
        public IActionResult Create()
        {
            ViewData["ActivePage"] = "Users";
            return View(new UserFormViewModel());
        }

        // POST: Users/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(UserFormViewModel model)
        {
            ViewData["ActivePage"] = "Users";
            if (string.IsNullOrWhiteSpace(model.Password))
            {
                ModelState.AddModelError("Password", "كلمة المرور مطلوبة لإنشاء الحساب.");
            }

            var allUsers = await _userRepo.GetAllAsync();
            if (allUsers.Any(u => u.Email.Equals(model.Email.Trim(), StringComparison.OrdinalIgnoreCase)))
            {
                ModelState.AddModelError("Email", "البريد الإلكتروني مسجل مسبقاً لمستخدم آخر.");
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var user = new User
            {
                FullName = model.FullName.Trim(),
                Email = model.Email.Trim().ToLower(),
                Phone = model.Phone?.Trim(),
                Role = model.Role,
                PasswordHash = _passwordHasher.Hash(model.Password!),
                CreatedAt = DateTime.UtcNow
            };

            await _userRepo.AddAsync(user);
            TempData["SuccessMessage"] = $"تمت إضافة المستخدم \"{user.FullName}\" بنجاح.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Users/Edit/5
        public async Task<IActionResult> Edit(int id)
        {
            ViewData["ActivePage"] = "Users";
            var user = await _userRepo.GetByIdAsync(id);
            if (user == null)
            {
                TempData["ErrorMessage"] = "المستخدم المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }

            var vm = new UserFormViewModel
            {
                Id = user.Id,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                Role = user.Role
            };

            return View(vm);
        }

        // POST: Users/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, UserFormViewModel model)
        {
            ViewData["ActivePage"] = "Users";
            if (id != model.Id)
            {
                return NotFound();
            }

            var allUsers = await _userRepo.GetAllAsync();
            if (allUsers.Any(u => u.Id != id && u.Email.Equals(model.Email.Trim(), StringComparison.OrdinalIgnoreCase)))
            {
                ModelState.AddModelError("Email", "البريد الإلكتروني مسجل مسبقاً لمستخدم آخر.");
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var user = await _userRepo.GetByIdAsync(id);
            if (user == null)
            {
                TempData["ErrorMessage"] = "المستخدم المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }

            user.FullName = model.FullName.Trim();
            user.Email = model.Email.Trim().ToLower();
            user.Phone = model.Phone?.Trim();
            user.Role = model.Role;

            if (!string.IsNullOrWhiteSpace(model.Password))
            {
                user.PasswordHash = _passwordHasher.Hash(model.Password);
            }

            await _userRepo.UpdateAsync(user);
            TempData["SuccessMessage"] = $"تم تحديث بيانات المستخدم \"{user.FullName}\" بنجاح.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Users/Delete/5
        public async Task<IActionResult> Delete(int id)
        {
            ViewData["ActivePage"] = "Users";
            var user = await _userRepo.GetByIdAsync(id, u => u.Merchants);
            if (user == null)
            {
                TempData["ErrorMessage"] = "المستخدم المطلوب غير موجود.";
                return RedirectToAction(nameof(Index));
            }
            return View(user);
        }

        // POST: Users/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var user = await _userRepo.GetByIdAsync(id);
            if (user != null)
            {
                await _userRepo.DeleteAsync(id);
                TempData["SuccessMessage"] = $"تم حذف المستخدم \"{user.FullName}\" بنجاح.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}