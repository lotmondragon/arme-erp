using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using OpenIddict.Abstractions;
using OpenIddict.Server.AspNetCore;
using System.Security.Claims;
using static OpenIddict.Abstractions.OpenIddictConstants;

namespace ArmeErp.AuthServer.Controllers;

[ApiController]
public class AuthorizationController : ControllerBase
{
    private readonly IOpenIddictApplicationManager _applicationManager;

    public AuthorizationController(IOpenIddictApplicationManager applicationManager)
    {
        _applicationManager = applicationManager;
    }

    [HttpPost("~/connect/token")]
    [Produces("application/json")]
    public async Task<IActionResult> Exchange()
    {
        var request = HttpContext.GetOpenIddictServerRequest() 
            ?? throw new InvalidOperationException("The OpenID Connect request cannot be retrieved.");

        if (request.IsPasswordGrantType())
        {
            // Validate credentials (hardcoded for dev - use real user store in production)
            if (request.Username != "admin@arme.com" || request.Password != "Admin123!")
            {
                return Forbid(
                    authenticationSchemes: OpenIddictServerAspNetCoreDefaults.AuthenticationScheme,
                    properties: new AuthenticationProperties(new Dictionary<string, string?>
                    {
                        [OpenIddictServerAspNetCoreConstants.Properties.Error] = Errors.InvalidGrant,
                        [OpenIddictServerAspNetCoreConstants.Properties.ErrorDescription] = "Invalid credentials"
                    }));
            }

            var identity = new ClaimsIdentity(
                authenticationType: OpenIddictServerAspNetCoreDefaults.AuthenticationScheme,
                nameType: Claims.Name,
                roleType: Claims.Role);

            identity.AddClaim(Claims.Subject, "admin-user-id");
            identity.AddClaim(Claims.Name, request.Username);
            identity.AddClaim(Claims.Email, request.Username);
            identity.AddClaim(Claims.Role, "Administrator");
            
            identity.SetScopes(request.GetScopes());
            identity.SetAudiences("arme-api");
            identity.SetDestinations(GetDestinations);

            return SignIn(new ClaimsPrincipal(identity), OpenIddictServerAspNetCoreDefaults.AuthenticationScheme);
        }

        if (request.IsClientCredentialsGrantType())
        {
            var application = await _applicationManager.FindByClientIdAsync(request.ClientId ?? string.Empty);
            
            if (application == null)
            {
                return Forbid(
                    authenticationSchemes: OpenIddictServerAspNetCoreDefaults.AuthenticationScheme,
                    properties: new AuthenticationProperties(new Dictionary<string, string?>
                    {
                        [OpenIddictServerAspNetCoreConstants.Properties.Error] = Errors.InvalidClient
                    }));
            }

            var identity = new ClaimsIdentity(
                authenticationType: OpenIddictServerAspNetCoreDefaults.AuthenticationScheme,
                nameType: Claims.Name,
                roleType: Claims.Role);

            identity.AddClaim(Claims.Subject, await _applicationManager.GetClientIdAsync(application) ?? string.Empty);
            identity.AddClaim(Claims.Name, await _applicationManager.GetDisplayNameAsync(application) ?? string.Empty);
            
            identity.SetScopes(request.GetScopes());
            identity.SetAudiences("arme-api");
            identity.SetDestinations(GetDestinations);

            return SignIn(new ClaimsPrincipal(identity), OpenIddictServerAspNetCoreDefaults.AuthenticationScheme);
        }

        return Forbid(
            authenticationSchemes: OpenIddictServerAspNetCoreDefaults.AuthenticationScheme,
            properties: new AuthenticationProperties(new Dictionary<string, string?>
            {
                [OpenIddictServerAspNetCoreConstants.Properties.Error] = Errors.UnsupportedGrantType
            }));
    }

    private static IEnumerable<string> GetDestinations(Claim claim)
    {
        return claim.Type switch
        {
            Claims.Name or Claims.Subject or Claims.Email or Claims.Role 
                => new[] { Destinations.AccessToken, Destinations.IdentityToken },
            _ => new[] { Destinations.AccessToken }
        };
    }
}
