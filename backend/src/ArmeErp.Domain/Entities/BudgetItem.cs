using ArmeErp.Domain.Common;

namespace ArmeErp.Domain.Entities;

public class BudgetItem : BaseEntity
{
    public string Description { get; set; } = string.Empty;
    public decimal Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal Total => Quantity * UnitPrice;
    public string Unit { get; set; } = string.Empty;
    
    // Foreign keys
    public Guid BudgetId { get; set; }
    public Budget Budget { get; set; } = null!;
}
