using ArmeErp.Domain.Common;
using ArmeErp.Domain.Enums;

namespace ArmeErp.Domain.Entities;

public class Invoice : BaseEntity
{
    public string InvoiceNumber { get; set; } = string.Empty;
    public DateTime IssueDate { get; set; } = DateTime.UtcNow;
    public DateTime DueDate { get; set; }
    public decimal Amount { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal TotalAmount => Amount + TaxAmount;
    public InvoiceStatus Status { get; set; } = InvoiceStatus.Pending;
    public DateTime? PaidDate { get; set; }
    public string? Notes { get; set; }
    
    // Foreign keys
    public Guid ProjectId { get; set; }
    public Project Project { get; set; } = null!;
}
