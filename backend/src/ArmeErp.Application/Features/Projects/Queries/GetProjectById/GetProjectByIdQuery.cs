using ArmeErp.Application.DTOs;
using MediatR;

namespace ArmeErp.Application.Features.Projects.Queries.GetProjectById;

public record GetProjectByIdQuery(Guid Id) : IRequest<ProjectDto?>;
