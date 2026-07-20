//
//  DariSholatApp.swift
//  darisholat
//
//  Modern prayer time menu bar app for macOS
//  Lowercase branding: "darisholat"
//

import SwiftUI

@main
struct DariSholatApp: App {
    @StateObject private var prayerViewModel = PrayerTimeViewModel()

    init() {
        // Force dark appearance app-wide so the MenuBarExtra panel
        // looks identical in both system light and dark mode.
        NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: prayerViewModel)
                .frame(width: prayerViewModel.showCalendarEvents ? 500 : 260)
        } label: {
            MenuBarLabelView(viewModel: prayerViewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabelView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: viewModel.nextPrayerIconName)
            if !viewModel.menuBarText.isEmpty {
                Text(viewModel.menuBarText)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .monospacedDigit()
            }
        }
        .foregroundColor(viewModel.resolvedAccentColor)
    }
}
