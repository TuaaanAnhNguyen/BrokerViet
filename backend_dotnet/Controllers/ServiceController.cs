using brokerviet_dotnet.Dtos.Requests;
using brokerviet_dotnet.Services.Impl;
using Microsoft.AspNetCore.Mvc;

namespace brokerviet_dotnet.Controllers;

[Route("api/[controller]")]
[ApiController]
public sealed class ServiceController : ControllerBase
{
    private readonly ServiceSearchServiceImpl _service;

    public ServiceController(ServiceSearchServiceImpl service)
    {
        _service = service;
    }

    [HttpGet("search")]
    public async Task<IActionResult> Search([FromQuery] ServiceSearchRequestDto request)
    {
        try
        {
            var result = await _service.SearchAsync(request);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ex.Message);
        }
    }
}
