using LocNet.DbModel;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace LocNet.Pages;

public class ProjectsModel: PageModel
{
    public readonly LocDbContext locDb;
    public IList<Project> Projects { get; set; } = [];
    public int Count { get; set; }

    public ProjectsModel(LocDbContext locDb)
    {
        this.locDb = locDb;
    }

    public async Task OnGetAsync()
    {
        // Projects = locDb.Projects.Select( p => new ProjectViewModel(p.Name, p.Id.ToString()) ).ToList();
        Projects = locDb.Projects.ToList();
        Count = await locDb.Projects.CountAsync();
    }
}

public record ProjectViewModel(string Name, string Id);
