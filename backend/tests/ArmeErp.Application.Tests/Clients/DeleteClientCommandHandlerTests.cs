using ArmeErp.Application.Features.Clients.Commands.DeleteClient;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using Moq;

namespace ArmeErp.Application.Tests.Clients;

public class DeleteClientCommandHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWork = new();
    private readonly Mock<IRepository<Client>> _clientRepository = new();

    public DeleteClientCommandHandlerTests()
    {
        _unitOfWork.Setup(u => u.Clients).Returns(_clientRepository.Object);
    }

    [Fact]
    public async Task Handle_ExistingClient_DeletesAndReturnsTrue()
    {
        var existing = new Client { CompanyName = "To Delete" };
        _clientRepository
            .Setup(r => r.GetByIdAsync(existing.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existing);

        var handler = new DeleteClientCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(new DeleteClientCommand(existing.Id), CancellationToken.None);

        Assert.True(result);
        _clientRepository.Verify(r => r.DeleteAsync(existing, It.IsAny<CancellationToken>()), Times.Once);
        _unitOfWork.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_UnknownClient_ReturnsFalseWithoutDeleting()
    {
        var missingId = Guid.NewGuid();
        _clientRepository
            .Setup(r => r.GetByIdAsync(missingId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Client?)null);

        var handler = new DeleteClientCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(new DeleteClientCommand(missingId), CancellationToken.None);

        Assert.False(result);
        _clientRepository.Verify(r => r.DeleteAsync(It.IsAny<Client>(), It.IsAny<CancellationToken>()), Times.Never);
        _unitOfWork.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
    }
}
