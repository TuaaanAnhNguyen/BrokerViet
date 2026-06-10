using brokerviet_dotnet.Dtos.Requests;
using brokerviet_dotnet.Dtos.Responses;

namespace brokerviet_dotnet.Services;

public interface ServiceSearchService
{
    Task<List<ServiceSearchItemDto>> SearchAsync(ServiceSearchRequestDto request);
}
