//
//  EditorView.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 27. 5. 2025..
//

import SwiftUI

struct EditorView: View {
    
    let project: Project
    let locale: LocaleInfo
    let apiService: IApiService
    @State var entries: [Entry] = []
    @State var deletionIndexSet: IndexSet? = nil
    
    var body: some View {
        List {
            ForEach($entries) { $entry in
                Section {
                    Grid {
                        GridRow {
                            Text("Key:")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)
                            
                            Text(entry.key)
                                .gridColumnAlignment(.center)
                        }
                        GridRow {
                            Text("Value:")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)
                            
                            TextField("", text: $entry.value)
                                .multilineTextAlignment(.center)
                                .gridColumnAlignment(.center)
                                .onSubmit {
                                    Task {
                                        await save(entry: entry)
                                    }
                                }
                        }
                    }
                }
            }
            .onDelete { indexSet in
                deletionIndexSet = indexSet
            }
        }
        .task {
            await load()
        }
        .alert("Really delete", isPresented: shouldShowDeleteConfirmation) {
            Button(role: .destructive) {
                deletionIndexSet = nil
            } label: {
                Text("Yes")
            }
            
            Button(role: .cancel) {
                deletionIndexSet = nil
            } label: {
                Text("No")
            }
        }
        .navigationTitle("\(project.name): \(locale.code)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("", systemImage: "plus") {
                    print("add")
                }
            }
        }
    }
    
    var shouldShowDeleteConfirmation: Binding<Bool> {
        Binding {
            deletionIndexSet != nil
        } set: { flag in
            if !(flag) {
                deletionIndexSet = nil
            }
        }

    }
    
    func load() async {
        do {
            self.entries = try await apiService.getEntries(projectId: project.id, localeCode: locale.code)
        } catch {
            print(error)
        }
    }
    
    func save(entry: Entry) async {
        do {
            let updated = try await apiService.updateEntry(projectId: project.id, updateEntryDto: UpdateEntryDto(id: entry.id, value: entry.value))
            
            let i = entries.firstIndex { $0.id == entry.id }!
            entries[i] = entry.with(value: updated.value)
            
        } catch {
            print(error)
        }
    }
}

#Preview {
    NavigationStack {
        EditorView(project: Project(id: "1", name: "Recipes"), locale: LocaleInfo(id: "2", code: "en-US"), apiService: ApiServicePreview())
    }
}
