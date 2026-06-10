using BrokerViet.BackendDotnet.Repositories;
using brokerviet_dotnet.Dtos.Requests;
using brokerviet_dotnet.Dtos.Responses;

namespace brokerviet_dotnet.Services.Impl;

public sealed class ServiceSearchServiceImpl : ServiceSearchService
{
    private const int DefaultLimit = 20;
    private const int MaxLimit = 100;

    private readonly ServiceRepository _repository;

    public ServiceSearchServiceImpl(ServiceRepository repository)
    {
        _repository = repository;
    }

    public Task<List<ServiceSearchItemDto>> SearchAsync(ServiceSearchRequestDto request)
    {
        if (request.MinPrice.HasValue && request.MaxPrice.HasValue && request.MinPrice > request.MaxPrice)
        {
            throw new ArgumentException("MinPrice cannot be greater than MaxPrice.");
        }

        var normalizedRequest = new ServiceSearchRequestDto
        {
            CategoryId = request.CategoryId,
            Search = string.IsNullOrWhiteSpace(request.Search) ? null : request.Search.Trim(),
            MinPrice = request.MinPrice,
            MaxPrice = request.MaxPrice,
            Limit = NormalizeLimit(request.Limit),
            Offset = NormalizeOffset(request.Offset)
        };

        return _repository.SearchByFiltersAsync(normalizedRequest);
    }

    private static int NormalizeLimit(int? limit)
    {
        if (!limit.HasValue || limit.Value <= 0)
        {
            return DefaultLimit;
        }

        return Math.Min(limit.Value, MaxLimit);
    }

    private static int NormalizeOffset(int? offset)
    {
        if (!offset.HasValue || offset.Value < 0)
        {
            return 0;
        }

        return offset.Value;
    }
}
