using System.ComponentModel.DataAnnotations;

namespace SanaaOffersApi.Domain.Entities
{
    public class Category
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(300)]
        public string? Description { get; set; }

        [MaxLength(100)]
        public string? Icon { get; set; } = "bi-tag";

        // Navigation: a category groups many offers
        public ICollection<Offer> Offers { get; set; } = new List<Offer>();
    }
}