using ArmeErp.Application.DTOs;
using ArmeErp.Application.Interfaces;
using MediatR;

namespace ArmeErp.Application.Features.Clients.Commands.UpdateClient;

public class UpdateClientCommandHandler : IRequestHandler<UpdateClientCommand, ClientDto>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateClientCommandHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ClientDto> Handle(UpdateClientCommand request, CancellationToken cancellationToken)
    {
        var client = await _unitOfWork.Clients.GetByIdAsync(request.Id, cancellationToken);
        
        if (client == null)
            throw new KeyNotFoundException($"Client with ID {request.Id} not found");

        client.CompanyName = request.CompanyName;
        client.ContactName = request.ContactName;
        client.Email = request.Email;
        client.Phone = request.Phone;
        client.Address = request.Address;
        client.RFC = request.RFC;

        await _unitOfWork.Clients.UpdateAsync(client, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

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
