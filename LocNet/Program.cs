using LocNet;
using LocNet.Endpoints;
using LocNet.DbModel;
using LocNet.Exceptions;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddLogging();

builder.Services.AddDbContext<LocDbContext>((options) =>
{
    options.UseSqlite("Data Source=db/locnet.sqlite");
    if (builder.Environment.IsDevelopment())
        options.EnableSensitiveDataLogging();
});

if (builder.Environment.IsDevelopment())
{
    builder.Services.AddDatabaseDeveloperPageExceptionFilter();
}

// builder.Services.AddOptions<BearerTokenOptions>(IdentityConstants.BearerScheme)
// .Configure(opt =>
// {
//     opt.BearerTokenExpiration = TimeSpan.FromSeconds(5);
//     opt.RefreshTokenExpiration = TimeSpan.FromSeconds(10);
// });

builder.Services
    .AddIdentityApiEndpoints<User>()
    .AddEntityFrameworkStores<LocDbContext>();

// builder.Services.AddRazorPages();

builder.Services.Configure<IdentityOptions>(opt =>
{
    opt.Password.RequireDigit = false;
    opt.Password.RequireLowercase = false;
    opt.Password.RequireUppercase = false;
    opt.Password.RequireNonAlphanumeric = false;
    opt.Password.RequiredLength = 4;
});

builder.Services.AddAuthorization();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddScoped<LocService>();


var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.MapProjectEndpoints();

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.MapIdentityApi<User>();
app.UseMiddleware<LocExceptionMiddleware>();

// app.MapRazorPages();

app.Run();
