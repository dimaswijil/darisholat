//
//  TodoManager.swift
//  DariSholat
//
//  Kanban-style to-do list: tasks flow through todo → in progress → done.
//  Persisted to UserDefaults as JSON. Shown in the desktop window and
//  auto-surfaced after wake-from-sleep when tasks are still pending.
//

import Foundation
import Combine

// MARK: - Status (kanban column)

enum TodoStatus: String, Codable, CaseIterable, Identifiable {
    case todo
    case inProgress
    case done

    var id: String { rawValue }
}

// MARK: - Folder (a list of tasks, switchable like Notion pages)

struct TodoFolder: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    let createdAt: Date

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}

// MARK: - Item

struct TodoItem: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var notes: String
    var status: TodoStatus
    var folderID: UUID?
    let createdAt: Date

    init(title: String, status: TodoStatus = .todo, folderID: UUID? = nil) {
        self.id = UUID()
        self.title = title
        self.notes = ""
        self.status = status
        self.folderID = folderID
        self.createdAt = Date()
    }

    // Backward compatible decoding: earlier versions stored `isDone: Bool`
    // and had no `notes` / `folderID`.
    private enum CodingKeys: String, CodingKey {
        case id, title, notes, status, folderID, createdAt, isDone
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id        = try c.decode(UUID.self, forKey: .id)
        title     = try c.decode(String.self, forKey: .title)
        notes     = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        folderID  = try c.decodeIfPresent(UUID.self, forKey: .folderID)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        if let s = try c.decodeIfPresent(TodoStatus.self, forKey: .status) {
            status = s
        } else {
            let done = try c.decodeIfPresent(Bool.self, forKey: .isDone) ?? false
            status = done ? .done : .todo
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(notes, forKey: .notes)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(folderID, forKey: .folderID)
        try c.encode(createdAt, forKey: .createdAt)
    }
}

// MARK: - Manager

class TodoManager: ObservableObject {

    @Published private(set) var items: [TodoItem] = []
    @Published private(set) var folders: [TodoFolder] = []
    /// nil = "Inbox" (tasks with no folder).
    @Published var selectedFolderID: UUID? {
        didSet {
            defaults.set(selectedFolderID?.uuidString ?? "", forKey: selectedFolderKey)
        }
    }

    private let defaults = UserDefaults.standard
    private let storageKey = "todoItems"
    private let foldersKey = "todoFolders"
    private let selectedFolderKey = "todoSelectedFolder"

    init() {
        load()
    }

    // MARK: - Derived State

    /// Anything not yet done keeps the badge alive and triggers the wake window.
    var pendingCount: Int {
        items.reduce(0) { $1.status == .done ? $0 : $0 + 1 }
    }

    var hasPendingTasks: Bool {
        items.contains { $0.status != .done }
    }

    /// Tasks in the currently selected folder (nil folder = Inbox).
    var currentItems: [TodoItem] {
        items.filter { $0.folderID == selectedFolderID }
    }

    func items(in status: TodoStatus) -> [TodoItem] {
        currentItems.filter { $0.status == status }
    }

    /// Pending count per folder for the folder chips (nil = Inbox).
    func pendingCount(inFolder folderID: UUID?) -> Int {
        items.reduce(0) { ($1.folderID == folderID && $1.status != .done) ? $0 + 1 : $0 }
    }

    // MARK: - Folder Mutations

    func addFolder(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let folder = TodoFolder(name: trimmed)
        folders.append(folder)
        selectedFolderID = folder.id
        saveFolders()
    }

    func renameFolder(_ folder: TodoFolder, to name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let idx = folders.firstIndex(where: { $0.id == folder.id }) else { return }
        folders[idx].name = trimmed
        saveFolders()
    }

    /// Deletes the folder; its tasks fall back to Inbox (folderID = nil).
    func deleteFolder(_ folder: TodoFolder) {
        folders.removeAll { $0.id == folder.id }
        for idx in items.indices where items[idx].folderID == folder.id {
            items[idx].folderID = nil
        }
        if selectedFolderID == folder.id { selectedFolderID = nil }
        saveFolders()
        save()
    }

    // MARK: - Mutations

    /// Adds into the currently selected folder. Tasks always live in a
    /// folder: with none selected (e.g. via the command palette on a fresh
    /// start), fall back to the first folder or create a default one.
    func add(_ title: String, status: TodoStatus = .todo) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if selectedFolderID == nil {
            if let first = folders.first {
                selectedFolderID = first.id
            } else {
                let folder = TodoFolder(name: "Tasks")
                folders.append(folder)
                selectedFolderID = folder.id
                saveFolders()
            }
        }

        items.insert(TodoItem(title: trimmed, status: status, folderID: selectedFolderID), at: 0)
        save()
    }

    /// Moves a task to another kanban column (drag & drop or menu).
    func move(_ item: TodoItem, to status: TodoStatus) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }),
              items[idx].status != status else { return }
        items[idx].status = status
        save()
    }

    /// Moves by id string (drag & drop payload).
    func move(idString: String, to status: TodoStatus) {
        guard let uuid = UUID(uuidString: idString),
              let item = items.first(where: { $0.id == uuid }) else { return }
        move(item, to: status)
    }

    /// Quick check/uncheck: done ↔ todo.
    func toggle(_ item: TodoItem) {
        move(item, to: item.status == .done ? .todo : .done)
    }

    /// Edits title/notes from the detail sheet.
    func update(_ item: TodoItem, title: String, notes: String) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        items[idx].title = trimmed.isEmpty ? items[idx].title : trimmed
        items[idx].notes = notes
        save()
    }

    func delete(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func clearCompleted() {
        items.removeAll { $0.status == .done && $0.folderID == selectedFolderID }
        save()
    }

    /// Moves a task into another folder (nil = Inbox).
    func moveToFolder(_ item: TodoItem, folderID: UUID?) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].folderID = folderID
        save()
    }

    // MARK: - Persistence

    private func load() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            items = decoded
        } else {
            items = []
        }

        if let data = defaults.data(forKey: foldersKey),
           let decoded = try? JSONDecoder().decode([TodoFolder].self, from: data) {
            folders = decoded
        } else {
            folders = []
        }

        // Restore selection; fall back to Inbox if the folder is gone.
        if let raw = defaults.string(forKey: selectedFolderKey),
           let uuid = UUID(uuidString: raw),
           folders.contains(where: { $0.id == uuid }) {
            selectedFolderID = uuid
        } else {
            selectedFolderID = nil
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func saveFolders() {
        guard let data = try? JSONEncoder().encode(folders) else { return }
        defaults.set(data, forKey: foldersKey)
    }
}
