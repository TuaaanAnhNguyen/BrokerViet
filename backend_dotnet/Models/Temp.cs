using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

// "Temp" table used solely to ping Supabase so it would not be paused due to inactivity;
// DO NOT USE FOR ANY BUSINESS LOGIC PURPOSES

[Table("temp")]
public class Temp : BaseModel
{
    [PrimaryKey("id", false)]
    [Column("id")]
    public long? Id { get; set; }

    [Column("created_at")]
    public DateTimeOffset? CreatedAt { get; set; }
}