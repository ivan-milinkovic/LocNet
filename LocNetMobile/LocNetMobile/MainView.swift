//
//  NavigationView.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var viewFactory: ViewFactory
    
    var body: some View {
        NavigationStack {
            viewFactory.makeProjectsView()
        }
    }
}
