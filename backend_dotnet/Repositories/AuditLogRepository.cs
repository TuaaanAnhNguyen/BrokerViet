using BrokerViet.BackendDotnet.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class AuditLogRepository : SupabaseRepository<AuditLog>
{
    public AuditLogRepository(Supabase.Client client) : base(client)
    {
    }
}