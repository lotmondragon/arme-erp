using ArmeErp.Application.DTOs;
using ArmeErp.Application.Interfaces;
using MediatR;

namespace ArmeErp.Application.Features.Clients.Queries.GetAllClients;

public class GetAllClientsQueryHandler : IRequestHandler<GetAllClientsQuery, IEnumerable<ClientDto>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetAllClientsQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<ClientDto>> Handle(GetAllClientsQuery request, CancellationToken cancellationToken)
    {
        var clients = await _unitOfWork.Clients.GetAllAsync(cancellationToken);

        return clients.Select(c => new ClientDto(
            c.Id,
            c.CompanyName,
            c.ContactName,
            c.Email,
            c.Phone,
            c.Address,
            c.RFC,
            c.CreatedAt
        ));
    }
}
