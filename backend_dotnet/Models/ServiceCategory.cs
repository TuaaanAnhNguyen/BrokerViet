using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Models;

[Table("service_categories")]
public class ServiceCategory : BaseModel
{
    [PrimaryKey("service_cat_id", false)]
    [Column("service_cat_id")]
    public Guid? ServiceCatId { get; set; }

    [Column("name")]
    public string Name { get; set; } = string.Empty;
}