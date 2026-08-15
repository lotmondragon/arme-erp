using ArmeErp.Domain.Enums;

namespace ArmeErp.Application.DTOs;

public class PaymentDto
{
    public Guid Id { get; set; }
    public string PaymentCode { get; set; } = string.Empty;
    public string PaymentType { get; set; } = string.Empty;
    public Guid? ProjectId { get; set; }
    public string? ProjectName { get; set; }
    public Guid? ClientId { get; set; }
    public string? ClientName { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "MXN";
    public PaymentMethod PaymentMethod { get; set; }
    public string? PaymentReference { get; set; }
    public string? BankName { get; set; }
    public DateTime PaymentDate { get; set; }
    public PaymentStatus Status { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreatePaymentDto
{
    public string PaymentType { get; set; } = "income";
    public Guid? ProjectId { get; set; }
    public Guid? ClientId { get; set; }
    public decimal Amount { get; set; }
    public PaymentMethod PaymentMethod { get; set; }
    public string? PaymentReference { get; set; }
    public string? BankName { get; set; }
    public DateTime PaymentDate { get; set; }
    public string? Notes { get; set; }
}
