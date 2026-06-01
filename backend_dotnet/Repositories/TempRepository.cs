using BrokerViet.BackendDotnet.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class TempRepository : SupabaseRepository<Temp>
{
    public TempRepository(Supabase.Client client) : base(client)
    {
    }
}