using LocNet.DbModel;
using LocNet.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace LocNet;

public class LocService(LocDbContext db)
{
    private readonly LocDbContext _db = db;

    private async Task<User> GetUserByIdAsync(string userId)
    {
        var user = (User) await _db.Users.SingleAsync(u => u.Id == userId);
        return user;
    }
    
    private async Task TryValidateUserIsOnProjectAsync(string userId, Guid projectId)
    {
        var user = await GetUserByIdAsync(userId);
        await _db.Entry(user).Collection(u => u.Projects).LoadAsync();
        var project = user.Projects.Find(p => p.Id == projectId);
        if (project is null)
            throw new ProjectUserNotFoundException();
    }

    public async Task<List<Project>> GetUserProjectsAsync(string userId)
    {
        var user = await GetUserByIdAsync(userId);
        await _db.Entry(user).Collection(u => u.Projects).LoadAsync();
        var res = user.Projects;
        return res;
    }
    
    public async Task<List<Entry>> GetProjectEntriesAsync(string userId, Guid projectId)
    {
        await TryValidateUserIsOnProjectAsync(userId, projectId);
        var projectEntries = 
            _db.Entries
                .Where(e => e.ProjectId == projectId)
                .Include(e => e.Key)
                .AsSplitQuery()
                .Include(e => e.Locale)
                .AsSplitQuery();
        return await projectEntries.ToListAsync();
    }
    
    public async Task<Dictionary<string, List<Entry>>> GetProjectEntriesGroupedByLocaleAsync(string userId, Guid projectId)
    {
        await TryValidateUserIsOnProjectAsync(userId, projectId);
        var projectEntries = 
            _db.Entries
                .Where(e => e.ProjectId == projectId)
                .Include(e => e.Key)
                .AsSplitQuery()
                .Include(e => e.Locale)
                .AsSplitQuery()
                .GroupBy(e => e.Locale!.Code);
        var dict = await projectEntries.ToDictionaryAsync(g => g.Key, g => g.ToList());
        return dict;
    }
    
    public async Task<List<Entry>> GetProjectEntriesForLocaleAsync(string userId, Guid projectId, string localeCode)
    {
        await TryValidateUserIsOnProjectAsync(userId, projectId);
        var entries = 
            _db.Entries
                .Where(e => e.ProjectId == projectId)
                .Include(e => e.Key)
                .AsSplitQuery()
                .Include(e => e.Locale)
                .AsSplitQuery()
                .Where(e => e.Locale!.Code == localeCode);
        return await entries.ToListAsync();
    }
}
