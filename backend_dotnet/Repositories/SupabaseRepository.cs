using Supabase.Postgrest.Models;

namespace BrokerViet.BackendDotnet.Repositories;

public abstract class SupabaseRepository<TModel>
    where TModel : BaseModel, new()
{
    protected readonly Supabase.Client Client;

    protected SupabaseRepository(Supabase.Client client)
    {
        Client = client;
    }

    protected Supabase.Postgrest.Interfaces.IPostgrestTable<TModel> Table => Client.From<TModel>();

    public async Task<IReadOnlyList<TModel>> GetAllAsync()
    {
        var response = await Table.Get();
        return response.Models;
    }

    public async Task<IReadOnlyList<TModel>> InsertAsync(TModel item)
    {
        var response = await Table.Insert(item);
        return response.Models;
    }

    public async Task<IReadOnlyList<TModel>> UpdateAsync(TModel item)
    {
        var response = await Table.Update(item);
        return response.Models;
    }

    public async Task<IReadOnlyList<TModel>> DeleteAsync(TModel item)
    {
        var response = await Table.Delete(item);
        return response.Models;
    }
}