using ArmeErp.Application.Features.Clients.Queries.GetAllClients;
using ArmeErp.Application.Features.Clients.Queries.GetClientById;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using Moq;

namespace ArmeErp.Application.Tests.Clients;

public class GetClientsQueryHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWork = new();
    private readonly Mock<IRepository<Client>> _clientRepository = new();

    public GetClientsQueryHandlerTests()
    {
        _unitOfWork.Setup(u => u.Clients).Returns(_clientRepository.Object);
    }

    [Fact]
    public async Task GetAll_ReturnsAllClientsMappedToDto()
    {
        var clients = new List<Client>
        {
            new() { CompanyName = "Cliente A" },
            new() { CompanyName = "Cliente B" },
        };
        _clientRepository
            .Setup(r => r.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(clients);

        var handler = new GetAllClientsQueryHandler(_unitOfWork.Object);

        var result = (await handler.Handle(new GetAllClientsQuery(), CancellationToken.None)).ToList();

        Assert.Equal(2, result.Count);
        Assert.Contains(result, c => c.CompanyName == "Cliente A");
        Assert.Contains(result, c => c.CompanyName == "Cliente B");
    }

    [Fact]
    public async Task GetById_ExistingClient_ReturnsDto()
    {
        var client = new Client { CompanyName = "Cliente A" };
        _clientRepository
            .Setup(r => r.GetByIdAsync(client.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(client);

        var handler = new GetClientByIdQueryHandler(_unitOfWork.Object);

        var result = await handler.Handle(new GetClientByIdQuery(client.Id), CancellationToken.None);

        Assert.NotNull(result);
        Assert.Equal(client.Id, result!.Id);
        Assert.Equal(client.CompanyName, result.CompanyName);
    }

    [Fact]
    public async Task GetById_UnknownClient_ReturnsNull()
    {
        var missingId = Guid.NewGuid();
        _clientRepository
            .Setup(r => r.GetByIdAsync(missingId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Client?)null);

        var handler = new GetClientByIdQueryHandler(_unitOfWork.Object);

        var result = await handler.Handle(new GetClientByIdQuery(missingId), CancellationToken.None);

        Assert.Null(result);
    }
}
