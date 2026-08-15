using ArmeErp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ArmeErp.Infrastructure.Persistence.Configurations;

public class ContractConfiguration : IEntityTypeConfiguration<Contract>
{
    public void Configure(EntityTypeBuilder<Contract> builder)
    {
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.ContractCode)
            .IsRequired()
            .HasMaxLength(20);
            
        builder.Property(e => e.Title)
            .IsRequired()
            .HasMaxLength(255);
            
        builder.Property(e => e.Description)
            .HasMaxLength(2000);
            
        builder.Property(e => e.TotalAmount)
            .HasPrecision(15, 2);
            
        builder.Property(e => e.Currency)
            .HasMaxLength(3)
            .HasDefaultValue("MXN");
        
        builder.HasOne(e => e.Project)
            .WithMany(p => p.Contracts)
            .HasForeignKey(e => e.ProjectId)
            .OnDelete(DeleteBehavior.SetNull);
            
        builder.HasOne(e => e.Client)
            .WithMany()
            .HasForeignKey(e => e.ClientId)
            .OnDelete(DeleteBehavior.SetNull);
            
        builder.HasIndex(e => e.ContractCode)
            .IsUnique();
    }
}
