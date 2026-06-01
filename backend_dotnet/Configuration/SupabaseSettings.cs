namespace BrokerViet.BackendDotnet.Configuration;

public sealed class SupabaseSettings
{
    public string Url { get; init; } = string.Empty;

    public string AnonKey { get; init; } = string.Empty;
}