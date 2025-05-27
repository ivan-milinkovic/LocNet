//
//  DI.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import Foundation

class DI {
    let router: Router
    let userSession: UserSession
    let authHttpClient: HttpClient
    let baseUrl = URL(string:"http://localhost:5297/")!
    let authMediator: AuthMediator
    let apiService: ApiService
    let viewFactory: ViewFactory
    
    init() {
        router = Router()
        
        let sessionHttpClient = HttpClient(urlSession: URLSession.shared, baseUrl: baseUrl)
        userSession = UserSession(httpClient: sessionHttpClient)
        
        authHttpClient = HttpClient(urlSession: URLSession.shared, baseUrl: baseUrl)
        authMediator = AuthMediator(router: router, userSession: userSession, httpClient: authHttpClient)
        
        apiService = ApiService(httpClient: authHttpClient)
        
        viewFactory = ViewFactory()
        viewFactory.di = self
    }
}
