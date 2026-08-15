using ArmeErp.Application.DTOs;
using ArmeErp.Application.Features.Projects.Commands.UpdateProject;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using ArmeErp.Domain.Enums;
using Moq;

namespace ArmeErp.Application.Tests.Projects;

public class UpdateProjectCommandHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWork = new();
    private readonly Mock<IRepository<Project>> _projectRepository = new();

    public UpdateProjectCommandHandlerTests()
    {
        _unitOfWork.Setup(u => u.Projects).Returns(_projectRepository.Object);
    }

    [Fact]
    public async Task Handle_ExistingProject_UpdatesFieldsAndReturnsDto()
    {
        var client = new Client { CompanyName = "Naves del Norte" };
        var existing = new Project
        {
            ProjectCode = "PRJ-000001",
            Name = "Old Name",
            Location = "Old Location",
            ClientId = client.Id,
            Client = client,
            Status = ProjectStatus.Planning,
        };

        _projectRepository
            .Setup(r => r.GetByIdAsync(existing.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existing);

        var dto = new UpdateProjectDto
        {
            Id = existing.Id,
            Name = "New Name",
            Location = "New Location",
            Status = ProjectStatus.InProgress,
            ProgressPercentage = 40,
            ContractAmount = 2_000_000m,
        };

        var handler = new UpdateProjectCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(new UpdateProjectCommand(dto), CancellationToken.None);

        Assert.NotNull(result);
        Assert.Equal("New Name", result!.Name);
        Assert.Equal("New Location", result.Location);
        Assert.Equal(ProjectStatus.InProgress, result.Status);
        Assert.Equal(40, result.ProgressPercentage);

        _projectRepository.Verify(r => r.UpdateAsync(existing, It.IsAny<CancellationToken>()), Times.Once);
        _unitOfWork.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_UnknownProject_ReturnsNullWithoutSaving()
    {
        var missingId = Guid.NewGuid();
        _projectRepository
            .Setup(r => r.GetByIdAsync(missingId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Project?)null);

        var dto = new UpdateProjectDto { Id = missingId, Name = "Whatever", Location = "Nowhere" };

        var handler = new UpdateProjectCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(new UpdateProjectCommand(dto), CancellationToken.None);

        Assert.Null(result);
        _unitOfWork.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
    }
}
