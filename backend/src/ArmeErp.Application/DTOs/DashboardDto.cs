namespace ArmeErp.Application.DTOs;

public class DashboardSummaryDto
{
    public int TotalProjects { get; set; }
    public int ActiveProjects { get; set; }
    public int PlanningProjects { get; set; }
    public int CompletedProjects { get; set; }
    
    public int TotalClients { get; set; }
    public int NewClientsThisMonth { get; set; }
    
    public decimal TotalRevenue { get; set; }
    public decimal TotalExpenses { get; set; }
    public decimal NetProfit { get; set; }
    public decimal ProfitMargin { get; set; }
    
    public decimal PendingReceivables { get; set; }
    public decimal PendingPayables { get; set; }
    
    public List<ProjectSummaryDto> RecentProjects { get; set; } = new();
    public List<FinancialSummaryDto> ProjectFinancials { get; set; } = new();
}

public class ProjectSummaryDto
{
    public Guid Id { get; set; }
    public string ProjectCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string ClientName { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public decimal ProgressPercentage { get; set; }
    public string HealthStatus { get; set; } = string.Empty;
    public decimal ContractAmount { get; set; }
}

public class FinancialSummaryDto
{
    public Guid ProjectId { get; set; }
    public string ProjectCode { get; set; } = string.Empty;
    public string ProjectName { get; set; } = string.Empty;
    public decimal ContractAmount { get; set; }
    public decimal TotalIncome { get; set; }
    public decimal TotalExpenses { get; set; }
    public decimal NetProfit { get; set; }
    public decimal ProfitMargin { get; set; }
}
