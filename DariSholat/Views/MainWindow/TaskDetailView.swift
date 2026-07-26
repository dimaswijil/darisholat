//
//  TaskDetailView.swift
//  DariSholat
//

import SwiftUI

// MARK: - Task Detail (Notion-style page)

/// Opens when a card is clicked: cover banner (wallpaper or gradient), overlapping emoji page icon,
/// properties table (Status, Folder, Priority, Time, Duration, Location, Date Created), and a free-form notes area.
struct TaskDetailView: View {
    let item: TodoItem
    @ObservedObject var todoManager: TodoManager
    let lang: String
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var notes: String
    @State private var status: TodoStatus
    @State private var folderID: UUID?
    @State private var emojiIcon: String?
    @State private var coverImageName: String?
    @State private var priority: TodoPriority
    @State private var timeRange: String
    @State private var duration: String
    @State private var location: String

    @State private var isHoveringCover = false
    @State private var showEmojiPicker = false

    private let wallpapers = ["None", "AboutWallpaper", "EventWallpaper1", "EventWallpaper2", "EventWallpaper3"]
    private let emojis = ["🎯", "📝", "💡", "🚀", "📅", "💻", "☕️", "🔥", "📖", "🕌", "🤲", "🌟", "🛠", "🎨", "💭"]

