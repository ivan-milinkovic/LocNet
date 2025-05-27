//
//  LocalesView.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import SwiftUI

struct LocalesView: View {
    
    let project: Project
    let apiService: ApiService
    @State var locales: [LocaleInfo] = []
    @EnvironmentObject var viewFactory: ViewFactory
    
    var body: some View {
        VStack {
            Text("Locales")
            List(locales) { locale in
                NavigationLink(locale.code, value: locale)
            }
            .navigationDestination(for: LocaleInfo.self) { locale in
                viewFactory.makeEditorView(project: project, locale: locale)
            }
        }
        .navigationTitle(project.name)
        .task {
            await load()
        }
    }
    
    func load() async {
        do {
            self.locales = try await apiService.getLocales(projectId: project.id)
        } catch {
            print(error)
        }
    }
}
