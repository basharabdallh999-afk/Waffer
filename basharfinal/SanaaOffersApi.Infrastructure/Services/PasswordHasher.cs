using System.Security.Cryptography;
using System.Text;
using SanaaOffersApi.Application.Interfaces;

namespace SanaaOffersApi.Infrastructure.Services
{
    public class PasswordHasher : IPasswordHasher
    {
        public string Hash(string password)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
            return Convert.ToHexString(bytes);
        }

        public bool Verify(string password, string hash)
        {
            var inputHash = Hash(password);
            return string.Equals(inputHash, hash, StringComparison.OrdinalIgnoreCase);
        }
    }
}