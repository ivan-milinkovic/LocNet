using Microsoft.AspNetCore.Identity;

namespace LocNet.DbModel;

public class User : IdentityUser
{
    public List<Project> Projects { get; } = [];
}
