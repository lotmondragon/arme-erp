using ArmeErp.Domain.Common;
using ArmeErp.Domain.Enums;

namespace ArmeErp.Domain.Entities;

public class ProjectTask : BaseEntity
{
    public Guid ProjectId { get; set; }
    public Project Project { get; set; } = null!;
    
    public Guid? StageId { get; set; }
    public ProjectStage? Stage { get; set; }
    
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public Enums.TaskStatus Status { get; set; } = Enums.TaskStatus.Pending;
    public TaskPriority Priority { get; set; } = TaskPriority.Medium;
    
    public DateTime? PlannedStartDate { get; set; }
    public DateTime? PlannedEndDate { get; set; }
    public DateTime? ActualStartDate { get; set; }
    public DateTime? ActualEndDate { get; set; }
    public DateTime? DueDate { get; set; }
    
    public Guid? AssignedToUserId { get; set; }
    public DateTime? AssignedAt { get; set; }
    
    public decimal ProgressPercentage { get; set; }
    public decimal? EstimatedHours { get; set; }
    public decimal ActualHours { get; set; }
    
    public string? Notes { get; set; }
}
