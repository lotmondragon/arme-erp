using ArmeErp.Application.DTOs;
using MediatR;

namespace ArmeErp.Application.Features.Projects.Commands.CreateProject;

public record CreateProjectCommand(CreateProjectDto Project) : IRequest<ProjectDto>;
