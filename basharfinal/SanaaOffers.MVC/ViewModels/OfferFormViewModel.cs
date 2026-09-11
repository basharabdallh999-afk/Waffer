using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace SanaaOffers.MVC.ViewModels
{
    public class OfferFormViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "عنوان العرض مطلوب")]
        [Display(Name = "عنوان العرض")]
        [MaxLength(150, ErrorMessage = "عنوان العرض لا يتجاوز 150 حرف")]
        public string Title { get; set; } = string.Empty;

        [Display(Name = "تفاصيل ووصف العرض")]
        [MaxLength(1000, ErrorMessage = "الوصف لا يتجاوز 1000 حرف")]
        public string? Description { get; set; }

        [Required(ErrorMessage = "السعر الأصلي مطلوب")]
        [Range(0.01, 100000000, ErrorMessage = "يرجى إدخال سعر أصلي صحيح")]
        [Display(Name = "السعر الأصلي (ر.ي)")]
        public decimal OriginalPrice { get; set; }

        [Required(ErrorMessage = "سعر التخفيض مطلوب")]
        [Range(0.01, 100000000, ErrorMessage = "يرجى إدخال سعر تخفيض صحيح")]
        [Display(Name = "سعر العرض بعد الخصم (ر.ي)")]
        public decimal DiscountedPrice { get; set; }

        [Required(ErrorMessage = "تاريخ بداية العرض مطلوب")]
        [Display(Name = "تاريخ البداية")]
        [DataType(DataType.Date)]
        public DateTime StartDate { get; set; } = DateTime.Today;

        [Required(ErrorMessage = "تاريخ نهاية العرض مطلوب")]
        [Display(Name = "تاريخ النهاية")]
        [DataType(DataType.Date)]
        public DateTime EndDate { get; set; } = DateTime.Today.AddDays(30);

        [Display(Name = "عرض خاطف (Flash Sale)")]
        public bool IsFlashSale { get; set; } = false;

        [Display(Name = "إعلان بنر مميز مدفوع (Sponsored Banner)")]
        public bool IsSponsored { get; set; } = false;

        [Display(Name = "أولوية الترتيب في شريط البنرات (Display Priority)")]
        public int DisplayPriority { get; set; } = 0;

        [Display(Name = "عرض نشط")]
        public bool IsActive { get; set; } = true;

        [Required(ErrorMessage = "يرجى اختيار المتجر الناشر")]
        [Display(Name = "المتجر الناشر")]
        public int MerchantId { get; set; }

        [Required(ErrorMessage = "يرجى اختيار تصنيف العرض")]
        [Display(Name = "تصنيف العرض")]
        public int CategoryId { get; set; }

        [Display(Name = "مسار الصورة الحالية")]
        public string? ExistingImageUrl { get; set; }

        [Display(Name = "صورة العرض")]
        public IFormFile? Image { get; set; }

        public SelectList? MerchantList { get; set; }
        public SelectList? CategoryList { get; set; }
    }
}