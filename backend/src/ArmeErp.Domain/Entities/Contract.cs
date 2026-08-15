using ArmeErp.Domain.Common;
using ArmeErp.Domain.Enums;

namespace ArmeErp.Domain.Entities;

public class Contract : BaseEntity
{
    public string ContractCode { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    
    public Guid? ProjectId { get; set; }
    public Project? Project { get; set; }
    
    public Guid? ClientId { get; set; }
    public Client? Client { get; set; }
    
    public decimal TotalAmount { get; set; }
    public string Currency { get; set; } = "MXN";
    
    public DateTime ContractDate { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public DateTime? SignedDate { get; set; }
    
    public ContractStatus Status { get; set; } = ContractStatus.Draft;
    
    public string? PaymentTerms { get; set; }
    public string? DeliveryTerms { get; set; }
    
    public string? FilePath { get; set; }
    public string? SignedFilePath { get; set; }
    
    public string? Notes { get; set; }
}
