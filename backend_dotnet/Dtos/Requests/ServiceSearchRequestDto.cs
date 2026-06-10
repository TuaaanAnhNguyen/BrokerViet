namespace brokerviet_dotnet.Dtos.Requests;

public sealed class ServiceSearchRequestDto
{
    public Guid? CategoryId { get; set; }
    public string? Search { get; set; }
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public int? Limit { get; set; }
    public int? Offset { get; set; }
}
