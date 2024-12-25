using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace LocNet.DbModel;

[Index(nameof(KeyId), nameof(LocaleId), nameof(ProjectId), IsUnique = true)]
public class Entry
{
    [Key]
    public required Guid Id { get; set; }
    
    public required string Value { get; set; }

    [ForeignKey(nameof(Key))]
    public required Guid KeyId { get; set; }
    public Key? Key { get; set; } = null;

    [ForeignKey(nameof(Locale))]
    public required Guid LocaleId { get; set; }
    public Locale? Locale { get; set; } = null!;

    [ForeignKey(nameof(Project))]
    public required Guid ProjectId { get; set; }
    public Project? Project { get; set; } = null!;
}
