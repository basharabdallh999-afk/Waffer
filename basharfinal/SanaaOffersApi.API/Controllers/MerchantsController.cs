using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using SanaaOffersApi.Application.DTOs;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffersApi.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MerchantsController : ControllerBase
    {
        private readonly IRepository<Merchant> _repository;
        private readonly IRepository<User> _userRepository;
        private readonly IValidator<MerchantCreateDto> _validator;
        private readonly IImageStorageService _imageStorage;
        private readonly IPasswordHasher _passwordHasher;

        public MerchantsController(
            IRepository<Merchant> repository,
            IRepository<User> userRepository,
            IValidator<MerchantCreateDto> validator,
            IImageStorageService imageStorage,
            IPasswordHasher passwordHasher)
        {
            _repository = repository;
            _userRepository = userRepository;
            _validator = validator;
            _imageStorage = imageStorage;
            _passwordHasher = passwordHasher;
        }

        // GET: api/merchants
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var merchants = await _repository.GetAllAsync(m => m.User!, m => m.Offers);
            return Ok(merchants);
        }

        // GET: api/merchants/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var merchant = await _repository.GetByIdAsync(id, m => m.User!, m => m.Offers);
            if (merchant == null) return NotFound(new { message = "التاجر غير موجود" });
            return Ok(merchant);
        }

        // GET: api/merchants/user/{userId} or api/merchants/status/{userId} -> Status check for Flutter app
        [HttpGet("user/{userId}")]
        [HttpGet("status/{userId}")]
        public async Task<IActionResult> GetByUserId(int userId)
        {
            var merchants = await _repository.GetAllAsync(m => m.User!, m => m.Offers);
            var merchant = merchants.FirstOrDefault(m => m.UserId == userId);
            if (merchant == null) return NotFound(new { message = "لا يوجد حساب تاجر مرتبط بهذا المستخدم" });
            return Ok(merchant);
        }

        // POST: api/merchants/register-with-id (multipart/form-data)
        [HttpPost("register-with-id")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> RegisterWithId([FromForm] MerchantRegisterWithIdDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Username) || string.IsNullOrWhiteSpace(dto.Password))
            {
                return BadRequest(new { message = "اسم المستخدم وكلمة المرور مطلوبان" });
            }

            if (string.IsNullOrWhiteSpace(dto.StoreName))
            {
                return BadRequest(new { message = "اسم المتجر مطلوب" });
            }

            // Check duplicate user
            var existingUsers = await _userRepository.GetAllAsync();
            if (existingUsers.Any(u => u.Email.Equals(dto.Username, StringComparison.OrdinalIgnoreCase) || u.FullName.Equals(dto.Username, StringComparison.OrdinalIgnoreCase)))
            {
                return BadRequest(new { message = "اسم المستخدم أو البريد مجل بالفعل" });
            }

            // Create User account with role = Merchant
            var user = new User
            {
                FullName = dto.Username,
                Email = dto.Username.Contains("@") ? dto.Username : $"{dto.Username}@waffer.com",
                Phone = dto.Phone,
                PasswordHash = _passwordHasher.Hash(dto.Password),
                Role = UserRole.Merchant,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            var createdUser = await _userRepository.AddAsync(user);

            // Create Merchant store record with Pending status
            var merchant = new Merchant
            {
                StoreName = dto.StoreName,
                Phone = dto.Phone,
                Address = dto.Address,
                UserId = createdUser.Id,
                IsApproved = false,
                CreatedAt = DateTime.UtcNow
            };

            var createdMerchant = await _repository.AddAsync(merchant);
            return Ok(createdMerchant);
        }

        // POST: api/merchants
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] MerchantCreateDto dto)
        {
            var validationResult = await _validator.ValidateAsync(dto);
            if (!validationResult.IsValid)
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));

            var merchant = new Merchant
            {
                StoreName = dto.StoreName,
                Phone = dto.Phone,
                Address = dto.Address,
                Latitude = dto.Latitude,
                Longitude = dto.Longitude,
                UserId = dto.UserId
            };

            var created = await _repository.AddAsync(merchant);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        // PUT: api/merchants/5/approve  -> used by the admin dashboard
        [HttpPut("{id}/approve")]
        public async Task<IActionResult> Approve(int id)
        {
            var merchant = await _repository.GetByIdAsync(id);
            if (merchant == null) return NotFound();

            merchant.IsApproved = true;
            merchant.IsSuspended = false;
            merchant.SuspensionReason = null;
            merchant.SuspendedUntil = null;
            await _repository.UpdateAsync(merchant);
            return Ok(merchant);
        }

        // PUT: api/merchants/5/reject
        [HttpPut("{id}/reject")]
        public async Task<IActionResult> Reject(int id)
        {
            var merchant = await _repository.GetByIdAsync(id);
            if (merchant == null) return NotFound();

            merchant.IsApproved = false;
            merchant.IsSuspended = true;
            merchant.SuspensionReason = "تم رفض طلب التوثيق من قبل إدارة المنصة";
            await _repository.UpdateAsync(merchant);
            return Ok(merchant);
        }

        // PUT: api/merchants/5/suspend
        [HttpPut("{id}/suspend")]
        public async Task<IActionResult> Suspend(int id, [FromBody] SuspendMerchantDto dto)
        {
            var merchant = await _repository.GetByIdAsync(id);
            if (merchant == null) return NotFound();

            merchant.IsSuspended = true;
            merchant.SuspensionReason = string.IsNullOrWhiteSpace(dto.Reason) ? "مخالفة شروط الاستخدام" : dto.Reason;
            if (dto.IsPermanent || !dto.DurationDays.HasValue || dto.DurationDays.Value <= 0)
            {
                merchant.SuspendedUntil = null; // إيقاف نهائي
            }
            else
            {
                merchant.SuspendedUntil = DateTime.UtcNow.AddDays(dto.DurationDays.Value);
            }

            await _repository.UpdateAsync(merchant);
            return Ok(merchant);
        }

        // PUT: api/merchants/5/unsuspend
        [HttpPut("{id}/unsuspend")]
        public async Task<IActionResult> Unsuspend(int id)
        {
            var merchant = await _repository.GetByIdAsync(id);
            if (merchant == null) return NotFound();

            merchant.IsSuspended = false;
            merchant.SuspensionReason = null;
            merchant.SuspendedUntil = null;
            await _repository.UpdateAsync(merchant);
            return Ok(merchant);
        }

        // DELETE: api/merchants/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var deleted = await _repository.DeleteAsync(id);
            if (!deleted) return NotFound();
            return NoContent();
        }
    }
}
