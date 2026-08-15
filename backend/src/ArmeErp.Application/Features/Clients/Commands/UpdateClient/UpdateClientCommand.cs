using ArmeErp.Application.DTOs;
using MediatR;

namespace ArmeErp.Application.Features.Clients.Commands.UpdateClient;

public record UpdateClientCommand(
    Guid Id,
    string CompanyName,
    string ContactName,
    string Email,
    string Phone,
    string Address,
    string? RFC
) : IRequest<ClientDto>;
