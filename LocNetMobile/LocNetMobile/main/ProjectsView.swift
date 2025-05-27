//
//  ProjectsView.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import SwiftUI

struct ProjectsView: View {
    
    @EnvironmentObject var viewFactory: ViewFactory
    
    let apiService: ApiService
    @State var projects: [Project] = []
    @State var isLoading = false
    @State var error: NetworkError? = nil
    
    var body: some View {
        List(projects) { project in
            NavigationLink(project.name, value: project)
        }
        .navigationDestination(for: Project.self, destination: { project in
            viewFactory.makeLocalesView(project: project)
        })
        .task {
            await load()
        }
        .alert("Something went wrong", isPresented: errorBinding) {
            Button("OK") { error = nil }
        }
    }
    
    var errorBinding: Binding<Bool> {
        Binding<Bool>(
        get: {
            return error != nil
        }, set: { newVal in
            if !newVal { error = nil }
        })
    }
    
    func load() async {
        isLoading = true; defer { isLoading = false }
        do {
            self.projects = try await apiService.getProjects()
        } catch {
            
        }
    }
}
