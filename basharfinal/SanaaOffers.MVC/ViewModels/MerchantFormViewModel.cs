using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace SanaaOffers.MVC.ViewModels
{
    public class MerchantFormViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "اسم المتجر مطلوب")]
        [Display(Name = "اسم المتجر / النشاط التجاري")]
        [MaxLength(150, ErrorMessage = "اسم المتجر لا يتجاوز 150 حرف")]
        public string StoreName { get; set; } = string.Empty;

        [Display(Name = "رقم الهاتف / التواصل")]
        [MaxLength(20)]
        public string? Phone { get; set; }

        [Display(Name = "العنوان في صنعاء")]
        [MaxLength(250)]
        public string? Address { get; set; }

        [Display(Name = "خط العرض (Latitude)")]
        public double? Latitude { get; set; }

        [Display(Name = "خط الطول (Longitude)")]
        public double? Longitude { get; set; }

        [Display(Name = "حالة الاعتماد (Approved)")]
        public bool IsApproved { get; set; } = true;

        [Required(ErrorMessage = "يرجى تحديد حساب التاجر المالك")]
        [Display(Name = "الحساب المالك (User)")]
        public int UserId { get; set; }

        public SelectList? UserList { get; set; }
    }
}