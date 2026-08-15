using ArmeErp.Domain.Common;
using ArmeErp.Domain.Enums;

namespace ArmeErp.Domain.Entities;

public class ProjectStage : BaseEntity
{
    public Guid ProjectId { get; set; }
    public Project Project { get; set; } = null!;
    
    public int StageNumber { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public StageStatus Status { get; set; } = StageStatus.Pending;
    
    public DateTime? PlannedStartDate { get; set; }
    public DateTime? PlannedEndDate { get; set; }
    public DateTime? ActualStartDate { get; set; }
    public DateTime? ActualEndDate { get; set; }
    
    public decimal ProgressPercentage { get; set; }
    public decimal WeightPercentage { get; set; } // Peso en el proyecto total
    
    public Guid? ResponsibleUserId { get; set; }
    
    public decimal? EstimatedCost { get; set; }
    public decimal ActualCost { get; set; }
    
    public string? Notes { get; set; }
    
    // Navigation
    public ICollection<ProjectTask> Tasks { get; set; } = new List<ProjectTask>();
}
