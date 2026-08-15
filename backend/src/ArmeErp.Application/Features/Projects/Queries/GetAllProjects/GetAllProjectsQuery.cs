using ArmeErp.Application.DTOs;
using MediatR;

namespace ArmeErp.Application.Features.Projects.Queries.GetAllProjects;

public record GetAllProjectsQuery : IRequest<List<ProjectDto>>;
