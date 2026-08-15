using ArmeErp.Domain.Enums;

namespace ArmeErp.Application.DTOs;

public class ProjectDto
{
    public Guid Id { get; set; }
    public string ProjectCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Location { get; set; } = string.Empty;
    public string? City { get; set; }
    public string? State { get; set; }
    public ProjectStatus Status { get; set; }
    public decimal ProgressPercentage { get; set; }
    public string HealthStatus { get; set; } = string.Empty;
    public DateTime? PlannedStartDate { get; set; }
    public DateTime? PlannedEndDate { get; set; }
    public DateTime? ActualStartDate { get; set; }
    public DateTime? ActualEndDate { get; set; }
    public decimal? TotalArea { get; set; }
    public decimal ContractAmount { get; set; }
    public decimal CurrentBudget { get; set; }
    public decimal TotalExpenses { get; set; }
    public decimal TotalIncome { get; set; }
    public string Priority { get; set; } = string.Empty;
    
    // Client info
    public Guid ClientId { get; set; }
    public string ClientName { get; set; } = string.Empty;
    
    // Calculated
    public decimal NetProfit => TotalIncome - TotalExpenses;
    public decimal ProfitMargin => TotalIncome > 0 ? ((TotalIncome - TotalExpenses) / TotalIncome) * 100 : 0;
    
    public DateTime CreatedAt { get; set; }
}

public class CreateProjectDto
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Location { get; set; } = string.Empty;
    public string? City { get; set; }
    public string? State { get; set; }
    public Guid ClientId { get; set; }
    public DateTime? PlannedStartDate { get; set; }
    public DateTime? PlannedEndDate { get; set; }
    public decimal? TotalArea { get; set; }
    public decimal? CoveredArea { get; set; }
    public decimal ContractAmount { get; set; }
    public string Priority { get; set; } = "normal";
    public string? Notes { get; set; }
}

public class UpdateProjectDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Location { get; set; } = string.Empty;
    public string? City { get; set; }
    public string? State { get; set; }
    public ProjectStatus Status { get; set; }
    public decimal ProgressPercentage { get; set; }
    public string HealthStatus { get; set; } = "on_track";
    public DateTime? PlannedStartDate { get; set; }
    public DateTime? PlannedEndDate { get; set; }
    public DateTime? ActualStartDate { get; set; }
    public DateTime? ActualEndDate { get; set; }
    public decimal? TotalArea { get; set; }
    public decimal? CoveredArea { get; set; }
    public decimal ContractAmount { get; set; }
    public string Priority { get; set; } = "normal";
    public string? Notes { get; set; }
}
