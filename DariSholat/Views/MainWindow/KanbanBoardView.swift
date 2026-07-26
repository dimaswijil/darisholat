//
//  KanbanBoardView.swift
//  DariSholat
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

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

// MARK: - Priority Presentation

extension TodoPriority {
    var color: Color {
        switch self {
        case .low:    return .secondary
        case .medium: return .orange
        case .high:   return .red
        }
    }
}

// MARK: - Kanban Column

struct KanbanColumn: View {
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

            // Handwritten whisper below the title, tinted with the accent
            Text(status.whisper(lang))
                .font(Font.handFont(11))
                .foregroundColor(.accentColor.opacity(0.7))
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

struct KanbanCard: View {
    let item: TodoItem
    @ObservedObject var todoManager: TodoManager
    let lang: String
    let onOpen: (TodoItem) -> Void
    @State private var isHovered = false
    @State private var isDropTarget = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 6) {
                if let emoji = item.emojiIcon, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: 13))
                }
                Text(item.title)
                    .font(.system(size: 12))
                    .foregroundColor(item.status == .done ? .secondary : .primary)
                    .strikethrough(item.status == .done, color: .secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
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
                // Priority chip (Notion-style, fixed width to prevent wrapping)
                HStack(spacing: 3) {
                    Image(systemName: item.priority.icon)
                        .font(.system(size: 7))
                    Text(item.priority.title(lang))
                        .font(.system(size: 9, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundColor(item.priority == .low ? .secondary : item.priority.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(item.priority == .low ? Color.primary.opacity(0.06) : item.priority.color.opacity(0.12))
                )
                .fixedSize(horizontal: true, vertical: true)
                .layoutPriority(1)

                Spacer(minLength: 4)

                HStack(spacing: 5) {
                    // Vertical reorder buttons (up / down within column)
                    if todoManager.canMoveUp(item) {
                        reorderButton("chevron.up") { todoManager.moveUp(item) }
                    }
                    if todoManager.canMoveDown(item) {
                        reorderButton("chevron.down") { todoManager.moveDown(item) }
                    }

                    // Move left / right through status flow
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
                .opacity(isHovered ? 1.0 : 0.0)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(isDropTarget ? 0.12 : (isHovered ? 0.10 : 0.06)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    isDropTarget ? Color.accentColor.opacity(0.6) : Color.clear,
                    style: StrokeStyle(lineWidth: 1.5, dash: [4])
                )
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.1), value: isHovered)
        .animation(.easeInOut(duration: 0.15), value: isDropTarget)
        .onTapGesture { onOpen(item) }
        .onDrag { NSItemProvider(object: item.id.uuidString as NSString) }
        .onDrop(of: [.plainText], isTargeted: $isDropTarget) { providers in
            guard let provider = providers.first else { return false }
            _ = provider.loadObject(ofClass: NSString.self) { object, _ in
                guard let idString = object as? String else { return }
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        todoManager.reorder(idString: idString, relativeTo: item)
                    }
                }
            }
            return true
        }
        .contextMenu {
            if todoManager.canMoveUp(item) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { todoManager.moveUp(item) }
                } label: {
                    Label(lang == "id" ? "Pindahkan ke atas" : "Move up", systemImage: "chevron.up")
                }
            }
            if todoManager.canMoveDown(item) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { todoManager.moveDown(item) }
                } label: {
                    Label(lang == "id" ? "Pindahkan ke bawah" : "Move down", systemImage: "chevron.down")
                }
            }
            Divider()
            Button(role: .destructive) {
                todoManager.delete(item)
            } label: {
                Label(lang == "id" ? "Hapus tugas" : "Delete task", systemImage: "trash")
            }
        }
        .help(lang == "id" ? "Klik untuk detail · seret ke kartu lain untuk mengurutkan" : "Click for details · drag to another card to reorder")
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

    private func reorderButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
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
