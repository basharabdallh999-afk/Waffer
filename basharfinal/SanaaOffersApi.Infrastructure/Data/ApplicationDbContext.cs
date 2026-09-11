using Microsoft.EntityFrameworkCore;
using SanaaOffersApi.Domain.Entities;

namespace SanaaOffersApi.Infrastructure.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }
        
        public DbSet<User> Users { get; set; }
        public DbSet<Merchant> Merchants { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Offer> Offers { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Unique email per user
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // User (1) -> (Many) Merchants
            modelBuilder.Entity<Merchant>()
                .HasOne(m => m.User)
                .WithMany(u => u.Merchants)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Merchant (1) -> (Many) Offers
            modelBuilder.Entity<Offer>()
                .HasOne(o => o.Merchant)
                .WithMany(m => m.Offers)
                .HasForeignKey(o => o.MerchantId)
                .OnDelete(DeleteBehavior.Cascade);

            // Category (1) -> (Many) Offers
            modelBuilder.Entity<Offer>()
                .HasOne(o => o.Category)
                .WithMany(c => c.Offers)
                .HasForeignKey(o => o.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
