using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

[Table("bookings")]
public class Booking : BaseModel
{
    [PrimaryKey("booking_id", false)]
    [Column("booking_id")]
    public Guid? BookingId { get; set; }

    [Column("service_id")]
    public Guid ServiceId { get; set; }

    [Column("customer_id")]
    public Guid? CustomerId { get; set; }

    [Column("provider_id")]
    public Guid? ProviderId { get; set; }

    [Column("booked_at")]
    public DateTimeOffset? BookedAt { get; set; }

    [Column("status")]
    public string? Status { get; set; }

    [Column("completed_at")]
    public DateTimeOffset? CompletedAt { get; set; }

    [Column("total_price")]
    public int? TotalPrice { get; set; }

    [Column("scheduled_at")]
    public DateTimeOffset? ScheduledAt { get; set; }

    [Column("service_type")]
    public string? ServiceType { get; set; }
}