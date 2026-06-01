using BrokerViet.BackendDotnet.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class ServiceRepository : SupabaseRepository<Service>
{
    public ServiceRepository(Supabase.Client client) : base(client)
    {
    }
}