using ArmeErp.Application.DTOs;
using MediatR;

namespace ArmeErp.Application.Features.Clients.Queries.GetClientById;

public record GetClientByIdQuery(Guid Id) : IRequest<ClientDto?>;
