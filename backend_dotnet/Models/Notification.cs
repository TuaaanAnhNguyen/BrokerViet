using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

[Table("notifications")]
public class Notification : BaseModel
{
    [PrimaryKey("notification_id", false)]
    [Column("notification_id")]
    public Guid? NotificationId { get; set; }

    [Column("user_id")]
    public Guid UserId { get; set; }

    [Column("title")]
    public string? Title { get; set; }

    [Column("content")]
    public string? Content { get; set; }

    [Column("is_read")]
    public bool? IsRead { get; set; }

    [Column("created_at")]
    public DateTimeOffset? CreatedAt { get; set; }
}