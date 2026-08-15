using ArmeErp.Domain.Common;
using ArmeErp.Domain.Enums;

namespace ArmeErp.Domain.Entities;

public class Expense : BaseEntity
{
    public string ExpenseCode { get; set; } = string.Empty;
    
    public Guid ProjectId { get; set; }
    public Project Project { get; set; } = null!;
    
    public ExpenseType ExpenseType { get; set; }
    public string? Category { get; set; }
    public string Description { get; set; } = string.Empty;
    
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "MXN";
    
    public DateTime ExpenseDate { get; set; }
    
    public Guid? SupplierId { get; set; }
    public Guid? InvoiceId { get; set; }
    
    public string? ReceiptFilePath { get; set; }
    public bool IsBillable { get; set; } = true;
    
    public string? Notes { get; set; }
}
