//
//  Api.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

protocol IApiService {
    func getProjects() async throws(NetworkError) -> [Project]
    func getLocales(projectId: String) async throws(NetworkError) -> [LocaleInfo]
    func getEntries(projectId: String, localeCode: String) async throws(NetworkError) -> [Entry]
    func updateEntry(projectId: String, updateEntryDto: UpdateEntryDto) async throws(NetworkError) -> UpdateEntryDto
}

class ApiService: IApiService {
    
    let httpClient: HttpClient
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func getProjects() async throws(NetworkError) -> [Project] {
        let projects: [Project] = try await httpClient.getJson("projects")
        return projects
    }
    
    func getLocales(projectId: String) async throws(NetworkError) -> [LocaleInfo] {
        let path = "projects/\(projectId)/locales"
        let locales: [LocaleInfo] = try await httpClient.getJson(path)
        return locales
    }
    
    func getEntries(projectId: String, localeCode: String) async throws(NetworkError) -> [Entry] {
        let path = "projects/\(projectId)/entries/\(localeCode)"
        let entries: [Entry] = try await httpClient.getJson(path)
        return entries
    }
    
    func updateEntry(projectId: String, updateEntryDto: UpdateEntryDto) async throws(NetworkError) -> UpdateEntryDto {
        let path = "projects/\(projectId)/entries"
        let updated: UpdateEntryDto = try await httpClient.putJson(path: path, body: updateEntryDto)
        return updated
    }
}

struct UpdateEntryDto: Codable {
    let id: String
    let value: String
}
