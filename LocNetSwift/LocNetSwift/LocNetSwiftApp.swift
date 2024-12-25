import SwiftUI

@main
struct LocNetSwiftApp: App {
    
    let di = DI()
    
    var body: some Scene {
        WindowGroup {
            ContentView(di: di)
                .environment(di.router)
        }
    }
}
