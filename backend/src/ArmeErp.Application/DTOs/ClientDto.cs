namespace ArmeErp.Application.DTOs;

public record ClientDto(
    Guid Id,
    string CompanyName,
    string ContactName,
    string Email,
    string Phone,
    string Address,
    string? TaxId,
    DateTime CreatedAt
);

public record CreateClientDto(
    string CompanyName,
    string ContactName,
    string Email,
    string Phone,
    string Address,
    string? TaxId
);

public record UpdateClientDto(
    Guid Id,
    string CompanyName,
    string ContactName,
    string Email,
    string Phone,
    string Address,
    string? TaxId
);
