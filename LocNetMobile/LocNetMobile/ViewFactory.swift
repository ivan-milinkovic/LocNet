//
//  ViewFactory.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import Foundation
import SwiftUI

class ViewFactory: ObservableObject {
    
    var di: DI!
    
    func makeMainView() -> some View {
        MainView()
    }
    
    func makeProjectsView() -> some View {
        ProjectsView(apiService: di.apiService)
    }
    
    func makeLocalesView(project: Project) -> some View {
        LocalesView(project: project, apiService: di.apiService)
    }
    
    func makeEditorView(project: Project, locale: LocaleInfo) -> some View {
        EditorView(project: project, locale: locale, apiService: di.apiService)
    }
}
