using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

[Table("messages")]
public class Message : BaseModel
{
    [PrimaryKey("message_id", false)]
    [Column("message_id")]
    public long? MessageId { get; set; }

    [Column("sender_id")]
    public Guid SenderId { get; set; }

    [Column("chatroom_id")]
    public Guid? ChatroomId { get; set; }

    [Column("content")]
    public string? Content { get; set; }

    [Column("sent_at")]
    public DateTimeOffset? SentAt { get; set; }
}