using System.Text.Json.Serialization;

namespace brokerviet_dotnet.Dtos.Responses;

public sealed class ServiceSearchItemDto
{
    [JsonPropertyName("service_id")]
    public Guid? ServiceId { get; set; }

    [JsonPropertyName("provider_id")]
    public Guid ProviderId { get; set; }

    [JsonPropertyName("service_cat_id")]
    public Guid? ServiceCatId { get; set; }

    [JsonPropertyName("category_name")]
    public string? CategoryName { get; set; }

    [JsonPropertyName("title")]
    public string? Title { get; set; }

    [JsonPropertyName("description")]
    public string? Description { get; set; }

    [JsonPropertyName("price")]
    public decimal? Price { get; set; }

    [JsonPropertyName("image_url")]
    public string? ImageUrl { get; set; }
}