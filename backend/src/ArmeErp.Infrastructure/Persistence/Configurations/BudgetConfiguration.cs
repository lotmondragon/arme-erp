using ArmeErp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ArmeErp.Infrastructure.Persistence.Configurations;

public class BudgetConfiguration : IEntityTypeConfiguration<Budget>
{
    public void Configure(EntityTypeBuilder<Budget> builder)
    {
        builder.HasKey(b => b.Id);
        
        builder.Property(b => b.BudgetNumber)
            .IsRequired()
            .HasMaxLength(50);
        
        builder.Property(b => b.Description)
            .HasMaxLength(1000);
        
        builder.Property(b => b.Amount)
            .HasPrecision(18, 2);
        
        builder.Property(b => b.ApprovedBy)
            .HasMaxLength(100);
        
        builder.HasMany(b => b.Items)
            .WithOne(i => i.Budget)
            .HasForeignKey(i => i.BudgetId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasIndex(b => b.BudgetNumber).IsUnique();
        builder.HasIndex(b => b.Status);
    }
}
