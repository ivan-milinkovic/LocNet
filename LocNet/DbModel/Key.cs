using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace LocNet.DbModel;

[Index(nameof(Name), nameof(ProjectId), IsUnique = true)]
public class Key
{
    [Key]
    public required Guid Id { get; set; }

    [MaxLength(100)]
    [Required]
    public required string Name { get; set; }

    [ForeignKey(nameof(Project))]
    public required Guid ProjectId { get; set; }
    public Project? Project { get; set; }
}
