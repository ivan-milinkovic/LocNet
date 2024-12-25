
struct Entry: Decodable, Identifiable {
    let id: String
    let key: String
    let locale: String
    var value: String
    let keyId: String // for deletion
}
