using ArmeErp.Application.DTOs;
using MediatR;

namespace ArmeErp.Application.Features.Clients.Queries.GetAllClients;

public record GetAllClientsQuery : IRequest<IEnumerable<ClientDto>>;
