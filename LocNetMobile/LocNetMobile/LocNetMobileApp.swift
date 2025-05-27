//
//  LocNetMobileApp.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import SwiftUI

@main
struct LocNetMobileApp: App {
    
    let di = DI()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(di.router)
                .environmentObject(di.userSession)
                .environmentObject(di.viewFactory)
        }
    }
}
