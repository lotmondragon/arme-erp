using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OpenIddict.Abstractions;
using OpenIddict.Server.AspNetCore;
using Serilog;
using System.Security.Claims;
using static OpenIddict.Abstractions.OpenIddictConstants;
using static OpenIddict.Server.AspNetCore.OpenIddictServerAspNetCoreConstants;

var builder = WebApplication.CreateBuilder(args);

// Serilog
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateLogger();

builder.Host.UseSerilog();

// In-memory database for development (use PostgreSQL in production)
builder.Services.AddDbContext<AuthDbContext>(options =>
{
    options.UseInMemoryDatabase("auth");
    options.UseOpenIddict();
});

builder.Services.AddOpenIddict()
    .AddCore(options =>
    {
        options.UseEntityFrameworkCore().UseDbContext<AuthDbContext>();
    })
    .AddServer(options =>
    {
        // Set explicit issuer to match what the API expects
        options.SetIssuer(new Uri("http://auth:8080"));
        
        options.SetTokenEndpointUris("/connect/token")
               .SetIntrospectionEndpointUris("/connect/introspect");
        
        options.AllowPasswordFlow()
               .AllowClientCredentialsFlow()
               .AllowRefreshTokenFlow();
        
        options.RegisterScopes(Scopes.OpenId, Scopes.Profile, Scopes.Email, Scopes.OfflineAccess, "api");
        
        // Use signing certificate for JWT tokens
        options.AddDevelopmentSigningCertificate();
        
        // Add ephemeral encryption key for other tokens (refresh tokens, etc.)
        options.AddEphemeralEncryptionKey();
        
        // Disable access token encryption for local validation
        options.DisableAccessTokenEncryption();
        
        options.UseAspNetCore()
               .EnableTokenEndpointPassthrough()
               .DisableTransportSecurityRequirement(); // Allow HTTP in development
    });

builder.Services.AddAuthentication();
builder.Services.AddAuthorization();
builder.Services.AddControllers();

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Seed test client and scopes
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AuthDbContext>();
    await context.Database.EnsureCreatedAsync();
    
    var appManager = scope.ServiceProvider.GetRequiredService<IOpenIddictApplicationManager>();
    
    var scopeManager = scope.ServiceProvider.GetRequiredService<IOpenIddictScopeManager>();
    
    // Register API resource scope
    if (await scopeManager.FindByNameAsync("api") is null)
    {
        await scopeManager.CreateAsync(new OpenIddictScopeDescriptor
        {
            Name = "api",
            DisplayName = "ARME API Access",
            Resources = { "arme-api" }
        });
    }
    
    if (await appManager.FindByClientIdAsync("web-client") is null)
    {
        // Leer client secret desde configuración (variable de entorno)
        var clientSecret = app.Configuration["JWT:ClientSecret"] ?? "dev-secret-2024";
        
        await appManager.CreateAsync(new OpenIddictApplicationDescriptor
        {
            ClientId = "web-client",
            ClientSecret = clientSecret,
            DisplayName = "ARME-ERP Web Client",
            Permissions =
            {
                Permissions.Endpoints.Token,
                Permissions.Endpoints.Introspection,
                Permissions.GrantTypes.Password,
                Permissions.GrantTypes.ClientCredentials,
                Permissions.GrantTypes.RefreshToken,
                Permissions.Scopes.Profile,
                Permissions.Scopes.Email,
                Permissions.Prefixes.Scope + "api"
            }
        });
    }
}

app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapGet("/health", () => Results.Ok(new { status = "Auth Server Healthy" }));

app.Run();

public class AuthDbContext : DbContext
{
    public AuthDbContext(DbContextOptions<AuthDbContext> options) : base(options) { }
}
