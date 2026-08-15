using ArmeErp.Application.DTOs;
using MediatR;

namespace ArmeErp.Application.Features.Projects.Commands.UpdateProject;

public record UpdateProjectCommand(UpdateProjectDto Project) : IRequest<ProjectDto?>;
