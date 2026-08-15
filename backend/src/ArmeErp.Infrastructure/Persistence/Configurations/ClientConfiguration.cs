using ArmeErp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ArmeErp.Infrastructure.Persistence.Configurations;

public class ClientConfiguration : IEntityTypeConfiguration<Client>
{
    public void Configure(EntityTypeBuilder<Client> builder)
    {
        builder.HasKey(c => c.Id);
        
        builder.Property(c => c.ClientCode)
            .IsRequired()
            .HasMaxLength(20);
        
        builder.Property(c => c.CompanyName)
            .IsRequired()
            .HasMaxLength(255);
        
        builder.Property(c => c.ContactName)
            .IsRequired()
            .HasMaxLength(200);
        
        builder.Property(c => c.Email)
            .IsRequired()
            .HasMaxLength(255);
        
        builder.Property(c => c.Phone)
            .HasMaxLength(20);
            
        builder.Property(c => c.Mobile)
            .HasMaxLength(20);
        
        builder.Property(c => c.Address)
            .HasMaxLength(500);
            
        builder.Property(c => c.RFC)
            .HasMaxLength(13);
            
        builder.Property(c => c.CreditLimit)
            .HasPrecision(15, 2);
            
        builder.Property(c => c.TotalRevenue)
            .HasPrecision(15, 2);
        
        builder.HasMany(c => c.Projects)
            .WithOne(p => p.Client)
            .HasForeignKey(p => p.ClientId)
            .OnDelete(DeleteBehavior.Restrict);
        
        builder.HasIndex(c => c.ClientCode).IsUnique();
        builder.HasIndex(c => c.Email);
        builder.HasIndex(c => c.RFC);
        builder.HasIndex(c => c.CompanyName);
    }
}
