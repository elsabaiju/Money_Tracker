using Microsoft.Data.SqlClient;
using System.Data;
using MoneyTracker.Contract;
using MoneyTracker.Service;
using MoneyTracker.Service;
using MoneyTracker.Services;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddScoped<IDbConnection>(sp =>
new SqlConnection(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add services to the container.

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNamingPolicy = null;
});


builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IUserService, UserServices>();
builder.Services.AddScoped<IExpenseService, ExpenseServices>();
builder.Services.AddScoped<IDebtService, DebtService>();
builder.Services.AddScoped<INoteService, NoteServices>();
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader());
});

builder.Services.AddScoped<ILimitService, LimitService>();
var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseHttpsRedirection();

app.UseCors("AllowAll");

app.UseAuthorization();

app.MapControllers();

app.Run();