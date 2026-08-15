using ArmeErp.Domain.Enums;

namespace ArmeErp.Application.DTOs;

public class ExpenseDto
{
    public Guid Id { get; set; }
    public string ExpenseCode { get; set; } = string.Empty;
    public Guid ProjectId { get; set; }
    public string ProjectName { get; set; } = string.Empty;
    public ExpenseType ExpenseType { get; set; }
    public string? Category { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "MXN";
    public DateTime ExpenseDate { get; set; }
    public bool IsBillable { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateExpenseDto
{
    public Guid ProjectId { get; set; }
    public ExpenseType ExpenseType { get; set; }
    public string? Category { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime ExpenseDate { get; set; }
    public bool IsBillable { get; set; } = true;
    public string? Notes { get; set; }
}

public class UpdateExpenseDto
{
    public Guid Id { get; set; }
    public ExpenseType ExpenseType { get; set; }
    public string? Category { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime ExpenseDate { get; set; }
    public bool IsBillable { get; set; }
    public string? Notes { get; set; }
}
