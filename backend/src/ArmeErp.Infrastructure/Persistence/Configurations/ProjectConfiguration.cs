using ArmeErp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ArmeErp.Infrastructure.Persistence.Configurations;

public class ProjectConfiguration : IEntityTypeConfiguration<Project>
{
    public void Configure(EntityTypeBuilder<Project> builder)
    {
        builder.HasKey(p => p.Id);
        
        builder.Property(p => p.ProjectCode)
            .IsRequired()
            .HasMaxLength(20);
        
        builder.Property(p => p.Name)
            .IsRequired()
            .HasMaxLength(255);
        
        builder.Property(p => p.Description)
            .HasMaxLength(2000);
        
        builder.Property(p => p.Location)
            .HasMaxLength(500);
            
        builder.Property(p => p.ProgressPercentage)
            .HasPrecision(5, 2);
            
        builder.Property(p => p.TotalArea)
            .HasPrecision(12, 2);
            
        builder.Property(p => p.CoveredArea)
            .HasPrecision(12, 2);
        
        builder.Property(p => p.ContractAmount)
            .HasPrecision(15, 2);
            
        builder.Property(p => p.CurrentBudget)
            .HasPrecision(15, 2);
        
        builder.Property(p => p.TotalExpenses)
            .HasPrecision(15, 2);
            
        builder.Property(p => p.TotalIncome)
            .HasPrecision(15, 2);
        
        builder.HasMany(p => p.Stages)
            .WithOne(s => s.Project)
            .HasForeignKey(s => s.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(p => p.Budgets)
            .WithOne(b => b.Project)
            .HasForeignKey(b => b.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(p => p.Invoices)
            .WithOne(i => i.Project)
            .HasForeignKey(i => i.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
            
        builder.HasMany(p => p.Contracts)
            .WithOne(c => c.Project)
            .HasForeignKey(c => c.ProjectId)
            .OnDelete(DeleteBehavior.SetNull);
            
        builder.HasMany(p => p.Expenses)
            .WithOne(e => e.Project)
            .HasForeignKey(e => e.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasIndex(p => p.ProjectCode).IsUnique();
        builder.HasIndex(p => p.Status);
        builder.HasIndex(p => p.ClientId);
        builder.HasIndex(p => p.PlannedStartDate);
        builder.HasIndex(p => p.Name);
    }
}
