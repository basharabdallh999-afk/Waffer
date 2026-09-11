using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using SanaaOffersApi.Application.DTOs;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffersApi.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IRepository<User> _repository;
        private readonly IValidator<UserCreateDto> _validator;
        private readonly IPasswordHasher _passwordHasher;

        public UsersController(
            IRepository<User> repository,
            IValidator<UserCreateDto> validator,
            IPasswordHasher passwordHasher)
        {
            _repository = repository;
            _validator = validator;
            _passwordHasher = passwordHasher;
        }

        // GET: api/users
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var users = await _repository.GetAllAsync(u => u.Merchants);
            return Ok(users);
        }

        // GET: api/users/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var user = await _repository.GetByIdAsync(id, u => u.Merchants);
            if (user == null) return NotFound(new { message = "المستخدم غير موجود" });
            return Ok(user);
        }

        // POST: api/users
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] UserCreateDto dto)
        {
            var validationResult = await _validator.ValidateAsync(dto);
            if (!validationResult.IsValid)
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));

            var user = new User
            {
                FullName = dto.FullName,
                Email = dto.Email,
                Phone = dto.Phone,
                Role = dto.Role,
                PasswordHash = _passwordHasher.Hash(dto.Password)
            };

            var created = await _repository.AddAsync(user);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        // PUT: api/users/5
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UserCreateDto dto)
        {
            var existing = await _repository.GetByIdAsync(id);
            if (existing == null) return NotFound();

            var validationResult = await _validator.ValidateAsync(dto);
            if (!validationResult.IsValid)
                return BadRequest(validationResult.Errors.Select(e => e.ErrorMessage));

            existing.FullName = dto.FullName;
            existing.Email = dto.Email;
            existing.Phone = dto.Phone;
            existing.Role = dto.Role;
            existing.PasswordHash = _passwordHasher.Hash(dto.Password);

            await _repository.UpdateAsync(existing);
            return NoContent();
        }

        // DELETE: api/users/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var deleted = await _repository.DeleteAsync(id);
            if (!deleted) return NotFound();
            return NoContent();
        }
    }
}
