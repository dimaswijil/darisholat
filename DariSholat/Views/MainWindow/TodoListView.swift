//
//  TodoListView.swift
//  DariSholat
//
//  Kanban board (Todo / In Progress / Done) shown in the desktop window.
//  Editorial header (big serif title + soft subtitle) and a daily
//  handwritten-style quote keep the human touch. Cards move between
//  columns via drag & drop or the arrow buttons on each card.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct TodoListView: View {
    @ObservedObject var todoManager: TodoManager
    let lang: String
    
    private var isRundownFolder: Bool {
        guard let folderID = todoManager.selectedFolderID,
              let folder = todoManager.folders.first(where: { $0.id == folderID }) else {
            return false
        }
        return folder.name.localizedCaseInsensitiveContains("rundown")
    }
    /// Not @ObservedObject on purpose — only the small HeaderEventsInfo
    /// subview observes it, so the board doesn't re-render every second.
    let viewModel: PrayerTimeViewModel
    /// Bound from the parent so the command palette can open a task's detail.
    @Binding var openItem: TodoItem?
    @ObservedObject var windowManager: MainWindowManager = .shared
    @State private var newTaskText = ""
    @State private var detailItem: TodoItem?
    @FocusState private var inputFocused: Bool

    /// Tasks require a folder: input only appears once a folder is selected.
    private var hasActiveFolder: Bool {
        todoManager.selectedFolderID != nil && !todoManager.folders.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if hasActiveFolder {
                inputRow

                if todoManager.currentItems.isEmpty {
                    emptyState
                } else {
                    if isRundownFolder {
                        rundownView
                    } else {
                        board
                    }
                }
            } else {
                noFolderState
            }

            Divider().opacity(0.35)
            footer
        }
        .sheet(item: $detailItem) { item in
            TaskDetailView(item: item, todoManager: todoManager, lang: lang)
        }
        .onChange(of: openItem) { newValue in
            guard let newValue else { return }
            // Jump to the task's folder so the detail opens in context.
            todoManager.selectedFolderID = newValue.folderID
            detailItem = newValue
            openItem = nil
        }
    }

    // MARK: - No Folder State (make a folder first, gently)

    private var noFolderState: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 8) {
                Text(lang == "id" ? "semua dimulai dari satu folder." : "everything starts with one folder.")
                    .font(Font.handFont(17))
                    .foregroundColor(.accentColor.opacity(0.85))

                Text(todoManager.folders.isEmpty
                     ? (lang == "id" ? "buat folder dulu dengan tombol + di atas ↑" : "make a folder first with the + above ↑")
                     : (lang == "id" ? "pilih folder di atas untuk mulai ↑" : "pick a folder above to begin ↑"))
                    .font(Font.handFont(12))
                    .foregroundColor(.accentColor.opacity(0.55))
                    .padding(.top, 13)
            }
            .multilineTextAlignment(.center)
            .frame(width: proxy.size.width)
            .position(x: proxy.size.width / 2,
                      y: proxy.size.height * 0.382) // 1/φ² golden section
        }
    }

    // MARK: - Header (editorial: big serif title + soft subtitle)

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.todo(lang))
                    .font(.system(size: 21, weight: .bold, design: .serif))
                    .foregroundColor(.primary)

                Text(subtitleText)
                    .font(Font.handFont(12))
                    .foregroundColor(.secondary.opacity(0.9))

                folderBar
                    .padding(.top, 13)
            }

            Spacer(minLength: 21)

            HeaderEventsInfo(viewModel: viewModel, lang: lang)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, windowManager.sidebarVisible ? 21 : 55)
        .padding(.trailing, 21)
        .padding(.top, 24)      // clears macOS traffic lights & aligns with sidebar
        .padding(.bottom, 13)
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: windowManager.sidebarVisible)
    }

    private var subtitleText: String {
        lang == "id" ? "hal-hal kecil untuk hari ini." : "small things for today."
    }

    // MARK: - Folder Bar (switchable lists, like Notion pages)

    @State private var showNewFolderField = false
    @State private var newFolderName = ""
    @FocusState private var folderFieldFocused: Bool
    @State private var renamingFolderID: UUID?
    @State private var renameFolderName = ""
    @FocusState private var renameFieldFocused: Bool
    @State private var folderBarContentWidth: CGFloat = 0
    @State private var folderBarVisibleWidth: CGFloat = 0

    private var folderBarOverflows: Bool {
        folderBarContentWidth > folderBarVisibleWidth + 1
    }

    private var folderBar: some View {
        HStack(spacing: 4) {
            ScrollView(.horizontal, showsIndicators: false) {
                folderBarContent
                    .background(
                        GeometryReader { proxy in
                            Color.clear.onAppear { folderBarContentWidth = proxy.size.width }
                                .onChange(of: proxy.size.width) { folderBarContentWidth = $0 }
                        }
                    )
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear { folderBarVisibleWidth = proxy.size.width }
                        .onChange(of: proxy.size.width) { folderBarVisibleWidth = $0 }
                }
            )

            if folderBarOverflows {
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: folderBarOverflows)
    }

    private var folderBarContent: some View {
        HStack(spacing: 8) {
            ForEach(todoManager.folders) { folder in
                if renamingFolderID == folder.id {
                    HStack(spacing: 5) {
                        Image(systemName: "folder")
                            .font(.system(size: 10))
                            .foregroundColor(.accentColor)
                        TextField("", text: $renameFolderName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                            .frame(width: 110)
                            .focused($renameFieldFocused)
                            .onSubmit { commitRename(folder) }
                            .onExitCommand { renamingFolderID = nil }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.primary.opacity(0.08)))
                } else {
                    folderChip(id: folder.id, name: folder.name, icon: "folder")
                        .onDrag { NSItemProvider(object: folder.id.uuidString as NSString) }
                        .onDrop(of: [.plainText], isTargeted: nil) { providers in
                            guard let provider = providers.first else { return false }
                            _ = provider.loadObject(ofClass: NSString.self) { object, _ in
                                guard let idString = object as? String else { return }
                                DispatchQueue.main.async {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        todoManager.moveFolder(idString: idString, before: folder)
                                    }
                                }
                            }
                            return true
                        }
                        .contextMenu {
                            Button {
                                renameFolderName = folder.name
                                renamingFolderID = folder.id
                                renameFieldFocused = true
                            } label: {
                                Label(lang == "id" ? "Ganti nama" : "Rename",
                                      systemImage: "pencil")
                            }
                            Divider()
                            Button(role: .destructive) {
                                todoManager.deleteFolder(folder)
                            } label: {
                                Label(lang == "id" ? "Hapus folder" : "Delete folder",
                                      systemImage: "trash")
                            }
                        }
                }
            }

            // New folder
            if showNewFolderField {
                HStack(spacing: 5) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 10))
                        .foregroundColor(.accentColor)
                    TextField(lang == "id" ? "Nama folder…" : "Folder name…",
                              text: $newFolderName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .frame(width: 110)
                        .focused($folderFieldFocused)
                        .onSubmit(commitNewFolder)
                        .onExitCommand {
                            showNewFolderField = false
                            newFolderName = ""
                        }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.primary.opacity(0.08)))
            } else {
                Button {
                    showNewFolderField = true
                    folderFieldFocused = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.primary.opacity(0.06)))
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .help(lang == "id" ? "Folder baru" : "New folder")
            }
        }
    }

    @ViewBuilder
    private func folderChip(id: UUID?, name: String, icon: String) -> some View {
        let isSelected = todoManager.selectedFolderID == id
        let pending = todoManager.pendingCount(inFolder: id)

        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(name)
                .font(.system(size: 12))
                .lineLimit(1)
            if pending > 0 {
                Text("\(pending)")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
            }
        }
        .foregroundColor(isSelected ? .white : .primary.opacity(0.8))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(isSelected ? Color.accentColor.opacity(0.4)
                                      : Color.primary.opacity(0.06))
        )
        .contentShape(Capsule())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                todoManager.selectedFolderID = isSelected ? nil : id
            }
        }
    }

    private func commitNewFolder() {
        todoManager.addFolder(newFolderName)
        newFolderName = ""
        showNewFolderField = false
    }

    private func commitRename(_ folder: TodoFolder) {
        todoManager.renameFolder(folder, to: renameFolderName)
        renamingFolderID = nil
        renameFolderName = ""
    }

    // MARK: - Daily Quote (handwritten, human touch)

    private var dailyQuote: [String] {
        let en: [[String]] = [
            ["sun rise every day.", "grug share one small wisdom.", "help move today rock.", "tiny step still step forward."],
            ["one task at a time.", "that is how mountains move."],
            ["done is prettier than perfect.", "start the ugly first draft."],
            ["water wears the stone.", "keep going, gently."],
            ["pray first, then begin.", "small deeds, done often."],
        ]
        let id: [[String]] = [
            ["matahari terbit tiap hari.", "langkah kecil tetap langkah maju.", "bantu pindahkan batu hari ini."],
            ["sedikit demi sedikit,", "lama-lama menjadi bukit."],
            ["selesai itu lebih indah", "daripada sempurna."],
            ["air menetes melubangi batu.", "pelan-pelan saja."],
            ["awali dengan doa,", "amal kecil yang rutin itu berkah."],
        ]
        let pool = lang == "id" ? id : en
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return pool[day % pool.count]
    }

    // MARK: - Input

    private var inputRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 15))
                .foregroundColor(.accentColor)

            ZStack(alignment: .leading) {
                if newTaskText.isEmpty {
                    Text(L10n.addTask(lang))
                        .font(Font.handFont(11))
                        .foregroundColor(.secondary.opacity(0.7))
                        .allowsHitTesting(false)
                }
                TextField("", text: $newTaskText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .focused($inputFocused)
                    .onSubmit(addTask)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(0.06))
        )
        .padding(.horizontal, 21)
    }

    private func addTask() {
        todoManager.add(newTaskText)
        newTaskText = ""
        inputFocused = true
    }

    // MARK: - Kanban Board

    private var board: some View {
        HStack(alignment: .top, spacing: 13) {
            KanbanColumn(status: .todo, todoManager: todoManager, lang: lang, onOpen: { detailItem = $0 })
            KanbanColumn(status: .inProgress, todoManager: todoManager, lang: lang, onOpen: { detailItem = $0 })
            KanbanColumn(status: .done, todoManager: todoManager, lang: lang, onOpen: { detailItem = $0 })
        }
        .padding(.horizontal, 21)
        .padding(.top, 21)
        .padding(.bottom, 13)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 8) {
                ForEach(dailyQuote, id: \.self) { line in
                    Text(line)
                        .font(Font.handFont(17))
                        .foregroundColor(.accentColor.opacity(0.85))
                }

                Text(lang == "id" ? "tulis tugas pertamamu di atas ↑" : "write your first task above ↑")
                    .font(Font.handFont(12))
                    .foregroundColor(.accentColor.opacity(0.55))
                    .padding(.top, 21)
            }
            .multilineTextAlignment(.center)
            .frame(width: proxy.size.width)
            .position(x: proxy.size.width / 2,
                      y: proxy.size.height * 0.382)
        }
    }

    // MARK: - Rundown View

    private var rundownView: some View {
        RundownTableView(
            todoManager: todoManager,
            lang: lang,
            windowManager: windowManager,
            onOpenDetail: { detailItem = $0 }
        )
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Text(L10n.tasksPending(lang, count: todoManager.pendingCount(inFolder: todoManager.selectedFolderID)))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 21)
        .padding(.vertical, 10)
    }
}
