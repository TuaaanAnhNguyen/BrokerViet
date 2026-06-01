using BrokerViet.BackendDotnet.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class MessageRepository : SupabaseRepository<Message>
{
    public MessageRepository(Supabase.Client client) : base(client)
    {
    }
}