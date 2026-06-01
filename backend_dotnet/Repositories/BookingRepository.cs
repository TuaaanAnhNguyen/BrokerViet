using BrokerViet.BackendDotnet.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public sealed class BookingRepository : SupabaseRepository<Booking>
{
    public BookingRepository(Supabase.Client client) : base(client)
    {
    }
}