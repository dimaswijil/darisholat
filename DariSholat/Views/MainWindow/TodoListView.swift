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
    /// Not @ObservedObject on purpose — only the small HeaderEventsInfo
    /// subview observes it, so the board doesn't re-render every second.
    let viewModel: PrayerTimeViewModel
    /// Bound from the parent so the command palette can open a task's detail.
    @Binding var openItem: TodoItem?
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
                    board
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
            VStack(alignment: .leading, spacing: 8) {
                Text(lang == "id" ? "semua dimulai dari satu folder." : "everything starts with one folder.")
                    .font(Self.handFont(17))
                    .foregroundColor(.accentColor.opacity(0.85))

                Text(todoManager.folders.isEmpty
                     ? (lang == "id" ? "buat folder dulu dengan tombol + di atas ↑" : "make a folder first with the + above ↑")
                     : (lang == "id" ? "pilih folder di atas untuk mulai ↑" : "pick a folder above to begin ↑"))
                    .font(Self.handFont(12))
                    .foregroundColor(.accentColor.opacity(0.55))
                    .padding(.top, 13)
            }
            .padding(.horizontal, 34)
            .frame(width: proxy.size.width, alignment: .leading)
            .position(x: proxy.size.width / 2,
                      y: proxy.size.height * 0.382) // 1/φ² golden section
        }
    }

    // MARK: - Header (editorial: big serif title + soft subtitle)
    // Spacing follows Fibonacci tokens (5, 8, 13, 21, 34) for golden rhythm.

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.todo(lang))
                    .font(.system(size: 21, weight: .bold, design: .serif)) // 13 · φ
                    .foregroundColor(.primary)

                Text(subtitleText)
                    .font(Self.handFont(12))
                    .foregroundColor(.secondary.opacity(0.9))

                // Folder chips live right under the title — inside the left
                // column, so the taller events card can't push them down.
                folderBar
                    .padding(.top, 13)
            }

            Spacer(minLength: 21)

            // Hijri date + upcoming events fill the empty trailing space.
            HeaderEventsInfo(viewModel: viewModel, lang: lang)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 34)
        .padding(.top, 26)
        .padding(.bottom, 13)
    }

    private var subtitleText: String {
        lang == "id" ? "hal-hal kecil untuk hari ini." : "small things for today."
    }

    // MARK: - Folder Bar (switchable lists, like Notion pages)

    @State private var showNewFolderField = false
    @State private var newFolderName = ""
    @FocusState private var folderFieldFocused: Bool

    private var folderBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(todoManager.folders) { folder in
                    folderChip(id: folder.id, name: folder.name, icon: "folder")
                        .contextMenu {
                            Button(role: .destructive) {
                                todoManager.deleteFolder(folder)
                            } label: {
                                Label(lang == "id" ? "Hapus folder" : "Delete folder",
                                      systemImage: "trash")
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
    }

    @ViewBuilder
    private func folderChip(id: UUID?, name: String, icon: String) -> some View {
        let isSelected = todoManager.selectedFolderID == id
        let pending = todoManager.pendingCount(inFolder: id)

        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                // Tap the active chip again to go back to the default list.
                todoManager.selectedFolderID = isSelected ? nil : id
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(name)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
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
        }
        .buttonStyle(.plain)
    }

    private func commitNewFolder() {
        todoManager.addFolder(newFolderName)
        newFolderName = ""
        showNewFolderField = false
    }

    // MARK: - Daily Quote (handwritten, human touch)

    /// Rotates once per day; grug-style lowercase wisdom.
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

    /// Handwritten font with graceful fallback when Noteworthy is missing.
    static func handFont(_ size: CGFloat) -> Font {
        if NSFont(name: "Noteworthy-Light", size: size) != nil {
            return .custom("Noteworthy-Light", size: size)
        }
        return .system(size: size, weight: .regular, design: .rounded)
    }

    // MARK: - Input

    private var inputRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 15))
                .foregroundColor(.accentColor)

            TextField(L10n.addTask(lang), text: $newTaskText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused($inputFocused)
                .onSubmit(addTask)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(0.06))
        )
        .padding(.horizontal, 34)
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
        .padding(.horizontal, 34)
        .padding(.top, 21)
        .padding(.bottom, 13)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Empty State (handwritten daily wisdom, like a note on the desk)
    // Sits at the golden section (~38.2% down) and shares the same left
    // edge as the title/input for one clean reading column.

    private var emptyState: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 8) {
                ForEach(dailyQuote, id: \.self) { line in
                    Text(line)
                        .font(Self.handFont(17))
                        .foregroundColor(.accentColor.opacity(0.85))
                }

                Text(lang == "id" ? "tulis tugas pertamamu di atas ↑" : "write your first task above ↑")
                    .font(Self.handFont(12))
                    .foregroundColor(.accentColor.opacity(0.55))
                    .padding(.top, 21)
            }
            .padding(.horizontal, 34)
            .frame(width: proxy.size.width, alignment: .leading)
            .position(x: proxy.size.width / 2,
                      y: proxy.size.height * 0.382) // 1/φ² golden section
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Text(L10n.tasksPending(lang, count: todoManager.pendingCount(inFolder: todoManager.selectedFolderID)))
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            Spacer()

            if !todoManager.items(in: .done).isEmpty {
                Button(action: { todoManager.clearCompleted() }) {
                    Text(L10n.clearCompleted(lang))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 10)
    }
}

