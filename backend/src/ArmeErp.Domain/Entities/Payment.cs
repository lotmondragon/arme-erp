using ArmeErp.Domain.Common;
using ArmeErp.Domain.Enums;

namespace ArmeErp.Domain.Entities;

public class Payment : BaseEntity
{
    public string PaymentCode { get; set; } = string.Empty;
    public string PaymentType { get; set; } = "income"; // income, expense
    
    public Guid? ProjectId { get; set; }
    public Project? Project { get; set; }
    
    public Guid? InvoiceId { get; set; }
    public Invoice? Invoice { get; set; }
    
    public Guid? ClientId { get; set; }
    public Client? Client { get; set; }
    
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "MXN";
    
    public PaymentMethod PaymentMethod { get; set; }
    public string? PaymentReference { get; set; }
    public string? BankName { get; set; }
    
    public DateTime PaymentDate { get; set; }
    public DateTime? ProcessedAt { get; set; }
    
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
    
    public string? ReceiptFilePath { get; set; }
    public string? Notes { get; set; }
}