    init(item: TodoItem, todoManager: TodoManager, lang: String) {
        self.item = item
        self.todoManager = todoManager
        self.lang = lang
        _title  = State(initialValue: item.title)
        _notes  = State(initialValue: item.notes)
        _status = State(initialValue: item.status)
        _folderID = State(initialValue: item.folderID)
        _emojiIcon = State(initialValue: item.emojiIcon)
        _coverImageName = State(initialValue: item.coverImageName)
        _priority = State(initialValue: item.priority)
        _timeRange = State(initialValue: item.timeRange ?? "")
        _duration = State(initialValue: item.duration ?? "")
        _location = State(initialValue: item.location ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover banner & Overlapping Emoji Icon
            ZStack(alignment: .bottomLeading) {
                coverView
                    .onHover { isHoveringCover = $0 }
                
                emojiButton
                    .offset(x: 24, y: 24)
                    .zIndex(2)
            }
            .frame(height: 110)
            
            Spacer().frame(height: 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title (big serif, like the page H1)
                    TextField(lang == "id" ? "Tanpa judul" : "Untitled",
                              text: $title, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                        .padding(.top, 4)

                    // Properties Grid (Notion-style)
                    propertiesSection
                        .padding(.vertical, 8)

                    Divider().opacity(0.3)

                    // Notes (free-form body, handwritten placeholder for warmth)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lang == "id" ? "Catatan & Deskripsi" : "Notes & Description")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text(lang == "id" ? "tulis catatan, langkah, atau niatmu di sini…"
                                                  : "write notes, steps, or your intention here…")
                                    .font(Font.handFont(15))
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
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
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
        .frame(width: 480, height: 600)
        .background(.ultraThinMaterial)
        .onDisappear(perform: persist)
    }

    // MARK: - Views

    private var coverView: some View {
        Group {
            if let coverName = coverImageName, coverName != "None" {
                Image(coverName)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [status.tint.opacity(0.55), status.tint.opacity(0.15)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
        }
        .frame(height: 110)
        .clipped()
        .overlay(alignment: .bottomTrailing) {
            if isHoveringCover {
                Menu {
                    Button(lang == "id" ? "Tanpa Cover" : "No Cover") {
                        coverImageName = "None"
                    }
                    ForEach(["AboutWallpaper", "EventWallpaper1", "EventWallpaper2", "EventWallpaper3"], id: \.self) { wallpaper in
                        Button(action: {
                            coverImageName = wallpaper
                        }) {
                            Text(wallpaperName(wallpaper))
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.system(size: 10))
                        Text(lang == "id" ? "Ganti Cover" : "Change cover")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .menuStyle(.borderlessButton)
                .padding(12)
                .transition(.opacity)
            }
        }
    }

    private var emojiButton: some View {
        Button {
            showEmojiPicker = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                
                Circle()
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    .frame(width: 56, height: 56)
                
                if let emoji = emojiIcon, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: 28))
                } else {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showEmojiPicker, arrowEdge: .bottom) {
            VStack(spacing: 8) {
                Text(lang == "id" ? "Pilih Ikon" : "Select Icon")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(30), spacing: 6), count: 5), spacing: 6) {
                    Button {
                        emojiIcon = nil
                        showEmojiPicker = false
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)

                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            emojiIcon = emoji
                            showEmojiPicker = false
                        } label: {
                            Text(emoji)
                                .font(.system(size: 20))
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(10)
        }
    }

    private var propertiesSection: some View {
        VStack(spacing: 6) {
            // Status Property
            propertyRow(icon: status.icon, label: lang == "id" ? "Status" : "Status") {
                Menu {
                    ForEach(TodoStatus.allCases) { s in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) { status = s }
                        } label: {
                            Label(s.title(lang), systemImage: s.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: status.icon)
                            .font(.system(size: 8))
                        Text(status.title(lang))
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(status == .todo ? .primary : .white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(status.tint.opacity(status == .todo ? 0.12 : 0.85)))
                }
                .buttonStyle(.plain)
            }
            
            // Folder Property
            propertyRow(icon: "folder", label: lang == "id" ? "Folder" : "Folder") {
                Menu {
                    Button(lang == "id" ? "Inbox (Tanpa Folder)" : "Inbox (No Folder)") {
                        folderID = nil
                    }
                    ForEach(todoManager.folders) { f in
                        Button(f.name) {
                            folderID = f.id
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "folder")
                            .font(.system(size: 8))
                        Text(todoManager.folders.first(where: { $0.id == folderID })?.name ?? (lang == "id" ? "Inbox" : "Inbox"))
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(RoundedRectangle(cornerRadius: 4).fill(Color.primary.opacity(0.08)))
                }
                .buttonStyle(.plain)
            }
            
            // Priority Property
            propertyRow(icon: "tag", label: lang == "id" ? "Prioritas" : "Priority") {
                Menu {
                    ForEach(TodoPriority.allCases) { p in
                        Button {
                            priority = p
                        } label: {
                            Label(p.title(lang), systemImage: p.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: priority.icon)
                            .font(.system(size: 8))
                        Text(priority.title(lang))
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(priority == .low ? .secondary : priority.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(priority == .low ? Color.primary.opacity(0.08) : priority.color.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
            }

            // Time Property (Waktu)
            propertyRow(icon: "clock", label: lang == "id" ? "Waktu" : "Time") {
                TextField(lang == "id" ? "Pilih waktu" : "Set time", text: $timeRange)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
            }
            
            // Duration Property (Durasi)
            propertyRow(icon: "hourglass", label: lang == "id" ? "Durasi" : "Duration") {
                TextField(lang == "id" ? "Durasi" : "Duration", text: $duration)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
            }
            
            // Location Property (Tempat)
            propertyRow(icon: "mappin.and.ellipse", label: lang == "id" ? "Tempat" : "Location") {
                TextField(lang == "id" ? "Tempat" : "Location", text: $location)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
            }
            
            // Created Date Property
            propertyRow(icon: "calendar", label: lang == "id" ? "Dibuat" : "Created") {
                Text(formattedDate(item.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
    }

    private func propertyRow<Content: View>(icon: String, label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .frame(width: 14)
                Text(label)
                    .font(.system(size: 12))
            }
            .foregroundColor(.secondary)
            .frame(width: 110, alignment: .leading)
            
            content()
            Spacer()
        }
        .frame(height: 28)
    }

    // MARK: - Helpers

    private func wallpaperName(_ name: String) -> String {
        switch name {
        case "AboutWallpaper": return lang == "id" ? "Sajadah Biru" : "Blue Rug"
        case "EventWallpaper1": return lang == "id" ? "Kuburan Baqi" : "Baqi Cemetery"
        case "EventWallpaper2": return lang == "id" ? "Kubah Hijau" : "Green Dome"
        case "EventWallpaper3": return lang == "id" ? "Masjid Nabawi" : "Nabawi Mosque"
        default: return name
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: lang)
        return formatter.string(from: date)
    }

    private func persist() {
        todoManager.update(
            item,
            title: title,
            notes: notes,
            status: status,
            folderID: folderID,
            emojiIcon: emojiIcon,
            coverImageName: coverImageName,
            priority: priority,
            timeRange: timeRange.isEmpty ? nil : timeRange,
            duration: duration.isEmpty ? nil : duration,
            location: location.isEmpty ? nil : location
        )
    }

    private func saveAndClose() {
        persist()
        dismiss()
    }
}
