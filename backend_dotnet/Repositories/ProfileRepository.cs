using BrokerViet.BackendDotnet.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class ProfileRepository : SupabaseRepository<Profile>
{
    public ProfileRepository(Supabase.Client client) : base(client)
    {
    }
}