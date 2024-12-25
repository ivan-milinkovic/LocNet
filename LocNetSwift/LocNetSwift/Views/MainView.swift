import SwiftUI

struct MainView: View {
    
    let session: Session
    let apiService: ApiService
    @State var projects: [Project] = []
    
    var body: some View {
        NavigationStack() {
            VStack {
                List(projects) { project in
                    NavigationLink(value: project) {
                        HStack(alignment: .center) {
                            Text(project.name).font(.title)
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
            .navigationDestination(for: Project.self, destination: { project in
                EditorView(project: project, apiService: apiService)
            })
        }
        .navigationTitle("Projects")
        .task {
            do {
                projects = try await apiService.loadProjectList()
            }
            catch {
                print(error)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Log out") {
                    Task {
                        await session.logout()
                    }
                }
            }
        }
    }
}
