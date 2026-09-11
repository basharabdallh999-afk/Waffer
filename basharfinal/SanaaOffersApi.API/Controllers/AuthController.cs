using Microsoft.AspNetCore.Mvc;
using SanaaOffersApi.Application.DTOs;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffersApi.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IRepository<User> _userRepo;
        private readonly IRepository<Merchant> _merchantRepo;
        private readonly IPasswordHasher _passwordHasher;

        public AuthController(
            IRepository<User> userRepo,
            IRepository<Merchant> merchantRepo,
            IPasswordHasher passwordHasher)
        {
            _userRepo = userRepo;
            _merchantRepo = merchantRepo;
            _passwordHasher = passwordHasher;
        }

        // POST: api/auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Email) || string.IsNullOrWhiteSpace(dto.Password))
            {
                return BadRequest(new { message = "يرجى إدخال البريد الإلكتروني وكلمة المرور" });
            }

            var cleanEmail = dto.Email.Trim();
            var users = await _userRepo.GetAllAsync(u => u.Merchants);
            var user = users.FirstOrDefault(u => u.Email.Equals(cleanEmail, StringComparison.OrdinalIgnoreCase));

            // Support demo accounts gracefully if database user is found or created
            if (user == null)
            {
                // If demo credentials, create the user on-the-fly
                if (cleanEmail.Contains("merchant") || cleanEmail.Contains("admin") || cleanEmail.Contains("user"))
                {
                    bool isMerch = cleanEmail.Contains("merchant");
                    user = new User
                    {
                        FullName = isMerch ? "متجر صنعاء الذهبي" : "علي المحمدي",
                        Email = cleanEmail,
                        Role = isMerch ? UserRole.Merchant : (cleanEmail.Contains("admin") ? UserRole.Admin : UserRole.Consumer),
                        PasswordHash = _passwordHasher.Hash(dto.Password)
                    };
                    await _userRepo.AddAsync(user);

                    if (isMerch)
                    {
                        var merch = new Merchant
                        {
                            StoreName = "متجر صنعاء الذهبي",
                            UserId = user.Id,
                            IsApproved = true,
                            Phone = "779888892",
                            Address = "صنعاء - شارع حدة"
                        };
                        await _merchantRepo.AddAsync(merch);
                    }
                    // reload
                    users = await _userRepo.GetAllAsync(u => u.Merchants);
                    user = users.FirstOrDefault(u => u.Id == user.Id);
                }
            }

            if (user == null || !_passwordHasher.Verify(dto.Password, user.PasswordHash))
            {
                return Unauthorized(new { message = "البريد الإلكتروني أو كلمة المرور غير صحيحة" });
            }

            var merchant = user.Merchants.FirstOrDefault();
            var isMerchantUser = user.Role == UserRole.Merchant || merchant != null;

            var response = new LoginResponseDto
            {
                Token = Guid.NewGuid().ToString("N"),
                User = new UserResponseDto
                {
                    Id = user.Id,
                    Name = user.FullName,
                    Email = user.Email,
                    Role = user.Role.ToString(),
                    IsMerchant = isMerchantUser,
                    StoreName = merchant?.StoreName ?? (isMerchantUser ? user.FullName : null),
                    MerchantId = merchant?.Id,
                    IsApproved = merchant?.IsApproved ?? true,
                    IsSuspended = merchant?.IsCurrentlySuspended ?? false,
                    SuspensionReason = merchant?.SuspensionReason,
                    SuspendedUntil = merchant?.SuspendedUntil
                }
            };

            return Ok(response);
        }

        // POST: api/auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] UserCreateDto dto)
        {
            var users = await _userRepo.GetAllAsync();
            if (users.Any(u => u.Email.Equals(dto.Email.Trim(), StringComparison.OrdinalIgnoreCase)))
            {
                return BadRequest(new { message = "البريد الإلكتروني مسجل مسبقاً" });
            }

            var user = new User
            {
                FullName = dto.FullName.Trim(),
                Email = dto.Email.Trim(),
                Phone = dto.Phone,
                Role = dto.Role,
                PasswordHash = _passwordHasher.Hash(dto.Password)
            };

            var created = await _userRepo.AddAsync(user);
            Merchant? createdMerchant = null;

            if (dto.Role == UserRole.Merchant)
            {
                createdMerchant = new Merchant
                {
                    StoreName = dto.FullName.Trim(),
                    Phone = dto.Phone,
                    UserId = created.Id,
                    IsApproved = false,
                    CreatedAt = DateTime.UtcNow
                };
                await _merchantRepo.AddAsync(createdMerchant);
            }

            var response = new LoginResponseDto
            {
                Token = Guid.NewGuid().ToString("N"),
                User = new UserResponseDto
                {
                    Id = created.Id,
                    Name = created.FullName,
                    Email = created.Email,
                    Role = created.Role.ToString(),
                    IsMerchant = created.Role == UserRole.Merchant,
                    StoreName = createdMerchant?.StoreName,
                    MerchantId = createdMerchant?.Id,
                    IsApproved = createdMerchant?.IsApproved ?? true,
                    IsSuspended = false
                }
            };

            return Ok(response);
        }
    }
}
