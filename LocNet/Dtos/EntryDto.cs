namespace LocNet.Dtos;

public class EntryDto
{
    public required Guid Id { get; set; }
    public required string Key { get; set; }
    public required string Locale { get; set; }
    public required string Value { get; set; }
    
    // needed for deletion from the client
    public required Guid KeyId { get; set; }
}
