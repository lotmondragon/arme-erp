using ArmeErp.Application.DTOs;
using ArmeErp.Application.Features.Projects.Commands.CreateProject;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using Moq;

namespace ArmeErp.Application.Tests.Projects;

public class CreateProjectCommandHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWork = new();
    private readonly Mock<IRepository<Project>> _projectRepository = new();
    private readonly Mock<IRepository<Client>> _clientRepository = new();

    public CreateProjectCommandHandlerTests()
    {
        _unitOfWork.Setup(u => u.Projects).Returns(_projectRepository.Object);
        _unitOfWork.Setup(u => u.Clients).Returns(_clientRepository.Object);
    }

    [Fact]
    public async Task Handle_NoExistingProjects_GeneratesFirstProjectCode()
    {
        _projectRepository
            .Setup(r => r.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(Enumerable.Empty<Project>());

        var client = new Client { CompanyName = "Naves del Norte" };
        _clientRepository
            .Setup(r => r.GetByIdAsync(client.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(client);

        var dto = new CreateProjectDto
        {
            Name = "Nave Industrial A",
            Location = "Parque Industrial Norte",
            ClientId = client.Id,
            ContractAmount = 1_500_000m,
        };

        var handler = new CreateProjectCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(new CreateProjectCommand(dto), CancellationToken.None);

        Assert.Equal("PRJ-000001", result.ProjectCode);
        Assert.Equal(dto.Name, result.Name);
        Assert.Equal(dto.ContractAmount, result.ContractAmount);
        Assert.Equal(dto.ContractAmount, result.CurrentBudget);
        Assert.Equal(client.CompanyName, result.ClientName);
        Assert.Equal(ArmeErp.Domain.Enums.ProjectStatus.Planning, result.Status);
    }

    [Fact]
    public async Task Handle_ExistingProjects_GeneratesSequentialProjectCode()
    {
        var existingProjects = new List<Project>
        {
            new() { ProjectCode = "PRJ-000001" },
            new() { ProjectCode = "PRJ-000002" },
        };
        _projectRepository
            .Setup(r => r.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(existingProjects);

        var client = new Client { CompanyName = "Naves del Norte" };
        _clientRepository
            .Setup(r => r.GetByIdAsync(client.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(client);

        var dto = new CreateProjectDto
        {
            Name = "Nave Industrial C",
            Location = "Parque Industrial Norte",
            ClientId = client.Id,
            ContractAmount = 500_000m,
        };

        var handler = new CreateProjectCommandHandler(_unitOfWork.Object);

        var result = await handler.Handle(new CreateProjectCommand(dto), CancellationToken.None);

        Assert.Equal("PRJ-000003", result.ProjectCode);
    }
}
