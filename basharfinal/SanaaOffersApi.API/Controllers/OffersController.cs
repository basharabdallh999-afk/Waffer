using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using SanaaOffersApi.Application.DTOs;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffersApi.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OffersController : ControllerBase
    {
        private readonly IRepository<Offer> _repository;
        private readonly IRepository<Merchant> _merchantRepo;
        private readonly IValidator<OfferCreateDto> _validator;
        private readonly IImageStorageService _imageStorage;

        public OffersController(
            IRepository<Offer> repository,
            IRepository<Merchant> merchantRepo,
            IValidator<OfferCreateDto> validator,
            IImageStorageService imageStorage)
        {
            _repository = repository;
            _merchantRepo = merchantRepo;
            _validator = validator;
            _imageStorage = imageStorage;
        }

        // GET: api/offers
        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] bool? sponsored = null)
        {
            var offers = await _repository.GetAllAsync(o => o.Merchant!, o => o.Category!);
            if (sponsored.HasValue)
            {
                offers = offers.Where(o => o.IsSponsored == sponsored.Value);
            }
            return Ok(offers);
        }

        // GET: api/offers/sponsored -> active sponsored banner ads for mobile carousel
        [HttpGet("sponsored")]
        public async Task<IActionResult> GetSponsored()
        {
            var offers = await _repository.GetAllAsync(o => o.Merchant!, o => o.Category!);
            var sponsored = offers
                .Where(o => o.IsSponsored && o.IsActive && !o.IsExpired)
                .OrderByDescending(o => o.DisplayPriority)
                .ThenByDescending(o => o.CreatedAt);
            return Ok(sponsored);
        }

        // GET: api/offers/flash  -> offers marked as flash sales and not yet expired
        [HttpGet("flash")]
        public async Task<IActionResult> GetFlashSales()
        {
            var offers = await _repository.GetAllAsync(o => o.Merchant!, o => o.Category!);
            var flash = offers.Where(o => o.IsFlashSale && !o.IsExpired);
            return Ok(flash);
        }

        // GET: api/offers/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var offer = await _repository.GetByIdAsync(id, o => o.Merchant!, o => o.Category!);
            if (offer == null) return NotFound(new { message = "العرض غير موجود" });

            offer.ViewsCount++;
            await _repository.UpdateAsync(offer);

            return Ok(offer);
        }

        // POST: api/offers  (multipart/form-data, supports image upload)
        [HttpPost]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Create([FromForm] OfferCreateDto dto)
        {
            var validationResult = await _validator.ValidateAsync(dto);
            if (!validationResult.IsValid)
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));

            // Verify merchant publishing eligibility
            var merchant = await _merchantRepo.GetByIdAsync(dto.MerchantId);
            if (merchant != null && !merchant.CanPublishOffers)
            {
                if (!merchant.IsApproved)
                {
                    return StatusCode(403, new { message = "حساب متجرك لا يزال بانتظار المراجعة والتوثيق من قِبل إدارة منصة وفر قبل نشر العروض." });
                }
                if (merchant.IsCurrentlySuspended)
                {
                    var period = merchant.SuspendedUntil.HasValue 
                        ? $"حتى {merchant.SuspendedUntil.Value:yyyy/MM/dd HH:mm}" 
                        : "بشكل نهائي";
                    return StatusCode(403, new { message = $"تم إيقاف متجرك عن نشر العروض {period}. سبب الإيقاف: {merchant.SuspensionReason ?? "مخالفة الشروط والأحكام"}." });
                }
            }

            string? imageUrl = null;
            if (dto.Image != null)
                imageUrl = await _imageStorage.SaveImageAsync(dto.Image);

            var offer = new Offer
            {
                Title = dto.Title,
                Description = dto.Description,
                OriginalPrice = dto.OriginalPrice,
                DiscountedPrice = dto.DiscountedPrice,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                IsFlashSale = dto.IsFlashSale,
                IsSponsored = dto.IsSponsored,
                DisplayPriority = dto.DisplayPriority,
                IsActive = dto.IsActive,
                MerchantId = dto.MerchantId,
                CategoryId = dto.CategoryId,
                ImageUrl = imageUrl
            };

            var created = await _repository.AddAsync(offer);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        // PUT: api/offers/5  (multipart/form-data, image optional — kept if not replaced)
        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Update(int id, [FromForm] OfferCreateDto dto)
        {
            var existing = await _repository.GetByIdAsync(id);
            if (existing == null) return NotFound();

            var validationResult = await _validator.ValidateAsync(dto);
            if (!validationResult.IsValid)
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));

            existing.Title = dto.Title;
            existing.Description = dto.Description;
            existing.OriginalPrice = dto.OriginalPrice;
            existing.DiscountedPrice = dto.DiscountedPrice;
            existing.StartDate = dto.StartDate;
            existing.EndDate = dto.EndDate;
            existing.IsFlashSale = dto.IsFlashSale;
            existing.IsSponsored = dto.IsSponsored;
            existing.DisplayPriority = dto.DisplayPriority;
            existing.IsActive = dto.IsActive;
            existing.MerchantId = dto.MerchantId;
            existing.CategoryId = dto.CategoryId;

            if (dto.Image != null)
                existing.ImageUrl = await _imageStorage.SaveImageAsync(dto.Image);

            await _repository.UpdateAsync(existing);
            return NoContent();
        }

        // DELETE: api/offers/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var deleted = await _repository.DeleteAsync(id);
            if (!deleted) return NotFound();
            return NoContent();
        }
    }
}
