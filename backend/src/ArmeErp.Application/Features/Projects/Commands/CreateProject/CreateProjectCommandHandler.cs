using ArmeErp.Application.DTOs;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using ArmeErp.Domain.Enums;
using MediatR;

namespace ArmeErp.Application.Features.Projects.Commands.CreateProject;

public class CreateProjectCommandHandler : IRequestHandler<CreateProjectCommand, ProjectDto>
{
    private readonly IUnitOfWork _unitOfWork;

    public CreateProjectCommandHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ProjectDto> Handle(CreateProjectCommand request, CancellationToken cancellationToken)
    {
        var dto = request.Project;
        
        // Generate unique project code
        var projects = await _unitOfWork.Projects.GetAllAsync();
        var projectCount = projects.Count();
        var projectCode = $"PRJ-{(projectCount + 1):D6}";
        
        var project = new Project
        {
            ProjectCode = projectCode,
            Name = dto.Name,
            Description = dto.Description,
            Location = dto.Location,
            City = dto.City,
            State = dto.State,
            ClientId = dto.ClientId,
            Status = ProjectStatus.Planning,
            ProgressPercentage = 0,
            HealthStatus = "on_track",
            PlannedStartDate = dto.PlannedStartDate,
            PlannedEndDate = dto.PlannedEndDate,
            TotalArea = dto.TotalArea,
            CoveredArea = dto.CoveredArea,
            ContractAmount = dto.ContractAmount,
            CurrentBudget = dto.ContractAmount,
            TotalExpenses = 0,
            TotalIncome = 0,
            Priority = dto.Priority,
            Notes = dto.Notes,
            CreatedAt = DateTime.UtcNow,
            IsDeleted = false
        };

        await _unitOfWork.Projects.AddAsync(project);
        await _unitOfWork.SaveChangesAsync();

        var client = await _unitOfWork.Clients.GetByIdAsync(dto.ClientId);

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
            TotalArea = project.TotalArea,
            ContractAmount = project.ContractAmount,
            CurrentBudget = project.CurrentBudget,
            TotalExpenses = project.TotalExpenses,
            TotalIncome = project.TotalIncome,
            Priority = project.Priority,
            ClientId = project.ClientId,
            ClientName = client?.CompanyName ?? string.Empty,
            CreatedAt = project.CreatedAt
        };
    }
}
