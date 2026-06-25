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

// Navigation state moved to ViewModel

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

    var body: some View {
        ZStack {
            VisualEffectView(material: viewModel.blurStyle.material, blendingMode: .behindWindow)
                .opacity(viewModel.blurStyle == .custom ? viewModel.customBlurOpacity : 1.0)
                .ignoresSafeArea()

            // Subtle dark overlay to match the Control Center's dark frosted glass depth
            if viewModel.blurStyle == .hud || viewModel.blurStyle == .liquidGlass {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
            }

            HStack(alignment: .top, spacing: 0) {
                // Left Column (Prayer times, Settings, or About)
                Group {
                    switch viewModel.currentScreen {
                    case .main:
                        leftMainColumn
                            .transition(.opacity)
                    case .settings:
                        SettingsView(viewModel: viewModel) {
                            withAnimation(.easeInOut(duration: 0.15)) { viewModel.currentScreen = .main }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .trailing).combined(with: .opacity)
                        ))
                    case .about:
                        AboutView(language: viewModel.selectedLanguage) {
                            withAnimation(.easeInOut(duration: 0.15)) { viewModel.currentScreen = .main }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }
                .frame(width: (viewModel.currentScreen == .settings || viewModel.currentScreen == .about)
                       ? (DS.panelWidth + 240) : DS.panelWidth)
                .animation(.easeInOut(duration: 0.15), value: viewModel.currentScreen)

                if viewModel.currentScreen == .main && viewModel.showCalendarEvents {
                    // Vertical separator
                    Divider()

                    // Right Column (Calendar events)
                    VStack(spacing: 0) {
                        calendarEventsSection
                        Spacer(minLength: 0)
                    }
                    .frame(width: 240)
                }
            }
            .padding(.vertical, DS.f5)
        }
        .frame(width: {
            switch viewModel.currentScreen {
            case .settings:
                return DS.panelWidth + 240
            case .about:
                return DS.panelWidth + 240
            case .main:
                return viewModel.showCalendarEvents ? (DS.panelWidth + 240) : DS.panelWidth
            }
        }())
        .environment(\.layoutDirection,
                      viewModel.selectedLanguage == "ar" ? .rightToLeft : .leftToRight)
        .tint(viewModel.resolvedAccentColor)
        .accentColor(viewModel.resolvedAccentColor)
    }

    // MARK: - Left Main Column

    private var leftMainColumn: some View {
        VStack(spacing: 0) {
            headerRow
            hairline
            prayerList
            hairline
            bottomMenu
        }
    }

    // MARK: - Header (macOS Focus-like title + location subtitle + countdown)

    private var headerRow: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("DariSholat")
                    .font(.system(size: DS.fontTitle, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .tracking(-0.4)

                HStack(spacing: 3) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text(viewModel.cityName)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: DS.f8)

            if !viewModel.nextPrayerDisplayName.isEmpty {
                HStack(spacing: DS.f3) {
                    Text(viewModel.nextPrayerDisplayName)
                        .font(.system(size: DS.fontSmall, weight: .regular))
                        .foregroundColor(.accentColor)
                    Text(viewModel.countdownText)
                        .font(.system(size: DS.fontSmall, weight: .medium, design: .monospaced))
                        .foregroundColor(.accentColor)
                        .monospacedDigit()
                }
            }
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, DS.headerV)
    }

    // MARK: - Prayer List

    private var prayerList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.prayerSchedule) { item in
                PrayerTimeRow(
                    name: item.name,
                    time: viewModel.formattedTime(item.time, use24h: viewModel.uses24HourTime),
                    isNext: viewModel.isNextPrayer(item.prayer),
                    prayer: item.prayer
                )
            }
        }
        .padding(.vertical, DS.f3)
    }

    // MARK: - Bottom Menu

    private var bottomMenu: some View {
        VStack(spacing: 0) {
            menuBtn(L10n.settings(viewModel.selectedLanguage), color: .primary) {
                withAnimation(.easeInOut(duration: 0.15)) { viewModel.currentScreen = .settings }
            }
            menuBtn(L10n.about(viewModel.selectedLanguage), color: .primary) {
                withAnimation(.easeInOut(duration: 0.15)) { viewModel.currentScreen = .about }
            }
            hairline
            menuBtn(L10n.quit(viewModel.selectedLanguage), color: .red) {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    @ViewBuilder
    private func menuBtn(_ label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: DS.fontBody, weight: .regular))
                    .foregroundColor(color)
                Spacer()
            }
            .padding(.horizontal, DS.paddingH)
            .padding(.vertical, DS.rowV)
            .contentShape(Rectangle())
        }
        .buttonStyle(HoverMenuButtonStyle())
    }

    // MARK: - Calendar Events Section

    private var calendarEventsSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                HStack(spacing: DS.f3) {
                    Image(systemName: "calendar")
                        .font(.system(size: DS.fontSmall - 1, weight: .medium))
                        .foregroundColor(.accentColor)
                    Text(L10n.events(viewModel.selectedLanguage))
                        .font(.system(size: DS.fontSmall, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, DS.paddingH)
            .padding(.top, DS.rowV)
            .padding(.bottom, DS.f3)

            // 1️⃣ Ramadan Countdown (always visible, pinned at top)
            ramadanCountdownRow

            Divider().opacity(DS.dividerOpacity)
                .padding(.horizontal, DS.paddingH)

            // 2️⃣ Apple Calendar Events
            if !viewModel.isCalendarAuthorized {
                // Permission not granted
                Button(action: { viewModel.calendarManager.requestAccess() }) {
                    HStack {
                        Image(systemName: "lock.shield")
                            .font(.system(size: DS.fontSmall))
                            .foregroundColor(.secondary)
                        Text(L10n.grantCalendarAccess(viewModel.selectedLanguage))
                            .font(.system(size: DS.fontBody, weight: .regular))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.horizontal, DS.paddingH)
                    .padding(.vertical, DS.rowV)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(HoverMenuButtonStyle())
            } else if viewModel.upcomingEvents.isEmpty {
                // No events
                HStack {
                    Text(L10n.noEvents(viewModel.selectedLanguage))
                        .font(.system(size: DS.fontBody, weight: .regular))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, DS.paddingH)
                .padding(.vertical, DS.rowV)
            } else {
                // Event list
                ForEach(viewModel.upcomingEvents) { event in
                    CalendarEventRow(
                        event: event,
                        lang: viewModel.selectedLanguage
                    )
                }
            }
        }
        .padding(.bottom, DS.f3)
    }

    // MARK: - Ramadan Countdown Row

    private var ramadanCountdownRow: some View {
        HStack(spacing: 12) {
            // Crescent moon icon
            ZStack {
                Circle()
                    .fill(viewModel.isCurrentlyRamadan
                          ? Color.accentColor
                          : Color.accentColor.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(viewModel.isCurrentlyRamadan ? .white : .accentColor)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(L10n.ramadan(viewModel.selectedLanguage))
                    .font(.system(size: DS.fontBody, weight: viewModel.isCurrentlyRamadan ? .semibold : .regular))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if viewModel.isCurrentlyRamadan {
                    Text(viewModel.ramadanCountdownText)
                        .font(.system(size: DS.fontSmall - 1, weight: .medium))
                        .foregroundColor(.accentColor)
                }
            }

            Spacer(minLength: 8)

            if !viewModel.isCurrentlyRamadan {
                Text(viewModel.ramadanCountdownText)
                    .font(.system(size: DS.fontBody, weight: .regular, design: .monospaced))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, DS.rowV)
        .help(viewModel.ramadanDateTooltip)
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
    let prayer: Prayer
    @State private var isHovered = false

    private var accent: Color { .accentColor }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Circular Icon
            ZStack {
                Circle()
                    .fill(isNext ? accent : Color.primary.opacity(0.08))
                    .frame(width: 28, height: 28)
                Image(systemName: prayerIconName(prayer))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isNext ? .white : .primary.opacity(0.8))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.system(size: DS.fontBody, weight: isNext ? .semibold : .regular))
                    .foregroundColor(isNext ? .primary : .primary.opacity(0.9))
            }

            Spacer()

            Text(time)
                .font(.system(size: DS.fontBody, weight: isNext ? .semibold : .regular, design: .monospaced))
                .foregroundColor(isNext ? accent : .secondary)
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, isNext ? DS.rowV + 2 : DS.rowV)
        .background(isHovered ? Color.primary.opacity(0.04) : Color.clear)
        .onHover { h in withAnimation(.easeInOut(duration: 0.1)) { isHovered = h } }
    }

    private func prayerIconName(_ prayer: Prayer) -> String {
        switch prayer {
        case .fajr:    return "sunrise.fill"
        case .sunrise: return "sun.and.horizon.fill"
        case .dhuhr:   return "sun.max.fill"
        case .asr:     return "sun.min.fill"
        case .maghrib: return "sunset.fill"
        case .isha:    return "moon.stars.fill"
        }
    }
}

// MARK: - Calendar Event Row

struct CalendarEventRow: View {
    let event: CalendarEventItem
    let lang: String
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Circular Calendar Icon with light background of accent color (green)
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.accentColor)
            }

            Text(event.title)
                .font(.system(size: DS.fontBody, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 8)

            Text(event.countdownText(lang: lang))
                .font(.system(size: DS.fontBody, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, DS.rowV)
        .background(isHovered ? Color.primary.opacity(0.04) : Color.clear)
        .onHover { h in withAnimation(.easeInOut(duration: 0.1)) { isHovered = h } }
        .help(event.tooltipText(lang: lang))
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
