using ArmeErp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ArmeErp.Infrastructure.Persistence.Configurations;

public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.PaymentCode)
            .IsRequired()
            .HasMaxLength(20);
            
        builder.Property(e => e.Amount)
            .HasPrecision(15, 2);
            
        builder.Property(e => e.Currency)
            .HasMaxLength(3)
            .HasDefaultValue("MXN");
        
        builder.HasOne(e => e.Project)
            .WithMany()
            .HasForeignKey(e => e.ProjectId)
            .OnDelete(DeleteBehavior.SetNull);
            
        builder.HasOne(e => e.Invoice)
            .WithMany()
            .HasForeignKey(e => e.InvoiceId)
            .OnDelete(DeleteBehavior.SetNull);
            
        builder.HasOne(e => e.Client)
            .WithMany()
            .HasForeignKey(e => e.ClientId)
            .OnDelete(DeleteBehavior.SetNull);
            
        builder.HasIndex(e => e.PaymentCode)
            .IsUnique();
            
        builder.HasIndex(e => e.PaymentDate);
    }
}
