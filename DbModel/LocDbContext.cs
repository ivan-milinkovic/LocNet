using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace LocNet.DbModel;

public class LocDbContext(DbContextOptions<LocDbContext> options, ILogger<LocDbContext> log)
    : IdentityDbContext(options)
{
    public required DbSet<Key> Keys { get; set; }
    public required DbSet<Locale> Locales { get; set; }
    public required DbSet<Entry> Entries { get; set; }
    public required DbSet<Project> Projects { get; set; }
    //public required DbSet<User> Users { get; set; }

    private readonly ILogger<LocDbContext> _log = log;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        var project = new Project { Id = new Guid("f62aa12b-15d9-49a7-8817-02ac6729c0af"), Name = "HelloWorld" };

        var localeEn = new Locale { Id = new Guid("7988ea0c-f91a-4419-950d-4d7b2485fcbd"), ProjectId = project.Id, Code = "en" };
        var localeRs = new Locale { Id = new Guid("2d0155e6-e474-42c0-bd8d-02fc33d84e9f"), ProjectId = project.Id, Code = "sr" };

        var keyEle = new Key { Id = new Guid("54b47dd9-e6e7-43ed-9860-56a896406e48"), ProjectId = project.Id, Name = "elephant" };
        var keyCat = new Key { Id = new Guid("0ab7dbd2-eb58-4568-b642-e4e0760a9cce"), ProjectId = project.Id, Name = "cat" };
        var keyDog = new Key { Id = new Guid("bfa178c2-307a-460a-947f-9bd88e272520"), ProjectId = project.Id, Name = "dog" };

        var entryEnEle = new Entry { Id = new Guid("ad9105f7-724c-4b9e-8550-3b3f46d1ec14"), KeyId = keyEle.Id, LocaleId = localeEn.Id, ProjectId = project.Id, Value = "An elephant" };
        var entryEnCat = new Entry { Id = new Guid("83e97db1-cc93-4d50-a0fb-9afae83b12fb"), KeyId = keyCat.Id, LocaleId = localeEn.Id, ProjectId = project.Id, Value = "A cat" };
        var entryEnDog = new Entry { Id = new Guid("f10d76a6-40f6-4c49-a561-550c6b0621b8"), KeyId = keyDog.Id, LocaleId = localeEn.Id, ProjectId = project.Id, Value = "A dog" };

        var entryRsEle = new Entry { Id = new Guid("80b90a74-7382-4d5c-8e98-2ed3019186cb"), KeyId = keyEle.Id, LocaleId = localeRs.Id, ProjectId = project.Id, Value = "Слон" };
        var entryRsCat = new Entry { Id = new Guid("b7e46950-c2d8-4cf2-9b42-93de851c3203"), KeyId = keyCat.Id, LocaleId = localeRs.Id, ProjectId = project.Id, Value = "Мачка" };
        var entryRsDog = new Entry { Id = new Guid("62a644af-e59f-454a-8ff6-622218372304"), KeyId = keyDog.Id, LocaleId = localeRs.Id, ProjectId = project.Id, Value = "Пас" };

        modelBuilder.Entity<Project>().HasData(project);
        modelBuilder.Entity<Locale>().HasData(localeEn, localeRs);
        modelBuilder.Entity<Key>().HasData(keyEle, keyCat, keyDog);
        modelBuilder.Entity<Entry>().HasData(entryEnEle, entryEnCat, entryEnDog, entryRsEle, entryRsCat, entryRsDog);
    }
}
