import SwiftUI

struct ContentView: View {
    
    let di: DI
    @Environment(Router.self) var router
    
    var body: some View {
        Group {
            switch router.route {
            case .launch:
                Text("Launch")
            case .login:
                LoginView(session: di.session)
            case .main:
                MainView(session: di.session, apiService: di.apiService)
            }
        }
        .onAppear {
            di.session.loadStoredAuthTokens()
        }
    }
}

//#Preview {
//    ContentView()
//}