// MARK: - Status Presentation

extension TodoStatus {
    func title(_ lang: String) -> String {
        switch self {
        case .todo:       return lang == "id" ? "Belum" : "Todo"
        case .inProgress: return lang == "id" ? "Dikerjakan" : "In Progress"
        case .done:       return lang == "id" ? "Selesai" : "Done"
        }
    }

    var icon: String {
        switch self {
        case .todo:       return "circle.dashed"
        case .inProgress: return "circle.circle"
        case .done:       return "checkmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .todo:       return .secondary
        case .inProgress: return .orange
        case .done:       return .green
        }
    }

    /// A gentle handwritten whisper under each column title.
    func whisper(_ lang: String) -> String {
        switch self {
        case .todo:       return lang == "id" ? "nanti dulu, pelan-pelan" : "someday starts here"
        case .inProgress: return lang == "id" ? "sedang diusahakan…" : "rock is moving…"
        case .done:       return lang == "id" ? "alhamdulillah, beres" : "little victories"
        }
    }
}

// MARK: - Kanban Column

private struct KanbanColumn: View {
    let status: TodoStatus
    @ObservedObject var todoManager: TodoManager
    let lang: String
    let onOpen: (TodoItem) -> Void
    @State private var isDropTarget = false

    private var columnItems: [TodoItem] { todoManager.items(in: status) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Column header
            HStack(spacing: 6) {
                Image(systemName: status.icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(status.tint)
                Text(status.title(lang))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(columnItems.count)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 4)

            Text(status.whisper(lang))
                .font(TodoListView.handFont(11))
                .foregroundColor(.secondary.opacity(0.8))
                .padding(.horizontal, 4)
                .padding(.bottom, 2)

            // Cards
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(columnItems) { item in
                        KanbanCard(item: item, todoManager: todoManager, lang: lang, onOpen: onOpen)
                    }
                }
                .padding(2)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(isDropTarget ? 0.10 : 0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isDropTarget ? status.tint.opacity(0.6) : Color.clear,
                    style: StrokeStyle(lineWidth: 1.5, dash: [5])
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isDropTarget)
        .onDrop(of: [.plainText], isTargeted: $isDropTarget) { providers in
            guard let provider = providers.first else { return false }
            _ = provider.loadObject(ofClass: NSString.self) { object, _ in
                guard let idString = object as? String else { return }
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        todoManager.move(idString: idString, to: status)
                    }
                }
            }
            return true
        }
    }
}

// MARK: - Kanban Card

private struct KanbanCard: View {
    let item: TodoItem
    @ObservedObject var todoManager: TodoManager
    let lang: String
    let onOpen: (TodoItem) -> Void
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.system(size: 12))
                .foregroundColor(item.status == .done ? .secondary : .primary)
                .strikethrough(item.status == .done, color: .secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !item.notes.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 8))
                    Text(item.notes)
                        .lineLimit(1)
                }
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 6) {
                // Status chip (like Plane's "Backlog / In Progress" pills)
                HStack(spacing: 3) {
                    Image(systemName: item.status.icon)
                        .font(.system(size: 8))
                    Text(item.status.title(lang))
                        .font(.system(size: 9, weight: .medium))
                }
                .foregroundColor(item.status.tint)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.primary.opacity(0.06)))

                Spacer()

                if isHovered {
                    // Move left / right through the flow
                    if let prev = prevStatus {
                        moveButton("chevron.left", to: prev)
                    }
                    if let next = nextStatus {
                        moveButton("chevron.right", to: next)
                    }
                    Button(action: { todoManager.delete(item) }) {
                        Image(systemName: "trash")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(isHovered ? 0.10 : 0.06))
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.1), value: isHovered)
        .onTapGesture { onOpen(item) }
        .onDrag { NSItemProvider(object: item.id.uuidString as NSString) }
        .help(lang == "id" ? "Klik untuk detail · seret untuk memindahkan" : "Click for details · drag to move")
    }

    private var prevStatus: TodoStatus? {
        switch item.status {
        case .todo:       return nil
        case .inProgress: return .todo
        case .done:       return .inProgress
        }
    }

    private var nextStatus: TodoStatus? {
        switch item.status {
        case .todo:       return .inProgress
        case .inProgress: return .done
        case .done:       return nil
        }
    }

    private func moveButton(_ icon: String, to status: TodoStatus) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                todoManager.move(item, to: status)
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Task Detail (Notion-style page)

