//
//  RundownTableView.swift
//  DariSholat
//

import SwiftUI
import AppKit

// MARK: - Rundown Table View

/// Spreadsheet-style table view for event rundown planning.
struct RundownTableView: View {
    @ObservedObject var todoManager: TodoManager
    let lang: String
    @ObservedObject var windowManager: MainWindowManager
    let onOpenDetail: (TodoItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Table Header
            HStack(spacing: 0) {
                Text(lang == "id" ? "Waktu" : "Time")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 90, alignment: .leading)
                    .padding(.leading, 8)
                
                Divider().frame(height: 20)
                
                Text(lang == "id" ? "Durasi" : "Duration")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                    .padding(.leading, 8)
                
                Divider().frame(height: 20)
                
                Text(lang == "id" ? "Kegiatan" : "Activity")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 150, alignment: .leading)
                    .padding(.leading, 8)
                
                Divider().frame(height: 20)
                
                Text(lang == "id" ? "Detail Acara" : "Event Detail")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                
                Divider().frame(height: 20)
                
                Text(lang == "id" ? "Tempat" : "Location")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 130, alignment: .leading)
                    .padding(.leading, 8)
                
                Divider().frame(height: 20)
                
                Text(lang == "id" ? "Status" : "Status")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                    .padding(.leading, 8)
                
                Divider().frame(height: 20)
                
                Text("").frame(width: 70) // Actions column
            }
            .frame(height: 32)
            .background(Color.primary.opacity(0.04))
            
            Divider()
            
            // Table Rows
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    ForEach(todoManager.currentItems) { item in
                        RundownRowView(item: item, todoManager: todoManager, lang: lang, onOpenDetail: onOpenDetail)
                        Divider()
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal, windowManager.sidebarVisible ? 21 : 55)
        .padding(.top, 13)
        .padding(.bottom, 21)
    }
}

// MARK: - Rundown Row View

struct RundownRowView: View {
    let item: TodoItem
    @ObservedObject var todoManager: TodoManager
    let lang: String
    let onOpenDetail: (TodoItem) -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Waktu (Time)
            TextField(lang == "id" ? "Pilih waktu" : "Set time",
                      text: Binding(
                        get: { item.timeRange ?? "" },
                        set: { todoManager.updateTimeRange(item, to: $0) }
                      ))
            .textFieldStyle(.plain)
            .font(.system(size: 12))
            .frame(width: 90)
            .padding(.leading, 8)
            
            Divider().frame(height: 36)
            
            // Durasi (Duration)
            TextField(lang == "id" ? "Durasi" : "Duration",
                      text: Binding(
                        get: { item.duration ?? "" },
                        set: { todoManager.updateDuration(item, to: $0) }
                      ))
            .textFieldStyle(.plain)
            .font(.system(size: 12))
            .frame(width: 80)
            .padding(.leading, 8)
            
            Divider().frame(height: 36)
            
            // Kegiatan (Activity / Title)
            HStack(spacing: 4) {
                if let emoji = item.emojiIcon, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: 13))
                }
                TextField(lang == "id" ? "Nama kegiatan" : "Activity name",
                          text: Binding(
                            get: { item.title },
                            set: { todoManager.updateTitle(item, to: $0) }
                          ))
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .medium))
            }
            .frame(width: 150)
            .padding(.leading, 8)
            
            Divider().frame(height: 36)
            
            // Detail Acara (Description / Notes)
            TextField(lang == "id" ? "Detail acara..." : "Event details...",
                      text: Binding(
                        get: { item.notes },
                        set: { todoManager.updateNotes(item, to: $0) }
                      ))
            .textFieldStyle(.plain)
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.leading, 8)
            
            Divider().frame(height: 36)
            
            // Tempat (Location)
            TextField(lang == "id" ? "Tempat" : "Location",
                      text: Binding(
                        get: { item.location ?? "" },
                        set: { todoManager.updateLocation(item, to: $0) }
                      ))
            .textFieldStyle(.plain)
            .font(.system(size: 12))
            .frame(width: 130)
            .padding(.leading, 8)
            
            Divider().frame(height: 36)

            // Status Column
            HStack(spacing: 4) {
                Image(systemName: item.status.icon)
                    .font(.system(size: 8))
                Text(item.status.title(lang))
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(item.status.tint)
            .frame(width: 80, alignment: .leading)
            .padding(.leading, 8)

            Divider().frame(height: 36)
            
            // Actions
            HStack(spacing: 6) {
                // Reorder chevrons
                Button(action: { todoManager.moveUp(item) }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 9))
                }
                .buttonStyle(.plain)
                .disabled(!todoManager.canMoveUp(item))
                
                Button(action: { todoManager.moveDown(item) }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                }
                .buttonStyle(.plain)
                .disabled(!todoManager.canMoveDown(item))
                
                // Open detail
                Button(action: { onOpenDetail(item) }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 9))
                }
                .buttonStyle(.plain)
            }
            .frame(width: 70)
            .foregroundColor(.secondary)
        }
        .frame(height: 36)
        .contentShape(Rectangle())
    }
}
