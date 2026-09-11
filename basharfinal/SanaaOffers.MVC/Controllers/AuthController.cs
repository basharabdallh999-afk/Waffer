using Microsoft.AspNetCore.Mvc;
using SanaaOffers.MVC.ViewModels;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffers.MVC.Controllers
{
    public class AuthController : Controller
    {
        private readonly IRepository<User> _userRepo;
        private readonly IPasswordHasher _hasher;

        public AuthController(IRepository<User> userRepo, IPasswordHasher hasher)
        {
            _userRepo = userRepo;
            _hasher = hasher;
        }

        [HttpGet]
        public IActionResult Login(string? returnUrl = null)
        {
            if (HttpContext.Session.GetString("UserEmail") != null)
            {
                return RedirectToAction("Index", "Dashboard");
            }

            ViewData["ReturnUrl"] = returnUrl;
            return View(new LoginViewModel { ReturnUrl = returnUrl });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var users = await _userRepo.GetAllAsync();
            var user = users.FirstOrDefault(u => u.Email.Equals(model.Username.Trim(), StringComparison.OrdinalIgnoreCase));

            // If admin or test credentials and user does not exist yet, auto-provision
            if (user == null && (model.Username.Trim().Equals("admin@waffer.com", StringComparison.OrdinalIgnoreCase) || model.Username.Trim().Equals("admin", StringComparison.OrdinalIgnoreCase)))
            {
                user = new User
                {
                    FullName = "مدير النظام",
                    Email = "admin@waffer.com",
                    Role = UserRole.Admin,
                    PasswordHash = _hasher.Hash(model.Password)
                };
                await _userRepo.AddAsync(user);
            }

            if (user == null || !_hasher.Verify(model.Password, user.PasswordHash))
            {
                ModelState.AddModelError(string.Empty, "بيانات الدخول غير صحيحة، يرجى التأكد من البريد وكلمة المرور.");
                return View(model);
            }

            // Set Session
            HttpContext.Session.SetInt32("UserId", user.Id);
            HttpContext.Session.SetString("UserName", user.FullName);
            HttpContext.Session.SetString("UserEmail", user.Email);
            HttpContext.Session.SetString("UserRole", user.Role.ToString());

            TempData["SuccessMessage"] = $"مرحباً بك مجدداً، {user.FullName}!";

            if (!string.IsNullOrEmpty(model.ReturnUrl) && Url.IsLocalUrl(model.ReturnUrl))
            {
                return Redirect(model.ReturnUrl);
            }

            return RedirectToAction("Index", "Dashboard");
        }

        [HttpGet]
        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            TempData["SuccessMessage"] = "تم تسجيل الخروج بنجاح.";
            return RedirectToAction("Login", "Auth");
        }
    }
}