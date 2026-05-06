//
//  ContentView.swift
//  darisholat
//
//  Layout menggunakan prinsip Golden Ratio & Fibonacci spacing:
//  φ = 1.618 | Fibonacci: 1,1,2,3,5,8,13,21,34,55,89...
//
//  Width  : 260px → content = 260 - (13×2) = 234 ≈ 233 (Fib)
//  Padding H: 13px  (Fib)
//  Padding V rows: 8px (Fib)
//  Padding V header: 13px (Fib)
//  Font body: 13px, header: 15px ≈ 13×φ (Fib scaling)
//  Row height: 8+13+8 = 29 ≈ 34 (Fib window)
//

import SwiftUI
import Adhan

// MARK: - Navigation State

enum AppScreen {
    case main, settings, about
}

// MARK: - Fibonacci / Golden Ratio Design Tokens

private enum DS {
    // Fibonacci units
    static let f3:  CGFloat = 3
    static let f5:  CGFloat = 5
    static let f8:  CGFloat = 8
    static let f13: CGFloat = 13
    static let f21: CGFloat = 21
    static let f34: CGFloat = 34

    // Layout
    static let panelWidth:  CGFloat = 260          // 233+13+13 ≈ 260
    static let paddingH:    CGFloat = f13           // horizontal padding
    static let rowV:        CGFloat = f8            // row vertical padding
    static let headerV:     CGFloat = f13           // header vertical padding
    static let dividerOpacity: CGFloat = 0.35

    // Typography (Fibonacci-scaled)
    static let fontTitle:   CGFloat = 15            // ≈ 13 × φ
    static let fontBody:    CGFloat = f13
    static let fontSmall:   CGFloat = 11            // ≈ 8 × φ
    static let fontMono:    CGFloat = f13
}

// MARK: - ContentView

struct ContentView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel
    @State private var currentScreen: AppScreen = .main

    var body: some View {
        ZStack {
            VisualEffectView(material: viewModel.blurStyle.material, blendingMode: .behindWindow)
                .opacity(viewModel.blurStyle == .custom ? viewModel.customBlurOpacity : 1.0)
                .ignoresSafeArea()

            Group {
                switch currentScreen {
                case .main:
                    mainView.transition(.opacity)
                case .settings:
                    SettingsView(viewModel: viewModel) {
                        withAnimation(.easeInOut(duration: 0.15)) { currentScreen = .main }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    ))
                case .about:
                    AboutView(language: viewModel.selectedLanguage) {
                        withAnimation(.easeInOut(duration: 0.15)) { currentScreen = .main }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.15), value: currentScreen)
        }
        .frame(width: DS.panelWidth)
        .environment(\.layoutDirection,
                      viewModel.selectedLanguage == "ar" ? .rightToLeft : .leftToRight)
    }

    // MARK: - Main View

    private var mainView: some View {
        VStack(spacing: 0) {
            headerRow
            hairline
            locationRow
            hairline
            prayerList
            hairline
            bottomMenu
        }
        .padding(.vertical, DS.f5)
    }

    // MARK: - Header  (app name left · countdown right)

    private var headerRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("darisholat")
                .font(.system(size: DS.fontTitle, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .tracking(-0.4)

            Spacer(minLength: DS.f8)

            if !viewModel.nextPrayerDisplayName.isEmpty {
                HStack(spacing: DS.f3) {
                    Text(viewModel.nextPrayerDisplayName)
                        .font(.system(size: DS.fontSmall, weight: .regular))
                        .foregroundColor(.secondary)
                    Text(viewModel.countdownText)
                        .font(.system(size: DS.fontSmall, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, DS.headerV)
    }

    // MARK: - Location

    private var locationRow: some View {
        HStack(spacing: DS.f5) {
            Image(systemName: "location.fill")
                .font(.system(size: DS.fontSmall - 1, weight: .medium))
                .foregroundColor(.accentColor)
            Text(viewModel.cityName)
                .font(.system(size: DS.fontBody, weight: .regular))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, DS.rowV)
    }

    // MARK: - Prayer List

    private var prayerList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.prayerSchedule) { item in
                PrayerTimeRow(
                    name: item.name,
                    time: viewModel.formattedTime(item.time, use24h: viewModel.uses24HourTime),
                    isNext: viewModel.isNextPrayer(item.prayer),
                    useAccentColor: viewModel.useAccentColor
                )
            }
        }
        .padding(.vertical, DS.f3)
    }

    // MARK: - Bottom Menu

    private var bottomMenu: some View {
        VStack(spacing: 0) {
            menuBtn(L10n.settings(viewModel.selectedLanguage), chevron: true, color: .primary) {
                withAnimation(.easeInOut(duration: 0.15)) { currentScreen = .settings }
            }
            menuBtn(L10n.about(viewModel.selectedLanguage), chevron: false, color: .primary) {
                withAnimation(.easeInOut(duration: 0.15)) { currentScreen = .about }
            }
            hairline
            menuBtn(L10n.quit(viewModel.selectedLanguage), chevron: false, color: .red) {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    @ViewBuilder
    private func menuBtn(_ label: String, chevron: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: DS.fontBody, weight: .regular))
                    .foregroundColor(color)
                Spacer()
                if chevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: DS.fontSmall - 1, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, DS.paddingH)
            .padding(.vertical, DS.rowV)
            .contentShape(Rectangle())
        }
        .buttonStyle(HoverMenuButtonStyle())
    }

    private var hairline: some View {
        Divider().opacity(DS.dividerOpacity)
    }
}

// MARK: - Prayer Time Row

struct PrayerTimeRow: View {
    let name: String
    let time: String
    let isNext: Bool
    let useAccentColor: Bool
    @State private var isHovered = false

    private var accent: Color { useAccentColor ? .accentColor : Color(nsColor: .controlAccentColor) }

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: DS.fontBody, weight: isNext ? .semibold : .regular))
                .foregroundColor(isNext ? accent : .primary)
            Spacer()
            Text(time)
                .font(.system(size: DS.fontBody, weight: isNext ? .semibold : .regular, design: .monospaced))
                .foregroundColor(isNext ? accent : Color.secondary.opacity(0.8))
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, DS.rowV)
        .background(
            Group {
                if isNext       { Color.accentColor.opacity(0.10) }
                else if isHovered { Color.primary.opacity(0.04) }
                else            { Color.clear }
            }
        )
        .onHover { h in withAnimation(.easeInOut(duration: 0.1)) { isHovered = h } }
    }
}

// MARK: - Hover Button Style

struct HoverMenuButtonStyle: ButtonStyle {
    @State private var isHovered = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(isHovered || configuration.isPressed ? Color.primary.opacity(0.05) : Color.clear)
            .onHover { h in withAnimation(.easeInOut(duration: 0.1)) { isHovered = h } }
    }
}

// MARK: - DS global access from other files
extension CGFloat {
    static let paddingH: CGFloat = DS.paddingH
    static let rowV:     CGFloat = DS.rowV
    static let headerV:  CGFloat = DS.headerV
    static let fontBody: CGFloat = DS.fontBody
    static let fontSmall: CGFloat = DS.fontSmall
}

// MARK: - Blur Style Mapping
extension AppBlurStyle {
    var material: NSVisualEffectView.Material {
        switch self {
        case .hud: return .hudWindow
        case .popover: return .popover
        case .menu: return .menu
        case .sidebar: return .sidebar
        case .liquidGlass: return .underWindowBackground
        case .custom: return .hudWindow // Base material for custom opacity
        }
    }
}
