using ArmeErp.Domain.Common;

namespace ArmeErp.Domain.Entities;

public class Client : BaseEntity
{
    public string ClientCode { get; set; } = string.Empty;
    public string CompanyName { get; set; } = string.Empty;
    public string ContactName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string? Mobile { get; set; }
    public string Address { get; set; } = string.Empty;
    public string? City { get; set; }
    public string? State { get; set; }
    public string? ZipCode { get; set; }
    public string? RFC { get; set; }
    public string? TaxRegime { get; set; }
    public string ClientType { get; set; } = "particular"; // corporativo, gobierno, particular
    public string Priority { get; set; } = "normal"; // low, normal, high, vip
    public decimal CreditLimit { get; set; }
    public int CreditDays { get; set; }
    public string? Notes { get; set; }
    public int TotalProjects { get; set; }
    public decimal TotalRevenue { get; set; }
    
    // Navigation
    public ICollection<Project> Projects { get; set; } = new List<Project>();
}
