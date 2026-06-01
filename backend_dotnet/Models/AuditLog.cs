using System.Text.Json.Nodes;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

[Table("audit_logs")]
public class AuditLog : BaseModel
{
    [PrimaryKey("log_id", false)]
    [Column("log_id")]
    public Guid? LogId { get; set; }

    [Column("created_at")]
    public DateTimeOffset? CreatedAt { get; set; }

    [Column("log_type")]
    public string? LogType { get; set; }

    [Column("performed_by")]
    public Guid? PerformedBy { get; set; }

    [Column("table_name")]
    public string? TargetTableName { get; set; }

    [Column("record_id")]
    public string? RecordId { get; set; }

    [Column("old_value")]
    public JsonNode? OldValue { get; set; }

    [Column("new_value")]
    public JsonNode? NewValue { get; set; }
}