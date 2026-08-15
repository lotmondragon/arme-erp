using ArmeErp.Application.DTOs;
using ArmeErp.Application.Interfaces;
using MediatR;

namespace ArmeErp.Application.Features.Clients.Queries.GetClientById;

public class GetClientByIdQueryHandler : IRequestHandler<GetClientByIdQuery, ClientDto?>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetClientByIdQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ClientDto?> Handle(GetClientByIdQuery request, CancellationToken cancellationToken)
    {
        var client = await _unitOfWork.Clients.GetByIdAsync(request.Id, cancellationToken);
        
        if (client == null)
            return null;

        return new ClientDto(
            client.Id,
            client.CompanyName,
            client.ContactName,
            client.Email,
            client.Phone,
            client.Address,
            client.RFC,
            client.CreatedAt
        );
    }
}
