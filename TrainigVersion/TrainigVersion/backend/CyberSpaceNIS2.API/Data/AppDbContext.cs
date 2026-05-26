using Microsoft.EntityFrameworkCore;
using CyberSpaceNIS2.API.Models;

namespace CyberSpaceNIS2.API.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Benutzer> Benutzer { get; set; }
    public DbSet<Karte> Karte { get; set; }
    public DbSet<Option> Option { get; set; }
    public DbSet<Szenario> Szenario { get; set; }
    public DbSet<SpielSession> Session { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Benutzer>(entity =>
        {
            entity.ToTable("Benutzer");
            entity.HasKey(e => e.BenutzerId);
            entity.HasIndex(e => e.Email).IsUnique();
        });

        modelBuilder.Entity<Karte>(entity =>
        {
            entity.ToTable("Karte");
            entity.HasKey(e => e.KarteId);
            entity.Property(e => e.Titel).HasMaxLength(80);
            entity.Property(e => e.Inhalt).HasMaxLength(300);
            entity.Property(e => e.KartenCode).HasMaxLength(10);
            entity.HasMany(e => e.Optionen)
                .WithOne()
                .HasForeignKey(o => o.KarteId);
        });

        modelBuilder.Entity<Option>(entity =>
        {
            entity.ToTable("Option");
            entity.HasKey(e => e.OptionId);
            entity.Property(e => e.Text).HasMaxLength(100);
        });

        modelBuilder.Entity<Szenario>(entity =>
        {
            entity.ToTable("Szenario");
            entity.HasKey(e => e.SzenarioId);
            entity.Property(e => e.Titel).HasMaxLength(100);
            
        });
        
        modelBuilder.Entity<SpielSession>(entity =>
        {
            entity.ToTable("Session");
            entity.HasKey(e => e.SessionId);
        });
    }
}