using Microsoft.EntityFrameworkCore;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Infrastructure.Data;
using SanaaOffersApi.Infrastructure.Repositories;
using SanaaOffersApi.Infrastructure.Services;

var builder = WebApplication.CreateBuilder(args);

// MVC + Session
builder.Services.AddControllersWithViews();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromHours(8);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});
builder.Services.AddHttpContextAccessor();

// DbContext - SQLite DB
var rawConnection = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=../SanaaOffersApi.API/SanaaOffers.db";
var dbFileName = rawConnection.Replace("Data Source=", "").Trim();
var fullDbPath = Path.IsPathRooted(dbFileName)
    ? dbFileName
    : Path.GetFullPath(Path.Combine(builder.Environment.ContentRootPath, dbFileName));
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite($"Data Source={fullDbPath}"));

// Repository Pattern
builder.Services.AddScoped(typeof(IRepository<>), typeof(GenericRepository<>));

// Core Services
builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();
builder.Services.AddScoped<IImageStorageService>(sp =>
{
    var env = sp.GetRequiredService<IWebHostEnvironment>();
    var apiWwwRoot = Path.GetFullPath(Path.Combine(env.ContentRootPath, "..", "SanaaOffersApi.API", "wwwroot"));
    var basePath = Directory.Exists(apiWwwRoot) ? apiWwwRoot : (env.WebRootPath ?? Path.Combine(env.ContentRootPath, "wwwroot"));
    return new ImageStorageService(basePath);
});

var app = builder.Build();

// Seed Database with realistic initial data
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<ApplicationDbContext>();
        var hasher = services.GetRequiredService<IPasswordHasher>();
        await DbInitializer.SeedAsync(context, hasher);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while seeding the database.");
    }
}

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

var sharedApiWwwRoot = Path.GetFullPath(Path.Combine(app.Environment.ContentRootPath, "..", "SanaaOffersApi.API", "wwwroot"));
if (Directory.Exists(sharedApiWwwRoot))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(sharedApiWwwRoot),
        RequestPath = ""
    });
}

app.UseRouting();
app.UseSession();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();