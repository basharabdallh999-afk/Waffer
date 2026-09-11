using System.ComponentModel.DataAnnotations;

namespace SanaaOffers.MVC.ViewModels
{
    public class CategoryFormViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "اسم التصنيف مطلوب")]
        [Display(Name = "اسم التصنيف")]
        [MaxLength(100, ErrorMessage = "يجب ألا يتجاوز اسم التصنيف 100 حرف")]
        public string Name { get; set; } = string.Empty;

        [Display(Name = "الوصف")]
        [MaxLength(500, ErrorMessage = "يجب ألا يتجاوز الوصف 500 حرف")]
        public string? Description { get; set; }

        [Display(Name = "أيقونة التصنيف (Bootstrap Icon Class)")]
        [MaxLength(100)]
        public string? Icon { get; set; } = "bi-tag";
    }
}