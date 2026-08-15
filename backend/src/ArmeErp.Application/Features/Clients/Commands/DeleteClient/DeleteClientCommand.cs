using MediatR;

namespace ArmeErp.Application.Features.Clients.Commands.DeleteClient;

public record DeleteClientCommand(Guid Id) : IRequest<bool>;
