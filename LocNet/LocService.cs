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

    public async Task<List<Locale>> GetProjectLocales(string userId, Guid projectId)
    {
        await TryValidateUserIsOnProjectAsync(userId, projectId);
        var locales = _db.Locales
            .Where(locale => locale.ProjectId == projectId);
        return await locales.ToListAsync();
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

    public async Task<Entry?> UpdateEntryAsync(string userId, Guid projectId, Guid entryId, string value)
    {
        await TryValidateUserIsOnProjectAsync(userId, projectId);
        Entry entry;
        try {
            entry = await _db.Entries.Where(e => e.Id == entryId && e.ProjectId == projectId).SingleAsync();
        } catch {
            return null;
        }
        entry.Value = value;
        await _db.SaveChangesAsync();
        return entry;
    }

    public async Task CreateKeyAsync(string userId, Guid projectId, string keyName)
    {
        await TryValidateUserIsOnProjectAsync(userId, projectId);
        var exists = await _db.Keys.Where(k => k.ProjectId == projectId && k.Name == keyName).AnyAsync();
        if (exists)
            throw new EntityAlreadyExistsException();
        
        Key newKey = new Key()
        {
            Id = Guid.NewGuid(),
            Name = keyName,
            ProjectId = projectId
        };
        
        await _db.Keys.AddAsync(newKey);
        
        // Add a new entry (for the new key) for each locale
        
        var localeIds = await _db.Locales
            .Where(l => l.ProjectId == projectId)
            .Select(l => l.Id)
            .ToListAsync();
        
        foreach(var locId in localeIds)
        {
            var entry = new Entry()
            {
                Id = Guid.NewGuid(),
                LocaleId = locId,
                ProjectId = projectId,
                KeyId = newKey.Id,
                Value = ""
            };
            
            await _db.Entries.AddAsync(entry);
        }
        
        await _db.SaveChangesAsync();
    }

    public async Task DeleteKeyAsync(string userId, Guid projectId, Guid keyId)
    {
        // ExecuteDelete only works with relational databases:
        // https://learn.microsoft.com/en-us/ef/core/saving/execute-insert-update-delete
        
        // Transactions will roll back if any of the commands fail: https://learn.microsoft.com/en-us/ef/core/saving/transactions
        
        await TryValidateUserIsOnProjectAsync(userId, projectId);
        await using var transaction = await _db.Database.BeginTransactionAsync();
        await _db.Keys.Where(k => k.Id == keyId).ExecuteDeleteAsync();
        await _db.Entries.Where(e => e.ProjectId == projectId && e.KeyId == keyId).ExecuteDeleteAsync();
        await transaction.CommitAsync();
    }
}
