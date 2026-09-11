using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SanaaOffersApi.Domain.Entities
{
    public class Merchant
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(150)]
        public string StoreName { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? Phone { get; set; }

        [MaxLength(250)]
        public string? Address { get; set; }

        // Used for geo-based notifications (nearby offers)
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }

        public bool IsApproved { get; set; } = false;

        public bool IsSuspended { get; set; } = false;

        [MaxLength(500)]
        public string? SuspensionReason { get; set; }

        public DateTime? SuspendedUntil { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [NotMapped]
        public bool IsCurrentlySuspended =>
            IsSuspended && (!SuspendedUntil.HasValue || SuspendedUntil.Value > DateTime.UtcNow);

        [NotMapped]
        public bool CanPublishOffers => IsApproved && !IsCurrentlySuspended;

        // FK: the User account (role = Merchant) that owns this store
        [Required]
        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public User? User { get; set; }

        // Navigation: a merchant can publish many offers
        public ICollection<Offer> Offers { get; set; } = new List<Offer>();
    }
}
