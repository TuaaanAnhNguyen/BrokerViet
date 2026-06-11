using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

[Table("services")]
public class Service : BaseModel
{
    [PrimaryKey("service_id", false)]
    [Column("service_id")]
    public Guid? ServiceId { get; set; }

    [Column("provider_id")]
    public Guid ProviderId { get; set; }

    [Column("service_cat_id")]
    public Guid? ServiceCatId { get; set; }

    [Column("title")]
    public string? Title { get; set; }

    [Column("description")]
    public string? Description { get; set; }

    [Column("price")]
    public decimal? Price { get; set; }

    [Column("image_url")]
    public string? ImageUrl { get; set; }
}