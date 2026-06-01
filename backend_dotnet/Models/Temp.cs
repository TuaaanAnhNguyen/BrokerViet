using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

[Table("temp")]
public class Temp : BaseModel
{
    [PrimaryKey("id", false)]
    [Column("id")]
    public long? Id { get; set; }

    [Column("created_at")]
    public DateTimeOffset? CreatedAt { get; set; }
}