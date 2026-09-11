using FluentValidation;
using SanaaOffersApi.Application.DTOs;

namespace SanaaOffersApi.Application.Validators
{
    public class CategoryCreateDtoValidator : AbstractValidator<CategoryCreateDto>
    {
        public CategoryCreateDtoValidator()
        {
            RuleFor(c => c.Name)
                .NotEmpty().WithMessage("اسم التصنيف مطلوب")
                .MaximumLength(100).WithMessage("اسم التصنيف يجب ألا يتجاوز 100 حرف");

            RuleFor(c => c.Description)
                .MaximumLength(300).WithMessage("الوصف طويل جداً");
        }
    }
}
