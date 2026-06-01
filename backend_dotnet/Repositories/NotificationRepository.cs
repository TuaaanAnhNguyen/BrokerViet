using BrokerViet.BackendDotnet.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class NotificationRepository : SupabaseRepository<Notification>
{
    public NotificationRepository(Supabase.Client client) : base(client)
    {
    }
}