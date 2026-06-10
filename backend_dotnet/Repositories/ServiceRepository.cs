using BrokerViet.BackendDotnet.Models;
using brokerviet_dotnet.Dtos.Requests;
using brokerviet_dotnet.Dtos.Responses;
using Newtonsoft.Json;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class ServiceRepository : SupabaseRepository<Service>
{
    private readonly HttpClient _httpClient;
    private readonly string _supabaseUrl;
    private readonly string _supabaseKey;

    public ServiceRepository(Supabase.Client client, IConfiguration configuration) : base(client)
    {
        _supabaseUrl = configuration["Supabase:Url"]
            ?? throw new InvalidOperationException("Missing Supabase:Url");
        _supabaseKey = configuration["Supabase:AnonKey"]
            ?? throw new InvalidOperationException("Missing Supabase:AnonKey");

        _httpClient = new HttpClient();
        _httpClient.DefaultRequestHeaders.Add("apikey", _supabaseKey);
        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_supabaseKey}");
        _httpClient.DefaultRequestHeaders.Add("Content-Profile", "public"); // ← THÊM
        _httpClient.DefaultRequestHeaders.Add("Accept", "application/json");  // ← THÊM
    }

    public async Task<List<ServiceSearchItemDto>> SearchByFiltersAsync(ServiceSearchRequestDto request)
    {
        var body = new
        {
            p_category_id = request.CategoryId,
            p_search = request.Search,
            p_min_price = request.MinPrice,
            p_max_price = request.MaxPrice,
            p_limit = request.Limit,
            p_offset = request.Offset
        };

        var json = JsonConvert.SerializeObject(body);
        var content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

        var response = await _httpClient.PostAsync(
            $"{_supabaseUrl}/rest/v1/rpc/get_services_list",
            content
        );
        Console.WriteLine($">>> Calling: {_supabaseUrl}/rest/v1/rpc/get_services_list");

        var responseBody = await response.Content.ReadAsStringAsync();
        Console.WriteLine($">>> RPC body sent: {json}");
        Console.WriteLine($">>> RPC response: {responseBody}");

        if (!response.IsSuccessStatusCode)
        {
            throw new Exception($"Supabase RPC error {response.StatusCode}: {responseBody}");
        }

        return JsonConvert.DeserializeObject<List<ServiceSearchItemDto>>(responseBody) ?? [];
    }
}
