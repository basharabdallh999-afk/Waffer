using Microsoft.AspNetCore.Http;
using SanaaOffersApi.Application.Interfaces;

namespace SanaaOffersApi.Infrastructure.Services
{
    // Saves uploaded images to a folder on disk (wwwroot/images by default)
    // and returns the relative path that gets stored on the Offer entity.
    public class ImageStorageService : IImageStorageService
    {
        private readonly string _imagesFolder;

        // basePath is the web root (e.g. IWebHostEnvironment.WebRootPath),
        // injected from the API layer's Program.cs so Infrastructure never
        // depends on ASP.NET Core hosting types directly.
        public ImageStorageService(string basePath)
        {
            _imagesFolder = Path.Combine(basePath, "images");
        }

        public async Task<string> SaveImageAsync(IFormFile image)
        {
            Directory.CreateDirectory(_imagesFolder);

            var fileName = $"{Guid.NewGuid()}{Path.GetExtension(image.FileName)}";
            var filePath = Path.Combine(_imagesFolder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await image.CopyToAsync(stream);
            }

            return $"images/{fileName}";
        }
    }
}
