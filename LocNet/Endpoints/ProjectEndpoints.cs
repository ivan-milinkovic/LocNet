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
         MapUpdateEntryEndpoint(app);
         MapCreateKeyEndpoint(app);
         MapDeleteKeyEndpoint(app);
    }
    
    private static string TryGetUserId(HttpContext context)
    {
        var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId is null) 
            throw new UserIdNotFoundException();
        return userId;
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
                    Locale = e.Locale?.Code ?? "",
                    KeyId = e.KeyId
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
                        Locale = e.Locale?.Code ?? "",
                        KeyId = e.KeyId
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
                    Locale = e.Locale?.Code ?? "",
                    KeyId = e.KeyId
                });
                return TypedResults.Ok(entryDtos.ToList());
                
            })
            .RequireAuthorization();
    }

    private static void MapUpdateEntryEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("/projects/{projectId:guid}/entries",
            async Task< Results<Ok<UpdateEntryDto>, NotFound> > 
                (HttpContext context, LocService locService, [FromRoute] Guid projectId, [FromBody] UpdateEntryDto entryRequestDto) =>
            {
                var userId = TryGetUserId(context);
                var entry = await locService.UpdateEntryAsync(userId, projectId, entryRequestDto.Id, entryRequestDto.Value);
                if (entry is null)
                    return TypedResults.NotFound();
                
                var entryResponseDto = new UpdateEntryDto()
                {
                    Id = entry.Id,
                    Value = entry.Value
                };
                return TypedResults.Ok(entryResponseDto);
            })
            .RequireAuthorization();
    }
    
    private static void MapCreateKeyEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("/projects/{projectId:guid}/keys",
            async (HttpContext context, LocService locService, [FromRoute] Guid projectId, [FromBody] CreateKeyDto keyRequestDto) =>
            {
                var userId = TryGetUserId(context);
                await locService.CreateKeyAsync(userId, projectId, keyRequestDto.Name);
            })
            .RequireAuthorization();
    }
    
    private static void MapDeleteKeyEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("/projects/{projectId:guid}/keys/{keyId:guid}",
                async (HttpContext context, LocService locService, [FromRoute] Guid projectId, [FromRoute] Guid keyId) =>
                {
                    var userId = TryGetUserId(context);
                    await locService.DeleteKeyAsync(userId, projectId, keyId);
                })
            .RequireAuthorization();
    }
}
