using FluentValidation;
using SanaaOffersApi.Application.DTOs;

namespace SanaaOffersApi.Application.Validators
{
    public class MerchantCreateDtoValidator : AbstractValidator<MerchantCreateDto>
    {
        public MerchantCreateDtoValidator()
        {
            RuleFor(m => m.StoreName)
                .NotEmpty().WithMessage("اسم المتجر مطلوب")
                .MaximumLength(150).WithMessage("اسم المتجر يجب ألا يتجاوز 150 حرف");

            RuleFor(m => m.Phone)
                .Matches(@"^\+?[0-9]{7,15}$").When(m => !string.IsNullOrEmpty(m.Phone))
                .WithMessage("رقم الجوال غير صحيح");

            RuleFor(m => m.Address)
                .MaximumLength(250).WithMessage("العنوان طويل جداً");

            RuleFor(m => m.Latitude)
                .InclusiveBetween(-90, 90).When(m => m.Latitude.HasValue)
                .WithMessage("خط العرض غير صحيح");

            RuleFor(m => m.Longitude)
                .InclusiveBetween(-180, 180).When(m => m.Longitude.HasValue)
                .WithMessage("خط الطول غير صحيح");

            RuleFor(m => m.UserId)
                .GreaterThan(0).WithMessage("يجب تحديد حساب المستخدم (التاجر) المالك للمتجر");
        }
    }
}
