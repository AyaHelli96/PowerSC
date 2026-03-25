using Microsoft.EntityFrameworkCore;
using CyberSpaceNIS2.API.Models;

namespace CyberSpaceNIS2.API.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Benutzer> Benutzer { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Benutzer>(entity =>
        {
            entity.ToTable("Benutzer");
            entity.HasKey(e => e.BenutzerId);
            entity.HasIndex(e => e.Email).IsUnique();
        });
    }
}