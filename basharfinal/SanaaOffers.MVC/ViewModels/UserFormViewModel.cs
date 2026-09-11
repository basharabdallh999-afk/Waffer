using System.ComponentModel.DataAnnotations;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffers.MVC.ViewModels
{
    public class UserFormViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "الاسم الكامل مطلوب")]
        [Display(Name = "الاسم الكامل")]
        [MaxLength(100, ErrorMessage = "الاسم يجب ألا يتجاوز 100 حرف")]
        public string FullName { get; set; } = string.Empty;

        [Required(ErrorMessage = "البريد الإلكتروني مطلوب")]
        [EmailAddress(ErrorMessage = "البريد الإلكتروني غير صالح")]
        [Display(Name = "البريد الإلكتروني")]
        public string Email { get; set; } = string.Empty;

        [Display(Name = "رقم الهاتف")]
        [Phone(ErrorMessage = "رقم الهاتف غير صالح")]
        public string? Phone { get; set; }

        [Required(ErrorMessage = "الدور مطلوب")]
        [Display(Name = "نوع الحساب / الدور")]
        public UserRole Role { get; set; } = UserRole.Consumer;

        [Display(Name = "كلمة المرور")]
        [DataType(DataType.Password)]
        public string? Password { get; set; }

        [Display(Name = "تأكيد كلمة المرور")]
        [DataType(DataType.Password)]
        [Compare("Password", ErrorMessage = "كلمتا المرور غير متطابقتين")]
        public string? ConfirmPassword { get; set; }
    }
}