using BrokerViet.BackendDotnet.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class ServiceCategoryRepository : SupabaseRepository<ServiceCategory>
{
    public ServiceCategoryRepository(Supabase.Client client) : base(client)
    {
    }
}