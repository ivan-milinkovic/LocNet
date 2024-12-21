
using System.ComponentModel.DataAnnotations;

namespace LocNet.DbModel;

public class Project
{
    [Key]
    public required Guid Id { get; set; }

    [MaxLength(100)]
    public required string Name { get; set; }

    public ICollection<Entry> Entries { get; } = []; // new List<Entries>();

    public List<User> Users { get; } = [];
}
