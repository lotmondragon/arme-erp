using ArmeErp.Application.Features.Projects.Commands.DeleteProject;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using Moq;

namespace ArmeErp.Application.Tests.Projects;

public class DeleteProjectCommandHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWork = new();
    private readonly Mock<IRepository<Project>> _projectRepository = new();

    public DeleteProjectCommandHandlerTests()
    {
        _unitOfWork.Setup(u => u.Projects).Returns(_projectRepository.Object);
    }

    [Fact]
    public async Task Handle_ExistingProject_DeletesAndReturnsTrue()
    {
        var existing = new Project { ProjectCode = "PRJ-000001", Name = "To Delete" };
        _projectRepository
            .Setup(r => r.GetByIdAsync(existing.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existing);

        var handler = new DeleteProjectCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(new DeleteProjectCommand(existing.Id), CancellationToken.None);

        Assert.True(result);
        _projectRepository.Verify(r => r.DeleteAsync(existing, It.IsAny<CancellationToken>()), Times.Once);
        _unitOfWork.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_UnknownProject_ReturnsFalseWithoutDeleting()
    {
        var missingId = Guid.NewGuid();
        _projectRepository
            .Setup(r => r.GetByIdAsync(missingId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Project?)null);

        var handler = new DeleteProjectCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(new DeleteProjectCommand(missingId), CancellationToken.None);

        Assert.False(result);
        _projectRepository.Verify(r => r.DeleteAsync(It.IsAny<Project>(), It.IsAny<CancellationToken>()), Times.Never);
    }
}
