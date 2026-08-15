using ArmeErp.Application.Features.Projects.Queries.GetAllProjects;
using ArmeErp.Application.Features.Projects.Queries.GetProjectById;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using Moq;

namespace ArmeErp.Application.Tests.Projects;

public class GetProjectsQueryHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWork = new();
    private readonly Mock<IRepository<Project>> _projectRepository = new();

    public GetProjectsQueryHandlerTests()
    {
        _unitOfWork.Setup(u => u.Projects).Returns(_projectRepository.Object);
    }

    [Fact]
    public async Task GetAll_ReturnsAllProjectsMappedToDto()
    {
        var client = new Client { CompanyName = "Naves del Norte" };
        var projects = new List<Project>
        {
            new() { ProjectCode = "PRJ-000001", Name = "Nave A", ClientId = client.Id, Client = client },
            new() { ProjectCode = "PRJ-000002", Name = "Nave B", ClientId = client.Id, Client = client },
        };
        _projectRepository
            .Setup(r => r.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(projects);

        var handler = new GetAllProjectsQueryHandler(_unitOfWork.Object);

        var result = await handler.Handle(new GetAllProjectsQuery(), CancellationToken.None);

        Assert.Equal(2, result.Count);
        Assert.Contains(result, p => p.ProjectCode == "PRJ-000001");
        Assert.All(result, p => Assert.Equal(client.CompanyName, p.ClientName));
    }

    [Fact]
    public async Task GetById_ExistingProject_ReturnsDto()
    {
        var client = new Client { CompanyName = "Naves del Norte" };
        var project = new Project { ProjectCode = "PRJ-000001", Name = "Nave A", ClientId = client.Id, Client = client };

        _projectRepository
            .Setup(r => r.GetByIdAsync(project.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(project);

        var handler = new GetProjectByIdQueryHandler(_unitOfWork.Object);

        var result = await handler.Handle(new GetProjectByIdQuery(project.Id), CancellationToken.None);

        Assert.NotNull(result);
        Assert.Equal(project.Id, result!.Id);
        Assert.Equal(project.Name, result.Name);
    }

    [Fact]
    public async Task GetById_UnknownProject_ReturnsNull()
    {
        var missingId = Guid.NewGuid();
        _projectRepository
            .Setup(r => r.GetByIdAsync(missingId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Project?)null);

        var handler = new GetProjectByIdQueryHandler(_unitOfWork.Object);

        var result = await handler.Handle(new GetProjectByIdQuery(missingId), CancellationToken.None);

        Assert.Null(result);
    }
}
