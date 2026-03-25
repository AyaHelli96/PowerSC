using Microsoft.EntityFrameworkCore;
using CyberSpaceNIS2.API.Data;

var builder = WebApplication.CreateBuilder(args);

// MySQL Verbindung (passend zu docker-compose.yml)
var connectionString = "Server=localhost;Port=3306;Database=cyberspace_nis2;User=cyberspace_user;Password=cyberspace123;";
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

// CORS erlauben (damit Frontend zugreifen kann)
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