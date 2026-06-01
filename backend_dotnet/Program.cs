using Npgsql;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.MapGet("/health/db", async () =>
{
	var connectionString = builder.Configuration.GetConnectionString("Supabase");

	if (string.IsNullOrWhiteSpace(connectionString))
	{
		return Results.Problem("Missing Supabase connection string.");
	}

	await using var connection = new NpgsqlConnection(connectionString);
	await connection.OpenAsync();

	await using var command = new NpgsqlCommand("select 1", connection);
	var result = await command.ExecuteScalarAsync();

	return Results.Ok(new
	{
		status = "connected",
		database = result
	});
});

app.Run();
