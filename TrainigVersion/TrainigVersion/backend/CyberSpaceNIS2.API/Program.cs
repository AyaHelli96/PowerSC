using Microsoft.EntityFrameworkCore;
using CyberSpaceNIS2.API.Data;

var builder = WebApplication.CreateBuilder(args);

// MySQL Verbindung
var connectionString = "Server=localhost;Port=3306;Database=cyberspace_nis2;User=cyberspace_user;Password=cyberspace123;";
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySQL(connectionString));

// CORS erlauben
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("AllowFrontend");
app.UseAuthorization();
app.MapControllers();

app.Run();