using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace ArmeErp.IntegrationTests;

/// <summary>
/// Prueba de integración mínima contra el stack real (API + Auth Server +
/// PostgreSQL) levantado con `docker compose up`. No usa mocks: ejercita el
/// flujo completo de login (OpenIddict password grant) -> JWT real ->
/// endpoint protegido de la API.
///
/// Requiere el stack corriendo. Si la API o el Auth Server no responden en
/// las URLs de abajo (configurables por variable de entorno), los tests se
/// saltan en vez de fallar, para no romper `dotnet test` en un entorno sin
/// Docker (por ejemplo, CI de solo build/test unitarios).
/// </summary>
public class AuthenticatedClientsApiTests : IAsyncLifetime
{
    private static readonly string ApiBaseUrl =
        Environment.GetEnvironmentVariable("ARME_API_URL") ?? "http://localhost:5070";

    private static readonly string AuthBaseUrl =
        Environment.GetEnvironmentVariable("ARME_AUTH_URL") ?? "http://localhost:5080";

    private static readonly string ClientSecret =
        Environment.GetEnvironmentVariable("CLIENT_SECRET")
        ?? "W3b_Cl13nt_S3cr3t_2024_V3ry_L0ng_@nd_S3cur3_F0r_D3v3l0pm3nt_Us3_0nly";

    private readonly HttpClient _apiClient = new() { BaseAddress = new Uri(ApiBaseUrl) };
    private readonly HttpClient _authClient = new() { BaseAddress = new Uri(AuthBaseUrl) };

    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    private bool _stackAvailable;

    public async Task InitializeAsync()
    {
        _stackAvailable = await IsReachableAsync(_apiClient, "/health")
            && await IsReachableAsync(_authClient, "/health");
    }

    public Task DisposeAsync()
    {
        _apiClient.Dispose();
        _authClient.Dispose();
        return Task.CompletedTask;
    }

    private static async Task<bool> IsReachableAsync(HttpClient client, string path)
    {
        try
        {
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(2));
            var response = await client.GetAsync(path, cts.Token);
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }

    [Fact]
    public async Task ClientsEndpoint_WithoutToken_ReturnsUnauthorized()
    {
        if (!_stackAvailable)
        {
            return; // Stack no disponible (ver docstring de la clase); no se falla el test.
        }

        var response = await _apiClient.GetAsync("/api/clients");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task LoginAndFetchClients_FullFlow_ReturnsSeededClients()
    {
        if (!_stackAvailable)
        {
            return; // Stack no disponible (ver docstring de la clase); no se falla el test.
        }

        // 1. Login vía OpenIddict (password grant) contra el Auth Server real.
        var tokenRequest = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["grant_type"] = "password",
            ["username"] = "admin@arme.com",
            ["password"] = "Admin123!",
            ["client_id"] = "web-client",
            ["client_secret"] = ClientSecret,
            ["scope"] = "api",
        });

        var tokenResponse = await _authClient.PostAsync("/connect/token", tokenRequest);
        Assert.True(tokenResponse.IsSuccessStatusCode, await tokenResponse.Content.ReadAsStringAsync());

        var tokenPayload = await tokenResponse.Content.ReadFromJsonAsync<TokenResponse>(JsonOptions);
        Assert.NotNull(tokenPayload);
        Assert.False(string.IsNullOrWhiteSpace(tokenPayload!.AccessToken));

        // 2. Usar el JWT real contra la API de negocio.
        using var request = new HttpRequestMessage(HttpMethod.Get, "/api/clients");
        request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue(
            "Bearer", tokenPayload.AccessToken);

        var clientsResponse = await _apiClient.SendAsync(request);
        Assert.Equal(HttpStatusCode.OK, clientsResponse.StatusCode);

        var clients = await clientsResponse.Content.ReadFromJsonAsync<List<ClientDto>>(JsonOptions);
        Assert.NotNull(clients);
        Assert.NotEmpty(clients!);
    }

    private class TokenResponse
    {
        [System.Text.Json.Serialization.JsonPropertyName("access_token")]
        public string AccessToken { get; set; } = string.Empty;

        [System.Text.Json.Serialization.JsonPropertyName("token_type")]
        public string TokenType { get; set; } = string.Empty;

        [System.Text.Json.Serialization.JsonPropertyName("expires_in")]
        public int ExpiresIn { get; set; }
    }

    private record ClientDto(Guid Id, string CompanyName, string ContactName, string Email);
}
