using BrokerViet.BackendDotnet.Repositories;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace BrokerViet.BackendDotnet.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddBrokerVietSupabase(this IServiceCollection services, IConfiguration configuration)
    {
        var supabaseUrl = configuration["Supabase:Url"]
            ?? throw new InvalidOperationException("Missing configuration value: Supabase:Url");

        var supabaseKey = configuration["Supabase:AnonKey"]
            ?? throw new InvalidOperationException("Missing configuration value: Supabase:AnonKey");

        services.AddSingleton(provider =>
        {
            var client = new Supabase.Client(
                supabaseUrl,
                supabaseKey,
                new Supabase.SupabaseOptions
                {
                    AutoConnectRealtime = false,
                    AutoRefreshToken = true
                });

            client.InitializeAsync().GetAwaiter().GetResult();
            return client;
        });

        services.AddScoped<AuditLogRepository>();
        services.AddScoped<BookingRepository>();
        services.AddScoped<ChatroomRepository>();
        services.AddScoped<MessageRepository>();
        services.AddScoped<NotificationRepository>();
        services.AddScoped<ProfileRepository>();
        services.AddScoped<ServiceCategoryRepository>();
        services.AddScoped<ServiceRepository>(provider =>
        {
            var client = provider.GetRequiredService<Supabase.Client>();
            var config = provider.GetRequiredService<IConfiguration>();
            return new ServiceRepository(client, config);
        });
        services.AddScoped<TempRepository>();

        return services;
    }
}