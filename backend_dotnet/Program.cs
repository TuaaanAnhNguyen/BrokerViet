using BrokerViet.BackendDotnet.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddBrokerVietSupabase(builder.Configuration);

var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.MapGet("/health/supabase", () => Results.Ok(new { status = "configured" }));

app.Run();
