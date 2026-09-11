using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace SanaaOffersApi.Infrastructure.Data
{
    public static class DbInitializer
    {
        public static async Task SeedAsync(ApplicationDbContext context, IPasswordHasher hasher)
        {
            await context.Database.EnsureCreatedAsync();

            // Safe schema migrations for SQLite (adds new columns if missing)
            try { await context.Database.ExecuteSqlRawAsync("ALTER TABLE Merchants ADD COLUMN IsSuspended INTEGER NOT NULL DEFAULT 0;"); } catch { }
            try { await context.Database.ExecuteSqlRawAsync("ALTER TABLE Merchants ADD COLUMN SuspensionReason TEXT NULL;"); } catch { }
            try { await context.Database.ExecuteSqlRawAsync("ALTER TABLE Merchants ADD COLUMN SuspendedUntil TEXT NULL;"); } catch { }
            try { await context.Database.ExecuteSqlRawAsync("ALTER TABLE Offers ADD COLUMN IsSponsored INTEGER NOT NULL DEFAULT 0;"); } catch { }
            try { await context.Database.ExecuteSqlRawAsync("ALTER TABLE Offers ADD COLUMN DisplayPriority INTEGER NOT NULL DEFAULT 0;"); } catch { }
            try { await context.Database.ExecuteSqlRawAsync("ALTER TABLE Offers ADD COLUMN IsActive INTEGER NOT NULL DEFAULT 1;"); } catch { }

            // Seed Users if not exists
            if (!await context.Users.AnyAsync())
            {
                var admin = new User
                {
                    FullName = "مدير النظام",
                    Email = "admin@waffer.ye",
                    Phone = "777000111",
                    Role = UserRole.Admin,
                    PasswordHash = hasher.Hash("Admin123!"),
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                };

                var mUser1 = new User
                {
                    FullName = "عبدالله باوزير",
                    Email = "alhadaf@waffer.ye",
                    Phone = "771234567",
                    Role = UserRole.Merchant,
                    PasswordHash = hasher.Hash("Merchant123!"),
                    CreatedAt = DateTime.UtcNow.AddMonths(-5)
                };

                var mUser2 = new User
                {
                    FullName = "محمد النصر",
                    Email = "alnasser@waffer.ye",
                    Phone = "772345678",
                    Role = UserRole.Merchant,
                    PasswordHash = hasher.Hash("Merchant123!"),
                    CreatedAt = DateTime.UtcNow.AddMonths(-4)
                };

                var mUser3 = new User
                {
                    FullName = "جمال الشيباني",
                    Email = "alshatea@waffer.ye",
                    Phone = "773456789",
                    Role = UserRole.Merchant,
                    PasswordHash = hasher.Hash("Merchant123!"),
                    CreatedAt = DateTime.UtcNow.AddMonths(-3)
                };

                var mUser4 = new User
                {
                    FullName = "سارة الصنعاني",
                    Email = "elegance@waffer.ye",
                    Phone = "774567890",
                    Role = UserRole.Merchant,
                    PasswordHash = hasher.Hash("Merchant123!"),
                    CreatedAt = DateTime.UtcNow.AddMonths(-2)
                };

                var customer1 = new User
                {
                    FullName = "أحمد علي الريمي",
                    Email = "ahmed.remi@gmail.com",
                    Phone = "775678901",
                    Role = UserRole.Consumer,
                    PasswordHash = hasher.Hash("User123!"),
                    CreatedAt = DateTime.UtcNow.AddMonths(-4)
                };

                var customer2 = new User
                {
                    FullName = "فاطمة محمد الحاشدي",
                    Email = "fatima.h@gmail.com",
                    Phone = "776789012",
                    Role = UserRole.Consumer,
                    PasswordHash = hasher.Hash("User123!"),
                    CreatedAt = DateTime.UtcNow.AddMonths(-2)
                };

                var customer3 = new User
                {
                    FullName = "خالد وليد الشامي",
                    Email = "khaled.shami@gmail.com",
                    Phone = "777890123",
                    Role = UserRole.Consumer,
                    PasswordHash = hasher.Hash("User123!"),
                    CreatedAt = DateTime.UtcNow.AddMonths(-1)
                };

                context.Users.AddRange(admin, mUser1, mUser2, mUser3, mUser4, customer1, customer2, customer3);
                await context.SaveChangesAsync();

                // Seed Categories
                var catFood = new Category { Name = "سوبرماركت ومواد غذائية", Description = "عروض المنتجات والمستلزمات التموينية المنزلية" };
                var catTech = new Category { Name = "إلكترونيات وهواتف", Description = "أحدث الهواتف الذكية والأجهزة الكهربائية والإلكترونية" };
                var catRest = new Category { Name = "مطاعم وكافيهات", Description = "أشهى الوجبات والمشروبات وأفضل تخفيضات المطاعم" };
                var catFashion = new Category { Name = "أزياء وملابس", Description = "أحدث تشكيلات الملابس والأحذية النسائية والرجالية والولادية" };
                var catHealth = new Category { Name = "صحة وجمال", Description = "مستحضرات التجميل، العطور، والعناية الشخصية" };
                var catCars = new Category { Name = "سيارات وخدمات", Description = "خدمات الصيانة وتخفيضات قطع غيار وزيوت السيارات" };

                context.Categories.AddRange(catFood, catTech, catRest, catFashion, catHealth, catCars);
                await context.SaveChangesAsync();

                // Seed Merchants
                var merchantHadaf = new Merchant
                {
                    StoreName = "سوبر ماركت الهدف",
                    Phone = "01-445566",
                    Address = "صنعاء - شارع حدة - بجوار سيتي ماكس",
                    Latitude = 15.3324,
                    Longitude = 44.1856,
                    IsApproved = true,
                    UserId = mUser1.Id,
                    CreatedAt = DateTime.UtcNow.AddMonths(-5)
                };

                var merchantNasser = new Merchant
                {
                    StoreName = "مؤسسة النصر للإلكترونيات",
                    Phone = "01-223344",
                    Address = "صنعاء - شارع الستين الغربي - مقابل الجامعة",
                    Latitude = 15.3512,
                    Longitude = 44.1724,
                    IsApproved = true,
                    UserId = mUser2.Id,
                    CreatedAt = DateTime.UtcNow.AddMonths(-4)
                };

                var merchantShatei = new Merchant
                {
                    StoreName = "مطاعم الشيباني الملكي",
                    Phone = "01-556677",
                    Address = "صنعاء - شارع الستين الجنوبي - جوار تقاطع عصر",
                    Latitude = 15.3210,
                    Longitude = 44.1950,
                    IsApproved = true,
                    UserId = mUser3.Id,
                    CreatedAt = DateTime.UtcNow.AddMonths(-3)
                };

                var merchantElegance = new Merchant
                {
                    StoreName = "بوتيك الأناقة للملابس",
                    Phone = "01-334455",
                    Address = "صنعاء - شارع بغداد - مركز الفخامة",
                    Latitude = 15.3400,
                    Longitude = 44.2010,
                    IsApproved = true,
                    UserId = mUser4.Id,
                    CreatedAt = DateTime.UtcNow.AddMonths(-2)
                };

                context.Merchants.AddRange(merchantHadaf, merchantNasser, merchantShatei, merchantElegance);
                await context.SaveChangesAsync();

                // Seed Offers
                var offers = new List<Offer>
                {
                    new Offer
                    {
                        Title = "عرض خاص: تخفيض 35% على الشاشات الذكية 4K",
                        Description = "احصل على شاشة سامسونج سمارت 55 بوصة بدقة فور كي مع ضمان عامين كاملين وبسعر لا يفوت ضمن عروض التوفير الكبرى.",
                        OriginalPrice = 280000,
                        DiscountedPrice = 182000,
                        StartDate = DateTime.UtcNow.AddDays(-5),
                        EndDate = DateTime.UtcNow.AddDays(25),
                        IsFlashSale = true,
                        ViewsCount = 430,
                        CreatedAt = DateTime.UtcNow.AddDays(-5),
                        MerchantId = merchantNasser.Id,
                        CategoryId = catTech.Id
                    },
                    new Offer
                    {
                        Title = "سلة التوفير الغذائية الأسبوعية العائلية",
                        Description = "تحتوي على أرز، زيت، سكر، حليب، مكرونة ومستلزمات المطبخ الأساسية بخصم حقيقي ومباشر 25%.",
                        OriginalPrice = 45000,
                        DiscountedPrice = 33750,
                        StartDate = DateTime.UtcNow.AddDays(-2),
                        EndDate = DateTime.UtcNow.AddDays(12),
                        IsFlashSale = false,
                        ViewsCount = 280,
                        CreatedAt = DateTime.UtcNow.AddDays(-2),
                        MerchantId = merchantHadaf.Id,
                        CategoryId = catFood.Id
                    },
                    new Offer
                    {
                        Title = "وجبة العائلة الملكية + مقبلات ومشروبات مجاناً",
                        Description = "وجبة مشويات مشكلة فاخرة تكفي 5 أشخاص مع تشكيلة مقبلات ساخنة وباردة وعصائر طبيعية طازجة.",
                        OriginalPrice = 32000,
                        DiscountedPrice = 22400,
                        StartDate = DateTime.UtcNow.AddDays(-3),
                        EndDate = DateTime.UtcNow.AddDays(15),
                        IsFlashSale = true,
                        ViewsCount = 590,
                        CreatedAt = DateTime.UtcNow.AddDays(-3),
                        MerchantId = merchantShatei.Id,
                        CategoryId = catRest.Id
                    },
                    new Offer
                    {
                        Title = "تخفيضات موسمية تصل إلى 50% على الملابس الشتوية والجاكيتات",
                        Description = "تشكيلة جديدة وحصرية من أرقى الماركات التركية والماركات العالمية لجميع الأعمار بتخفيض مذهل نصف السعر.",
                        OriginalPrice = 30000,
                        DiscountedPrice = 15000,
                        StartDate = DateTime.UtcNow.AddDays(-7),
                        EndDate = DateTime.UtcNow.AddDays(20),
                        IsFlashSale = false,
                        ViewsCount = 345,
                        CreatedAt = DateTime.UtcNow.AddDays(-7),
                        MerchantId = merchantElegance.Id,
                        CategoryId = catFashion.Id
                    },
                    new Offer
                    {
                        Title = "سماعات بلوتوث لاسلكية عازلة للضوضاء + بنك طاقة هدية",
                        Description = "صوت نقي وبطارية تدوم حتى 48 ساعة متواصلة تدعم الشحن السريع مع باور بانك مجاني 10000mAh.",
                        OriginalPrice = 22000,
                        DiscountedPrice = 14500,
                        StartDate = DateTime.UtcNow.AddDays(-1),
                        EndDate = DateTime.UtcNow.AddDays(10),
                        IsFlashSale = true,
                        ViewsCount = 195,
                        CreatedAt = DateTime.UtcNow.AddDays(-1),
                        MerchantId = merchantNasser.Id,
                        CategoryId = catTech.Id
                    }
                };

                context.Offers.AddRange(offers);
                await context.SaveChangesAsync();
            }
        }
    }
}