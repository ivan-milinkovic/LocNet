using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace LocNet.DbModel;

[Index(nameof(Code), nameof(ProjectId), IsUnique = true)]
public class Locale
{
    [Key]
    public required Guid Id { get; set; }

    [MaxLength(10)]
    public required string Code { get; set; }

    [ForeignKey(nameof(Project))]
    public required Guid ProjectId { get; set; }

    public Project? Project { get; set; }
}
