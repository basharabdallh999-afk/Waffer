using FluentValidation;
using SanaaOffersApi.Application.DTOs;

namespace SanaaOffersApi.Application.Validators
{
    public class UserCreateDtoValidator : AbstractValidator<UserCreateDto>
    {
        public UserCreateDtoValidator()
        {
            RuleFor(u => u.FullName)
                .NotEmpty().WithMessage("الاسم الكامل مطلوب")
                .MaximumLength(100).WithMessage("الاسم الكامل يجب ألا يتجاوز 100 حرف");

            RuleFor(u => u.Email)
                .NotEmpty().WithMessage("البريد الإلكتروني مطلوب")
                .EmailAddress().WithMessage("صيغة البريد الإلكتروني غير صحيحة")
                .MaximumLength(150);

            RuleFor(u => u.Password)
                .NotEmpty().WithMessage("كلمة المرور مطلوبة")
                .MinimumLength(6).WithMessage("كلمة المرور يجب ألا تقل عن 6 أحرف");

            RuleFor(u => u.Phone)
                .Matches(@"^\+?[0-9]{7,15}$").When(u => !string.IsNullOrEmpty(u.Phone))
                .WithMessage("رقم الجوال غير صحيح");

            RuleFor(u => u.Role)
                .IsInEnum().WithMessage("نوع الحساب غير صحيح");
        }
    }
}
