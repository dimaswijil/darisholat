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

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: prayerViewModel)
                .frame(width: (prayerViewModel.currentScreen == .settings || (prayerViewModel.currentScreen == .main && prayerViewModel.showCalendarEvents)) ? 500 : 260)
        } label: {
            MenuBarLabelView(viewModel: prayerViewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabelView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel

    var body: some View {
        switch viewModel.menuBarStyle {
        case .iconOnly:
            Image(systemName: viewModel.nextPrayerIconName)
                .foregroundColor(viewModel.resolvedAccentColor)
        case .compact:
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
}
