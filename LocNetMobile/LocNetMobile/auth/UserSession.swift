//
//  UserSession.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import Foundation

class UserSession: ObservableObject {
    
    let httpClient: HttpClient
    
    @Published var tokens: Tokens?
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func login(credentials: Credentials) async throws {
        let tokens: Tokens = try await httpClient.postJson(path: "login", body: credentials)
        await MainActor.run {
            self.tokens = tokens
        }
    }
    
    func handleAuthorizationFail() {
        tokens = nil
    }
}
