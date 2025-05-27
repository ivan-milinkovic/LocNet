//
//  AuthMediator.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import Foundation
import Combine

class AuthMediator {
    let router: Router
    let userSession: UserSession
    let httpClient: HttpClient
    let sub: AnyCancellable
    
    init(router: Router, userSession: UserSession, httpClient: HttpClient) {
        self.router = router
        self.userSession = userSession
        self.httpClient = httpClient
        
        sub = userSession.$tokens.sink { tokens in
            if tokens == nil {
                router.route = .login
            } else {
                router.route = .main(.projects(nil))
            }
        }
                
        httpClient.requestInterceptor = { [userSession] request in
            guard let tokens = userSession.tokens else { return }
            request.setValue("\(tokens.tokenType) \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        }
            
        httpClient.responseInterceptor = { [userSession] res in
            if res.statusCode == 401 {
                userSession.handleAuthorizationFail()
            }
        }
    }
}
