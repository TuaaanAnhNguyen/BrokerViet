using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

[Table("chatrooms")]
public class Chatroom : BaseModel
{
    [PrimaryKey("chatroom_id", false)]
    [Column("chatroom_id")]
    public Guid? ChatroomId { get; set; }

    [Column("provider_id")]
    public Guid ProviderId { get; set; }

    [Column("customer_id")]
    public Guid? CustomerId { get; set; }
}