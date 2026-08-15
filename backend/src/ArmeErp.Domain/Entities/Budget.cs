using ArmeErp.Domain.Common;
using ArmeErp.Domain.Enums;

namespace ArmeErp.Domain.Entities;

public class Budget : BaseEntity
{
    public string BudgetNumber { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public BudgetStatus Status { get; set; } = BudgetStatus.Draft;
    public DateTime IssueDate { get; set; } = DateTime.UtcNow;
    public DateTime? ApprovedDate { get; set; }
    public string? ApprovedBy { get; set; }
    public string? Notes { get; set; }
    
    // Foreign keys
    public Guid ProjectId { get; set; }
    public Project Project { get; set; } = null!;
    
    // Navigation
    public ICollection<BudgetItem> Items { get; set; } = new List<BudgetItem>();
}
