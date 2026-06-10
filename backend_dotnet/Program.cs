using BrokerViet.BackendDotnet.Extensions;
using BrokerViet.BackendDotnet.Repositories;
using brokerviet_dotnet.Services;
using brokerviet_dotnet.Services.Impl;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// 1. Đăng ký dịch vụ OpenAPI (Swagger) và cấu hình nút Authorize bảo mật
builder.Services.AddOpenApi(options =>
{
    options.AddDocumentTransformer((document, context, cancellationToken) =>
    {
        // Định nghĩa cấu hình Bearer Token (JWT)
        var scheme = new OpenApiSecurityScheme
        {
            Type = SecuritySchemeType.Http,
            Name = "Authorization",
            In = ParameterLocation.Header,
            Scheme = "Bearer",
            BearerFormat = "JWT",
            Description = "Nhập Token của bạn vào ô dưới đây (Chỉ cần dán chuỗi JWT, không cần gõ chữ 'Bearer ')."
        };

        // Thêm cơ chế bảo mật vào tài liệu OpenAPI
        document.Components ??= new OpenApiComponents();
        document.Components.SecuritySchemes.Add("Bearer", scheme);

        // Áp dụng yêu cầu bảo mật này trên phạm vi toàn cục (Global) cho mọi API
        document.SecurityRequirements.Add(new OpenApiSecurityRequirement
        {
            [new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }] = Array.Empty<string>()
        });

        return Task.CompletedTask;
    });
});

builder.Services.AddScoped<ProfileRepository>();
builder.Services.AddScoped<ProfileServiceImpl>();
builder.Services.AddScoped<ServiceRepository>(); 
builder.Services.AddScoped<ServiceSearchServiceImpl>();

builder.Services.AddBrokerVietSupabase(builder.Configuration);

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

builder.Services.AddControllers();


var app = builder.Build();

app.UseCors();

// 2. Cấu hình Pipeline cho môi trường Development
if (app.Environment.IsDevelopment())
{
    // Tạo endpoint phục vụ file openapi.json tại đường dẫn /openapi/v1.json
    app.MapOpenApi();

    // Kích hoạt Swagger UI và cấu hình để nó đọc file openapi.json từ .NET 9
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/openapi/v1.json", "BrokerViet API v1");
        // Nếu muốn vào thẳng swagger khi chạy (localhost:5077), bỏ comment dòng dưới:
        // options.RoutePrefix = string.Empty; 
    });
}

app.MapControllers();

app.MapGet("/", () => "Hello World!");

app.MapGet("/health/supabase", () => Results.Ok(new { status = "configured" }));

app.Run();
