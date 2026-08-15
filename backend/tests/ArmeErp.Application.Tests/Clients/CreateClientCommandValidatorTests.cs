using ArmeErp.Application.Features.Clients.Commands.CreateClient;

namespace ArmeErp.Application.Tests.Clients;

public class CreateClientCommandValidatorTests
{
    private readonly CreateClientCommandValidator _validator = new();

    private static CreateClientCommand ValidCommand() => new(
        CompanyName: "Naves del Norte S.A.",
        ContactName: "Ana Torres",
        Email: "ana@navesdelnorte.com",
        Phone: "8112345678",
        Address: "Av. Industria 100",
        RFC: "NNO010101ABC");

    [Fact]
    public void Validate_ValidCommand_HasNoErrors()
    {
        var result = _validator.Validate(ValidCommand());

        Assert.True(result.IsValid);
    }

    [Fact]
    public void Validate_EmptyCompanyName_FailsWithExpectedError()
    {
        var command = ValidCommand() with { CompanyName = "" };

        var result = _validator.Validate(command);

        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.PropertyName == nameof(CreateClientCommand.CompanyName));
    }

    [Theory]
    [InlineData("not-an-email")]
    [InlineData("missing-at-sign.com")]
    public void Validate_InvalidEmail_FailsWithExpectedError(string invalidEmail)
    {
        var command = ValidCommand() with { Email = invalidEmail };

        var result = _validator.Validate(command);

        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.PropertyName == nameof(CreateClientCommand.Email));
    }

    [Fact]
    public void Validate_MissingAddress_FailsWithExpectedError()
    {
        var command = ValidCommand() with { Address = "" };

        var result = _validator.Validate(command);

        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.PropertyName == nameof(CreateClientCommand.Address));
    }
}
