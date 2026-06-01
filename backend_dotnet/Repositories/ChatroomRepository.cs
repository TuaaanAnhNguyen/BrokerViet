using BrokerViet.BackendDotnet.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class ChatroomRepository : SupabaseRepository<Chatroom>
{
    public ChatroomRepository(Supabase.Client client) : base(client)
    {
    }
}