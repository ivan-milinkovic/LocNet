import Foundation

@MainActor
class ApiService {
    let apiUrl: URL
    let httpClient: HttpClient
    
    init(apiUrl: URL, httpClient: HttpClient) {
        self.apiUrl = apiUrl
        self.httpClient = httpClient
    }
    
    func loadProjectList() async throws(HttpClientError) -> [Project] {
        let projectsUrl = apiUrl.appending(component: "projects")
        let projects: [Project] = try await httpClient.get(url: projectsUrl)
        return projects
    }
    
    func loadEntriesUnsorted(projectId: String) async throws(HttpClientError) -> [Entry] {
        let entriesUrl = apiUrl.appending(components: "projects", projectId, "entries")
        let entries: [Entry] = try await httpClient.get(url: entriesUrl)
        return entries
    }
    
    func loadEntriesGroupedByLocale(projectId: String) async throws(HttpClientError) -> [String: [Entry]] {
        let entriesUrl = apiUrl.appending(components: "projects", projectId, "entriesGroupedByLocale")
        let entries: [String: [Entry]] = try await httpClient.get(url: entriesUrl)
        return entries
    }
    
    func updateEntry(projectId: String, entryDto: UpdateEntryDto) async throws(HttpClientError) -> UpdateEntryDto {
        let updateEntryUrl = apiUrl.appending(components: "projects", projectId, "entries")
        let entryResponse: UpdateEntryDto = try await httpClient.put(url: updateEntryUrl, model: entryDto)
        return entryResponse
    }
    
    func createKey(projectId: String, name: String) async throws(HttpClientError) {
        let createKeyUrl = apiUrl.appending(components: "projects", projectId, "keys")
        let dto = ["name": name]
        try await httpClient.post(url: createKeyUrl, model: dto)
    }
    
    func deleteKey(projectId: String, keyId: String) async throws(HttpClientError) {
        let deleteKeyUrl = apiUrl.appending(components: "projects", projectId, "keys", keyId)
        let nilBody: String? = nil
        try await httpClient.delete(url: deleteKeyUrl, model: nilBody)
    }
}

struct UpdateEntryDto: Codable {
    let id: String
    let value: String
}
