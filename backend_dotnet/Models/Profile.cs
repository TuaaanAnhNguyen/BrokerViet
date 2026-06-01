using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

[Table("profiles")]
public class Profile : BaseModel
{
    [PrimaryKey("user_id", false)]
    [Column("user_id")]
    public Guid UserId { get; set; }

    [Column("username")]
    public string Username { get; set; } = string.Empty;

    [Column("avatar_url")]
    public string? AvatarUrl { get; set; }

    [Column("bio")]
    public string? Bio { get; set; }

    [Column("role")]
    public string? Role { get; set; }

    [Column("location_latitude")]
    public float? LocationLatitude { get; set; }

    [Column("location_longitude")]
    public float? LocationLongitude { get; set; }

    [Column("opening_hour")]
    public TimeOnly? OpeningHour { get; set; }

    [Column("closing_hour")]
    public TimeOnly? ClosingHour { get; set; }

    [Column("location_text")]
    public string? LocationText { get; set; }

    [Column("address")]
    public string? Address { get; set; }
}