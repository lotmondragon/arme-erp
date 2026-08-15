using ArmeErp.Domain.Enums;

namespace ArmeErp.Application.DTOs;

public class ProjectStageDto
{
    public Guid Id { get; set; }
    public Guid ProjectId { get; set; }
    public int StageNumber { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public StageStatus Status { get; set; }
    public DateTime? PlannedStartDate { get; set; }
    public DateTime? PlannedEndDate { get; set; }
    public DateTime? ActualStartDate { get; set; }
    public DateTime? ActualEndDate { get; set; }
    public decimal ProgressPercentage { get; set; }
    public decimal WeightPercentage { get; set; }
    public decimal? EstimatedCost { get; set; }
    public decimal ActualCost { get; set; }
    public string? Notes { get; set; }
    public int TasksCount { get; set; }
    public int CompletedTasksCount { get; set; }
}

public class CreateProjectStageDto
{
    public Guid ProjectId { get; set; }
    public int StageNumber { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? PlannedStartDate { get; set; }
    public DateTime? PlannedEndDate { get; set; }
    public decimal WeightPercentage { get; set; }
    public decimal? EstimatedCost { get; set; }
    public string? Notes { get; set; }
}

public class UpdateProjectStageDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public StageStatus Status { get; set; }
    public DateTime? ActualStartDate { get; set; }
    public DateTime? ActualEndDate { get; set; }
    public decimal ProgressPercentage { get; set; }
    public decimal ActualCost { get; set; }
    public string? Notes { get; set; }
}
