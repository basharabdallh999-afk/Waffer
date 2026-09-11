using FluentValidation;
using Microsoft.EntityFrameworkCore;
using SanaaOffersApi.Application.Interfaces;
using SanaaOffersApi.Application.Validators;
using SanaaOffersApi.Infrastructure.Data;
using SanaaOffersApi.Infrastructure.Repositories;
using SanaaOffersApi.Infrastructure.Services;

var builder = WebApplication.CreateBuilder(args);

// Bind to 0.0.0.0:5232 so mobile devices on the network can connect
builder.WebHost.UseUrls("http://0.0.0.0:5232");

// Add services to the container.
builder.Services.AddControllers();

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    });

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

// Database
var rawConnection = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=SanaaOffers.db";
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
    var basePath = env.WebRootPath ?? Path.Combine(env.ContentRootPath, "wwwroot");
    return new ImageStorageService(basePath);
});

// FluentValidation
builder.Services.AddValidatorsFromAssemblyContaining<OfferCreateDtoValidator>();

var app = builder.Build();

app.UseCors("AllowAll");

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseAuthorization();

app.MapControllers();

app.Run();