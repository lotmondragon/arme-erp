using ArmeErp.Application.DTOs;
using ArmeErp.Application.Interfaces;
using MediatR;

namespace ArmeErp.Application.Features.Projects.Commands.UpdateProject;

public class UpdateProjectCommandHandler : IRequestHandler<UpdateProjectCommand, ProjectDto?>
{
    private readonly IUnitOfWork _unitOfWork;

    public UpdateProjectCommandHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ProjectDto?> Handle(UpdateProjectCommand request, CancellationToken cancellationToken)
    {
        var dto = request.Project;
        var project = await _unitOfWork.Projects.GetByIdAsync(dto.Id);
        
        if (project == null)
            return null;

        project.Name = dto.Name;
        project.Description = dto.Description;
        project.Location = dto.Location;
        project.City = dto.City;
        project.State = dto.State;
        project.Status = dto.Status;
        project.ProgressPercentage = dto.ProgressPercentage;
        project.HealthStatus = dto.HealthStatus;
        project.PlannedStartDate = dto.PlannedStartDate;
        project.PlannedEndDate = dto.PlannedEndDate;
        project.ActualStartDate = dto.ActualStartDate;
        project.ActualEndDate = dto.ActualEndDate;
        project.TotalArea = dto.TotalArea;
        project.CoveredArea = dto.CoveredArea;
        project.ContractAmount = dto.ContractAmount;
        project.Priority = dto.Priority;
        project.Notes = dto.Notes;
        project.UpdatedAt = DateTime.UtcNow;

        await _unitOfWork.Projects.UpdateAsync(project);
        await _unitOfWork.SaveChangesAsync();

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
