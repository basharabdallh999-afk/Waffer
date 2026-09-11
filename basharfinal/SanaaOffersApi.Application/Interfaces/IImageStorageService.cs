using Microsoft.AspNetCore.Http;

namespace SanaaOffersApi.Application.Interfaces
{
    // Abstraction over "where/how offer images are stored" so controllers
    // never touch the file system directly (kept in Infrastructure).
    public interface IImageStorageService
    {
        Task<string> SaveImageAsync(IFormFile image);
    }
}
