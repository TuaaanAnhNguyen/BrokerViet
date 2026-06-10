namespace brokerviet_dotnet.Dtos.Responses;

public sealed class ServiceSearchItemDto
{
    [Newtonsoft.Json.JsonProperty("service_id")]
    public Guid? ServiceId { get; set; }

    [Newtonsoft.Json.JsonProperty("provider_id")]
    public Guid ProviderId { get; set; }

    [Newtonsoft.Json.JsonProperty("service_cat_id")]
    public Guid? ServiceCatId { get; set; }

    [Newtonsoft.Json.JsonProperty("category_name")]
    public string? CategoryName { get; set; }

    [Newtonsoft.Json.JsonProperty("title")]
    public string? Title { get; set; }

    [Newtonsoft.Json.JsonProperty("description")]
    public string? Description { get; set; }

    [Newtonsoft.Json.JsonProperty("price")]
    public decimal? Price { get; set; }
}