/// Opens when a card is clicked: cover strip, big serif title, status
/// switcher, and a free-form notes area — like a Notion doc.
private struct TaskDetailView: View {
    let item: TodoItem
    @ObservedObject var todoManager: TodoManager
    let lang: String
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var notes: String
    @State private var status: TodoStatus

    init(item: TodoItem, todoManager: TodoManager, lang: String) {
        self.item = item
        self.todoManager = todoManager
        self.lang = lang
        _title  = State(initialValue: item.title)
        _notes  = State(initialValue: item.notes)
        _status = State(initialValue: item.status)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover strip (Notion-like banner)
            LinearGradient(
                colors: [status.tint.opacity(0.55), status.tint.opacity(0.15)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 96)
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: status.icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white.opacity(0.35))
                    .padding(16)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title (big serif, like the page H1)
                    TextField(lang == "id" ? "Tanpa judul" : "Untitled",
                              text: $title, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(.primary)

                    // Status switcher (property row)
                    HStack(spacing: 10) {
                        Text(lang == "id" ? "Status" : "Status")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(width: 70, alignment: .leading)

                        HStack(spacing: 6) {
                            ForEach(TodoStatus.allCases) { s in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) { status = s }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: s.icon)
                                            .font(.system(size: 9))
                                        Text(s.title(lang))
                                            .font(.system(size: 10, weight: .medium))
                                    }
                                    .foregroundColor(status == s ? .white : s.tint)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule().fill(status == s ? s.tint.opacity(0.8)
                                                                    : Color.primary.opacity(0.06))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Divider().opacity(0.3)

                    // Notes (free-form body, handwritten placeholder for warmth)
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text(lang == "id" ? "tulis catatan, langkah, atau niatmu di sini…"
                                              : "write notes, steps, or your intention here…")
                                .font(TodoListView.handFont(15))
                                .foregroundColor(.secondary.opacity(0.7))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        TextEditor(text: $notes)
                            .font(.system(size: 14))
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 180, alignment: .top)
                    }
                }
                .padding(24)
            }

            Divider().opacity(0.3)

            // Footer actions
            HStack {
                Button(role: .destructive) {
                    todoManager.delete(item)
                    dismiss()
                } label: {
                    Label(lang == "id" ? "Hapus" : "Delete", systemImage: "trash")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundColor(.red.opacity(0.8))

                Spacer()

                Button(lang == "id" ? "Selesai" : "Done") { saveAndClose() }
                    .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(width: 460, height: 520)
        .background(.ultraThinMaterial)
        .onDisappear(perform: persist)
    }

    private func persist() {
        todoManager.update(item, title: title, notes: notes)
        todoManager.move(item, to: status)
    }

    private func saveAndClose() {
        persist()
        dismiss()
    }
}

// MARK: - Header Events Info (hijri date + upcoming events, right-aligned)

/// Compact glance card in the To-Doing header: hijri date on top, then
/// Ramadan countdown and the next couple of calendar events — mirroring the
/// menu bar popover's Events column.
private struct HeaderEventsInfo: View {
    @ObservedObject var viewModel: PrayerTimeViewModel
    let lang: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Hijri date header
            HStack(spacing: 5) {
                Image(systemName: "calendar")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.accentColor.opacity(0.9))
                Text(viewModel.currentHijriDate + (lang == "id" ? " H" : " AH"))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.9))
            }

            Divider().opacity(0.25)

            // Ramadan countdown
            infoRow(icon: "moon.stars.fill",
                    title: L10n.ramadan(lang),
                    value: viewModel.ramadanCountdownText)

            // Next up to 2 calendar events
            ForEach(viewModel.upcomingEvents.prefix(2)) { event in
                infoRow(icon: "calendar.badge.clock",
                        title: event.title,
                        value: event.countdownText(lang: lang))
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .frame(width: 233) // 144 · φ — fixed so rows align in one grid
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(0.05))
        )
    }

    /// Icon + title lead from the left, value trails right — one aligned grid.
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(.secondary.opacity(0.8))
                .frame(width: 12)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.primary.opacity(0.85))
                .monospacedDigit()
                .lineLimit(1)
        }
    }
}

// MARK: - Pending Badge

/// Capsule counter of unfinished tasks; observes TodoManager directly so it
/// re-renders exactly when todos change (used in popover row + window sidebar).
struct PendingBadge: View {
    @ObservedObject var todoManager: TodoManager

    var body: some View {
        if todoManager.pendingCount > 0 {
            Text("\(todoManager.pendingCount)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.accentColor.opacity(0.8)))
        }
    }
}
