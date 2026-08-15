using ArmeErp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ArmeErp.Infrastructure.Persistence.Configurations;

public class ExpenseConfiguration : IEntityTypeConfiguration<Expense>
{
    public void Configure(EntityTypeBuilder<Expense> builder)
    {
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.ExpenseCode)
            .IsRequired()
            .HasMaxLength(20);
            
        builder.Property(e => e.Description)
            .IsRequired()
            .HasMaxLength(500);
            
        builder.Property(e => e.Amount)
            .HasPrecision(15, 2);
            
        builder.Property(e => e.Currency)
            .HasMaxLength(3)
            .HasDefaultValue("MXN");
        
        builder.HasOne(e => e.Project)
            .WithMany(p => p.Expenses)
            .HasForeignKey(e => e.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
            
        builder.HasIndex(e => e.ExpenseCode)
            .IsUnique();
            
        builder.HasIndex(e => e.ProjectId);
        builder.HasIndex(e => e.ExpenseDate);
    }
}
