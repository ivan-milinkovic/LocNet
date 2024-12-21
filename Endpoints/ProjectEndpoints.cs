using System.Security.Claims;
using LocNet.DbModel;
using LocNet.Dtos;
using LocNet.Exceptions;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace LocNet.Endpoints;

public static class ProjectEndpoints
{
    public static void MapProjectEndpoints(this IEndpointRouteBuilder app)
    {
         MapUserProjectsEndpoint(app);
         MapProjectEntriesEndpoint(app);
         MapProjectEntriesGroupedByLocaleEndpoint(app);
         MapProjectEntriesForLocaleEndpoint(app);
    }
    
    private static void MapUserProjectsEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("/projects", async (HttpContext context, LocService locService) =>
            {
                var userId = TryGetUserId(context);
                var projects = await locService.GetUserProjectsAsync(userId);
                var res = projects.Select(p => new ProjectDto() { Id = p.Id, Name = p.Name });
                return res;
            })
            .WithName("UserProjectsEndpoint")
            .RequireAuthorization();
    }
    
    private static void MapProjectEntriesEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("/projects/{projectId:guid}/entries", async (HttpContext context, LocService locService, [FromRoute] Guid projectId) =>
            {
                var userId = TryGetUserId(context);
                var entries = await locService.GetProjectEntriesAsync(userId, projectId);
                var entryDtos = entries.Select(e => new EntryDto()
                {
                    Id = e.Id,
                    Value = e.Value,
                    Key = e.Key?.Name ?? "",
                    Locale = e.Locale?.Code ?? ""
                });
                return entryDtos;
            })
            .RequireAuthorization();
    }

    private static void MapProjectEntriesGroupedByLocaleEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("/projects/{projectId:guid}/entriesGroupedByLocale",
            async (HttpContext context, LocService locService, [FromRoute] Guid projectid) =>
            {
                var userId = TryGetUserId(context);
                var groupedEntries = await locService.GetProjectEntriesGroupedByLocaleAsync(userId, projectid);
                var groupedDtos = groupedEntries.ToDictionary(
                    kv => kv.Key,
                    kv => kv.Value.Select(e => new EntryDto()
                    {
                        Id = e.Id,
                        Value = e.Value,
                        Key = e.Key?.Name ?? "",
                        Locale = e.Locale?.Code ?? ""
                    }));
                return groupedDtos;
            })
            .RequireAuthorization();
    }
    
    private static void MapProjectEntriesForLocaleEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("/projects/{projectId:guid}/entries/{localeCode}", 
                async Task< Results<Ok<List<EntryDto>>, NotFound> > 
                (HttpContext context, LocService locService, [FromRoute] Guid projectId, [FromRoute] string localeCode) =>
            {
                var userId = TryGetUserId(context);
                var entries = await locService.GetProjectEntriesForLocaleAsync(userId, projectId, localeCode);
                var entryDtos = entries.Select(e => new EntryDto()
                {
                    Id = e.Id,
                    Value = e.Value,
                    Key = e.Key?.Name ?? "",
                    Locale = e.Locale?.Code ?? ""
                });
                return TypedResults.Ok(entryDtos.ToList());
                
            })
            .RequireAuthorization();
    }

    private static string TryGetUserId(HttpContext context)
    {
        var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId is null) 
            throw new UserIdNotFoundException();
        return userId;
    }
}
