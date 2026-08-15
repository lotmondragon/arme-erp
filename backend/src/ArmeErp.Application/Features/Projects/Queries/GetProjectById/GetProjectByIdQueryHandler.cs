using ArmeErp.Application.DTOs;
using ArmeErp.Application.Interfaces;
using MediatR;

namespace ArmeErp.Application.Features.Projects.Queries.GetProjectById;

public class GetProjectByIdQueryHandler : IRequestHandler<GetProjectByIdQuery, ProjectDto?>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetProjectByIdQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ProjectDto?> Handle(GetProjectByIdQuery request, CancellationToken cancellationToken)
    {
        var project = await _unitOfWork.Projects.GetByIdAsync(request.Id);
        
        if (project == null)
            return null;

        return new ProjectDto
        {
            Id = project.Id,
            ProjectCode = project.ProjectCode,
            Name = project.Name,
            Description = project.Description,
            Location = project.Location,
            City = project.City,
            State = project.State,
            Status = project.Status,
            ProgressPercentage = project.ProgressPercentage,
            HealthStatus = project.HealthStatus,
            PlannedStartDate = project.PlannedStartDate,
            PlannedEndDate = project.PlannedEndDate,
            ActualStartDate = project.ActualStartDate,
            ActualEndDate = project.ActualEndDate,
            TotalArea = project.TotalArea,
            ContractAmount = project.ContractAmount,
            CurrentBudget = project.CurrentBudget,
            TotalExpenses = project.TotalExpenses,
            TotalIncome = project.TotalIncome,
            Priority = project.Priority,
            ClientId = project.ClientId,
            ClientName = project.Client?.CompanyName ?? string.Empty,
            CreatedAt = project.CreatedAt
        };
    }
}
