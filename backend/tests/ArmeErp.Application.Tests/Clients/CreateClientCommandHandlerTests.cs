using ArmeErp.Application.Features.Clients.Commands.CreateClient;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using Moq;

namespace ArmeErp.Application.Tests.Clients;

public class CreateClientCommandHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWork = new();
    private readonly Mock<IRepository<Client>> _clientRepository = new();

    public CreateClientCommandHandlerTests()
    {
        _unitOfWork.Setup(u => u.Clients).Returns(_clientRepository.Object);
    }

    [Fact]
    public async Task Handle_PersistsClientAndReturnsDto()
    {
        var command = new CreateClientCommand(
            CompanyName: "Naves del Norte S.A.",
            ContactName: "Ana Torres",
            Email: "ana@navesdelnorte.com",
            Phone: "8112345678",
            Address: "Av. Industria 100",
            RFC: "NNO010101ABC");

        Client? addedClient = null;
        _clientRepository
            .Setup(r => r.AddAsync(It.IsAny<Client>(), It.IsAny<CancellationToken>()))
            .Callback<Client, CancellationToken>((c, _) => addedClient = c)
            .ReturnsAsync((Client c, CancellationToken _) => c);

        var handler = new CreateClientCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(command, CancellationToken.None);

        Assert.NotNull(addedClient);
        Assert.Equal(command.CompanyName, addedClient!.CompanyName);
        Assert.Equal(command.Email, addedClient.Email);
        Assert.Equal(command.RFC, addedClient.RFC);

        Assert.Equal(command.CompanyName, result.CompanyName);
        Assert.Equal(command.ContactName, result.ContactName);
        Assert.Equal(command.Email, result.Email);

        _clientRepository.Verify(r => r.AddAsync(It.IsAny<Client>(), It.IsAny<CancellationToken>()), Times.Once);
        _unitOfWork.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }
}
