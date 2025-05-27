//
//  ContentView.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import SwiftUI

struct ContentView: View {
    
    @Environment(Router.self) var router: Router
    @EnvironmentObject var viewFactory: ViewFactory
    
    var body: some View {
        switch router.route {
        case .login:
            LoginView()
        case .main(_):
            MainView()
        }
    }
}

#Preview {
    let router = Router()
    let httpClient = HttpClient(urlSession: URLSession.shared)
    ContentView()
        .environment(router)
        .environmentObject(UserSession(httpClient: httpClient))
}
