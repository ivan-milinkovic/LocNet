//
//  ApiServicePreview.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 27. 5. 2025..
//

import Foundation

#if DEBUG
class ApiServicePreview: IApiService {
    
    func getProjects() async throws(NetworkError) -> [Project] {
        []
    }
    
    func getLocales(projectId: String) async throws(NetworkError) -> [LocaleInfo] {
        []
    }
    
    func getEntries(projectId: String, localeCode: String) async throws(NetworkError) -> [Entry] {
        return [
            Entry(id: "0", locale: "en-US", key: "key1", keyId: "1", value: "value1"),
            Entry(id: "1", locale: "en-US", key: "key2", keyId: "2", value: "value2"),
            Entry(id: "2", locale: "en-US", key: "key3", keyId: "3", value: "value3"),
        ]
    }
    
    func updateEntry(projectId: String, updateEntryDto: UpdateEntryDto) async throws(NetworkError) -> UpdateEntryDto {
        return updateEntryDto
    }
    
}
#endif
