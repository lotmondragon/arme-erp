using ArmeErp.Domain.Common;
using ArmeErp.Domain.Enums;

namespace ArmeErp.Domain.Entities;

public class Project : BaseEntity
{
    public string ProjectCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string? Address { get; set; }
    public string? City { get; set; }
    public string? State { get; set; }
    public ProjectStatus Status { get; set; } = ProjectStatus.Planning;
    public decimal ProgressPercentage { get; set; }
    public string HealthStatus { get; set; } = "on_track"; // on_track, at_risk, delayed
    public DateTime? PlannedStartDate { get; set; }
    public DateTime? PlannedEndDate { get; set; }
    public DateTime? ActualStartDate { get; set; }
    public DateTime? ActualEndDate { get; set; }
    public decimal? TotalArea { get; set; }
    public decimal? CoveredArea { get; set; }
    public decimal ContractAmount { get; set; }
    public decimal CurrentBudget { get; set; }
    public decimal TotalExpenses { get; set; }
    public decimal TotalIncome { get; set; }
    public string Priority { get; set; } = "normal";
    public string? Notes { get; set; }
    
    // Foreign keys
    public Guid ClientId { get; set; }
    public Client Client { get; set; } = null!;
    
    public Guid? ProjectManagerId { get; set; }
    public Guid? SiteSupervisorId { get; set; }
    
    // Navigation
    public ICollection<ProjectStage> Stages { get; set; } = new List<ProjectStage>();
    public ICollection<Budget> Budgets { get; set; } = new List<Budget>();
    public ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();
    public ICollection<Contract> Contracts { get; set; } = new List<Contract>();
    public ICollection<Expense> Expenses { get; set; } = new List<Expense>();
}
