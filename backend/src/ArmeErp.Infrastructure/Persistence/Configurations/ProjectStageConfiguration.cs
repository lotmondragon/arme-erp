using ArmeErp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ArmeErp.Infrastructure.Persistence.Configurations;

public class ProjectStageConfiguration : IEntityTypeConfiguration<ProjectStage>
{
    public void Configure(EntityTypeBuilder<ProjectStage> builder)
    {
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.Name)
            .IsRequired()
            .HasMaxLength(255);
            
        builder.Property(e => e.Description)
            .HasMaxLength(2000);
            
        builder.Property(e => e.ProgressPercentage)
            .HasPrecision(5, 2);
            
        builder.Property(e => e.WeightPercentage)
            .HasPrecision(5, 2);
            
        builder.Property(e => e.EstimatedCost)
            .HasPrecision(15, 2);
            
        builder.Property(e => e.ActualCost)
            .HasPrecision(15, 2);
        
        builder.HasOne(e => e.Project)
            .WithMany(p => p.Stages)
            .HasForeignKey(e => e.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);
            
        builder.HasIndex(e => new { e.ProjectId, e.StageNumber })
            .IsUnique();
    }
}
