using ArmeErp.Application.DTOs;
using ArmeErp.Application.Interfaces;
using MediatR;

namespace ArmeErp.Application.Features.Projects.Queries.GetAllProjects;

public class GetAllProjectsQueryHandler : IRequestHandler<GetAllProjectsQuery, List<ProjectDto>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetAllProjectsQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<List<ProjectDto>> Handle(GetAllProjectsQuery request, CancellationToken cancellationToken)
    {
        var projects = await _unitOfWork.Projects.GetAllAsync();
        
        return projects.Select(p => new ProjectDto
        {
            Id = p.Id,
            ProjectCode = p.ProjectCode,
            Name = p.Name,
            Description = p.Description,
            Location = p.Location,
            City = p.City,
            State = p.State,
            Status = p.Status,
            ProgressPercentage = p.ProgressPercentage,
            HealthStatus = p.HealthStatus,
            PlannedStartDate = p.PlannedStartDate,
            PlannedEndDate = p.PlannedEndDate,
            ActualStartDate = p.ActualStartDate,
            ActualEndDate = p.ActualEndDate,
            TotalArea = p.TotalArea,
            ContractAmount = p.ContractAmount,
            CurrentBudget = p.CurrentBudget,
            TotalExpenses = p.TotalExpenses,
            TotalIncome = p.TotalIncome,
            Priority = p.Priority,
            ClientId = p.ClientId,
            ClientName = p.Client?.CompanyName ?? string.Empty,
            CreatedAt = p.CreatedAt
        }).ToList();
    }
}
