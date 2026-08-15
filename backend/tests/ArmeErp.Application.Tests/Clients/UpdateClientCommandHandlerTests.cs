using ArmeErp.Application.Features.Clients.Commands.UpdateClient;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using Moq;

namespace ArmeErp.Application.Tests.Clients;

public class UpdateClientCommandHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWork = new();
    private readonly Mock<IRepository<Client>> _clientRepository = new();

    public UpdateClientCommandHandlerTests()
    {
        _unitOfWork.Setup(u => u.Clients).Returns(_clientRepository.Object);
    }

    [Fact]
    public async Task Handle_ExistingClient_UpdatesFieldsAndReturnsDto()
    {
        var existing = new Client
        {
            CompanyName = "Old Name",
            ContactName = "Old Contact",
            Email = "old@example.com",
            Phone = "0000000000",
            Address = "Old Address"
        };

        _clientRepository
            .Setup(r => r.GetByIdAsync(existing.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existing);

        var command = new UpdateClientCommand(
            existing.Id,
            CompanyName: "New Name",
            ContactName: "New Contact",
            Email: "new@example.com",
            Phone: "8199999999",
            Address: "New Address",
            RFC: "NEW010101XYZ");

        var handler = new UpdateClientCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(command, CancellationToken.None);

        Assert.Equal("New Name", result.CompanyName);
        Assert.Equal("New Contact", result.ContactName);
        Assert.Equal("new@example.com", result.Email);
        Assert.Equal("NEW010101XYZ", result.TaxId);

        _clientRepository.Verify(r => r.UpdateAsync(existing, It.IsAny<CancellationToken>()), Times.Once);
        _unitOfWork.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_UnknownClient_ThrowsKeyNotFoundException()
    {
        var missingId = Guid.NewGuid();
        _clientRepository
            .Setup(r => r.GetByIdAsync(missingId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Client?)null);

        var command = new UpdateClientCommand(
            missingId, "Name", "Contact", "a@b.com", "123", "Address", null);

        var handler = new UpdateClientCommandHandler(_unitOfWork.Object);

        await Assert.ThrowsAsync<KeyNotFoundException>(() => handler.Handle(command, CancellationToken.None));

        _unitOfWork.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
    }
}
