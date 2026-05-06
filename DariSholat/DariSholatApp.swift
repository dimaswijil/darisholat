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
                .frame(width: 260)
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        switch prayerViewModel.menuBarStyle {
        case .iconOnly:
            Image(systemName: "moon.stars.fill")
        case .countdown, .compact, .prayerTime:
            HStack(spacing: 4) {
                Image(systemName: "moon.stars.fill")
                if !prayerViewModel.menuBarText.isEmpty {
                    Text(prayerViewModel.menuBarText)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                }
            }
        }
    }
}
