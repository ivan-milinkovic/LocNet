import SwiftUI

struct EditorView: View {
    
    let project: Project
    let apiService: ApiService
    
    @State var entriesGroupByLocale: [String: [Entry]] = [:]
    @State var localeEntries: [Entry] = []
    @State var locales: [String] = []
    @State var selectedLocale: String = ""
    @State var selectedEntryId: String?
    
    @State var showsNewKeyModal = false
    @State var newKeyName = ""
    
    @State var showsDeleteKeyConfirmation = false
    @State var deleteKeyName = ""
    @State var deleteKeyId = ""
    
    @State var isSaving = false
    
    @FocusState<String?> var focusState
    
    let entrySortFunction: (Entry, Entry) -> Bool = { e1, e2 in
        e1.key <= e2.key
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            localePickerView
            entriesView
        }
        .navigationTitle("Project: \(project.name)")
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                toolbarItems
            }
        }
        .task {
            await load()
        }
        .onChange(of: selectedLocale) { oldValue, newValue in
            updateEntries()
        }
        .sheet(isPresented: $showsNewKeyModal) {
            createKeyForm
        }
        .alert("This action will delete the key across all locales in the project! Are you sure? \n\n Key: \(deleteKeyName)", isPresented: $showsDeleteKeyConfirmation) {
            Button("Delete", role: .destructive) {
                Task { await deleteKey() }
            }
            Button("Cancel", role: .cancel) {
                resetKeyDeletionFields()
            }
        }
    }
    
    @ViewBuilder var localePickerView: some View {
        Picker("Locale", selection: $selectedLocale){
            ForEach(locales, id: \.self) { locale in
                Button(locale) {
                    selectedLocale = locale
                }
            }
        }
        .frame(width: 200)
        .padding([.leading, .trailing])
        .padding([.top, .bottom], 4)
    }
    
    @ViewBuilder var entriesView: some View {
        Table($localeEntries, selection: $selectedEntryId) {
            TableColumn("key") { $entry in
                Text(entry.key)
                    .frame(maxWidth: .infinity, alignment: .leading) // strech it so that the whole row is clickable
                    .contentShape(Rectangle()) // make empty space clickable
                    .contextMenu {
                        Button("Delete key: \(entry.key)") {
                            prepareToDeleteKey(keyId: entry.keyId, keyName: entry.key)
                        }
                    }
            }
            TableColumn("value") { $entry in
                TextField("", text: $entry.value, onCommit: {
                    Task {
                        await updateEntry(entry)
                    }
                })
                .focused($focusState, equals: entry.id)
            }
        }
        .disabled(isSaving)
    }
    
    func prepareToDeleteKey(keyId: String, keyName: String) {
        deleteKeyId = keyId
        deleteKeyName = keyName
        showsDeleteKeyConfirmation = true
    }
    
    @ViewBuilder var toolbarItems: some View {
        Button("Add Key", systemImage: "plus") {
            showsNewKeyModal = true
        }
        Button("Delete Key", systemImage: "minus") {
            guard let entry = localeEntries.first(where: { $0.id == selectedEntryId }) else { return }
            prepareToDeleteKey(keyId: entry.keyId, keyName: entry.key)
        }
        Button("Refresh", systemImage: "arrow.trianglehead.clockwise") {
            Task { await load() }
        }
    }
    
    @ViewBuilder var createKeyForm: some View {
        VStack {
            TextField("key name", text: $newKeyName)
                .autocorrectionDisabled()
                .onSubmit {
                    Task { await createNewKey() }
                }
            Button("Create", role: .none) {
                Task { await createNewKey() }
            }
            Button("Cancel", role: .cancel) {
                showsNewKeyModal = false
                newKeyName = ""
            }
        }
        .frame(minWidth: 100, maxWidth: 300)
        .padding()
    }
    
    func load() async {
        do {
            entriesGroupByLocale = try await apiService.loadEntriesGroupedByLocale(projectId: project.id)
            locales = entriesGroupByLocale.keys.sorted()
            if selectedLocale.isEmpty {
                selectedLocale = locales.first ?? ""
            } else {
                updateEntries()
            }
        } catch {
            print(error)
        }
    }
    
    fileprivate func updateEntries() {
        localeEntries = entriesGroupByLocale[selectedLocale]?.sorted(by: entrySortFunction) ?? []
        selectedEntryId = nil
    }
    
    func updateEntry(_ entry: Entry) async {
        Task {
            isSaving = true
            defer { isSaving = false }
            do {
                let entryRequestDto = UpdateEntryDto(id: entry.id, value: entry.value)
                let entryResponse = try await apiService.updateEntry(projectId: project.id, entryDto: entryRequestDto)
                updateLocalModel(oldEntry: entry, entryResponse: entryResponse)
            } catch {
                print(error)
            }
        }
    }
    
    // Need to update the model explicitly as structs are copied, not referenced
    func updateLocalModel(oldEntry: Entry, entryResponse: UpdateEntryDto) {
        var updatedEntry = oldEntry
        updatedEntry.value = entryResponse.value
        
        guard let indexOfEntry2 = localeEntries.firstIndex(where: { $0.id == entryResponse.id }) else { return }
        localeEntries[indexOfEntry2] = updatedEntry
        
        var locEntries = entriesGroupByLocale[selectedLocale] ?? []
        guard let indexOfEntry2 = locEntries.firstIndex(where: { $0.id == entryResponse.id }) else { return }
        locEntries[indexOfEntry2] = updatedEntry
        entriesGroupByLocale[selectedLocale] = locEntries
    }
    
    func createNewKey() async {
        if newKeyName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            return
        }
        
        do {
            try await apiService.createKey(projectId: project.id, name: newKeyName)
        } catch {
            print(error)
        }
        
        showsNewKeyModal = false
        newKeyName = ""
        
        await load()
    }
    
    func deleteKey() async {
        do {
            try await apiService.deleteKey(projectId: project.id, keyId: deleteKeyId)
        } catch {
            print(error)
        }
        resetKeyDeletionFields()
        await load()
    }
    
    func resetKeyDeletionFields() {
        showsDeleteKeyConfirmation = false
        deleteKeyName = ""
        deleteKeyId = ""
    }
}

//#Preview {
//    EntriesView()
//}
