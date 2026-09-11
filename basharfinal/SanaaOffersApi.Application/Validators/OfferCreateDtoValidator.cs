using FluentValidation;
using SanaaOffersApi.Application.DTOs;

namespace SanaaOffersApi.Application.Validators
{
    public class OfferCreateDtoValidator : AbstractValidator<OfferCreateDto>
    {
        public OfferCreateDtoValidator()
        {
            RuleFor(o => o.Title)
                .NotEmpty().WithMessage("عنوان العرض مطلوب")
                .MaximumLength(150);

            RuleFor(o => o.OriginalPrice)
                .GreaterThan(0).WithMessage("يجب أن يكون السعر الأصلي رقماً موجباً");

            RuleFor(o => o.DiscountedPrice)
                .GreaterThan(0).WithMessage("يجب أن يكون سعر العرض رقماً موجباً")
                .LessThanOrEqualTo(o => o.OriginalPrice)
                .WithMessage("سعر العرض يجب أن يكون أقل من أو يساوي السعر الأصلي");

            RuleFor(o => o.EndDate)
                .GreaterThan(o => o.StartDate)
                .WithMessage("تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء");

            RuleFor(o => o.MerchantId)
                .GreaterThan(0).WithMessage("يجب تحديد التاجر صاحب العرض");

            RuleFor(o => o.CategoryId)
                .GreaterThan(0).WithMessage("يجب تحديد تصنيف العرض");

            RuleFor(o => o.Image)
                .Must(f => f == null || f.ContentType.StartsWith("image/"))
                .WithMessage("الملف المرفق يجب أن يكون صورة")
                .Must(f => f == null || f.Length <= 5 * 1024 * 1024)
                .WithMessage("حجم الصورة يجب ألا يتجاوز 5 ميجابايت");
        }
    }
}
