using ArmeErp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ArmeErp.Infrastructure.Persistence.Configurations;

public class ProjectTaskConfiguration : IEntityTypeConfiguration<ProjectTask>
{
    public void Configure(EntityTypeBuilder<ProjectTask> builder)
    {
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.Title)
            .IsRequired()
            .HasMaxLength(255);
            
        builder.Property(e => e.Description)
            .HasMaxLength(2000);
            
        builder.Property(e => e.ProgressPercentage)
            .HasPrecision(5, 2);
            
        builder.Property(e => e.EstimatedHours)
            .HasPrecision(8, 2);
            
        builder.Property(e => e.ActualHours)
            .HasPrecision(8, 2);
        
        builder.HasOne(e => e.Project)
            .WithMany()
            .HasForeignKey(e => e.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
            
        builder.HasOne(e => e.Stage)
            .WithMany(s => s.Tasks)
            .HasForeignKey(e => e.StageId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
