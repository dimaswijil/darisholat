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
import AppKit

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
    static let fontTitle:   CGFloat = 15            // ≈ 13 × do
    static let fontBody:    CGFloat = f13
    static let fontSmall:   CGFloat = 11            // ≈ 8 × φ
    static let fontMono:    CGFloat = f13
}

// MARK: - ContentView

struct ContentView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var hasAppeared = false
    @State private var urgencyPulse = false

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
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.15)) { viewModel.currentScreen = .main }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .trailing).combined(with: .opacity)
                        ))
                    case .about:
                        AboutView(language: viewModel.selectedLanguage) {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.15)) { viewModel.currentScreen = .main }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }
                .frame(width: (viewModel.currentScreen == .settings || viewModel.currentScreen == .about)
                       ? (DS.panelWidth + 240) : DS.panelWidth)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: viewModel.currentScreen)

                if viewModel.currentScreen == .main && viewModel.showCalendarEvents {
                    // Vertical separator
                    Divider()

                    // Right Column (Calendar events or Habits)
                    VStack(spacing: 0) {
                        calendarEventsSection
                            .transition(.opacity)
                        Spacer(minLength: 0)
                        wallpaperAndToggleBar
                    }
                    .frame(width: 240)
                    .background(
                        GeometryReader { proxy in
                            ZStack {
                                Image(viewModel.selectedEventWallpaper)
                                    .resizable()
                                    .scaledToFill()
                                    .id(viewModel.selectedEventWallpaper)
                                    .transition(.opacity)
                                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: viewModel.selectedEventWallpaper)
                                Color.black.opacity(0.6)
                                // Time-based tint overlay
                                prayerTimeTintColor
                                    .opacity(0.18)
                                    .blendMode(.overlay)
                            }
                            .frame(width: proxy.size.width, height: proxy.size.height + 10)
                            .clipped()
                            .offset(y: -5)
                        }
                    )
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
        .onAppear {
            hasAppeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8)) {
                    hasAppeared = true
                }
            }
        }
        .onDisappear { hasAppeared = false }
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
                    RollingDigitText(
                        text: viewModel.countdownText,
                        font: .system(size: DS.fontSmall, weight: .medium, design: .monospaced),
                        color: urgencyColor
                    )
                    .scaleEffect(isUrgent ? (urgencyPulse ? 1.08 : 1.0) : 1.0)
                    .animation(
                        reduceMotion ? nil : (isUrgent
                            ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                            : .default),
                        value: urgencyPulse
                    )
                }
            }
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, DS.headerV)
        .onAppear { if isUrgent { urgencyPulse = true } }
        .onChange(of: isUrgent) { newValue in urgencyPulse = newValue }
    }

    /// True when < 5 minutes remain
    private var isUrgent: Bool {
        viewModel.countdownSeconds > 0 && viewModel.countdownSeconds <= 300
    }

    /// Shifts from accent → warm orange → red as time decreases
    private var urgencyColor: Color {
        let secs = viewModel.countdownSeconds
        guard secs > 0 && secs <= 300 else { return viewModel.resolvedAccentColor }
        let ratio = Double(secs) / 300.0 // 1.0 = 5min, 0.0 = 0min
        if ratio > 0.5 {
            // accent → orange (300s → 150s)
            return viewModel.resolvedAccentColor
        } else if ratio > 0.15 {
            // orange zone (150s → 45s)
            return Color(red: 0.95, green: 0.55, blue: 0.20)
        } else {
            // red zone (< 45s)
            return Color(red: 0.92, green: 0.28, blue: 0.28)
        }
    }

    // MARK: - Prayer List

    private var prayerList: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.prayerSchedule.enumerated()), id: \.element.id) { index, item in
                PrayerTimeRow(
                    name: item.name,
                    time: viewModel.formattedTime(item.time, use24h: viewModel.uses24HourTime),
                    isNext: viewModel.isNextPrayer(item.prayer),
                    prayer: item.prayer,
                    isWhiteAccent: viewModel.appAccentColor == .white,
                    progress: viewModel.isNextPrayer(item.prayer) ? viewModel.nextPrayerProgress : nil
                )
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 8)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.35).delay(Double(index) * 0.04), value: hasAppeared)
            }
        }
        .padding(.vertical, DS.f3)
    }

    // MARK: - Bottom Menu

    private var bottomMenu: some View {
        VStack(spacing: 0) {
            menuBtn(L10n.settings(viewModel.selectedLanguage), color: .primary) {
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.15)) { viewModel.currentScreen = .settings }
            }
            menuBtn(L10n.about(viewModel.selectedLanguage), color: .primary) {
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.15)) { viewModel.currentScreen = .about }
            }
            hairline
            menuBtn(L10n.quit(viewModel.selectedLanguage), color: .red) {
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
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
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Text(viewModel.currentHijriDate + (viewModel.selectedLanguage == "id" ? " H" : " AH"))
                    .font(.system(size: DS.fontSmall, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
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
                            .foregroundColor(.white.opacity(0.8))
                        Text(L10n.grantCalendarAccess(viewModel.selectedLanguage))
                            .font(.system(size: DS.fontBody, weight: .semibold))
                            .foregroundColor(.white)
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
                        .font(.system(size: DS.fontBody, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
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

    // MARK: - Wallpaper Selector + Habits Toggle

    private var wallpaperAndToggleBar: some View {
        HStack(spacing: 12) {
            // Wallpaper options
            ForEach(["AboutWallpaper", "EventWallpaper1", "EventWallpaper2", "EventWallpaper3"], id: \.self) { wallpaper in
                Button(action: {
                    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                    withAnimation(reduceMotion ? nil : .default) {
                        viewModel.selectedEventWallpaper = wallpaper
                    }
                }) {
                    Image(wallpaper)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    viewModel.selectedEventWallpaper == wallpaper ? Color.white : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
            }

            Spacer()


        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, 12)
    }

    // Keep old name for backward compatibility if referenced elsewhere
    private var wallpaperSelector: some View {
        wallpaperAndToggleBar
    }

    // MARK: - Ramadan Countdown Row

    private var ramadanCountdownRow: some View {
        HStack(spacing: 12) {
            // Crescent moon icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(L10n.ramadan(viewModel.selectedLanguage))
                    .font(.system(size: DS.fontBody, weight: viewModel.isCurrentlyRamadan ? .semibold : .regular))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if viewModel.isCurrentlyRamadan {
                    Text(viewModel.ramadanCountdownText)
                        .font(.system(size: DS.fontSmall - 1, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            Spacer(minLength: 8)

            if !viewModel.isCurrentlyRamadan {
                Text(viewModel.ramadanCountdownText)
                    .font(.system(size: DS.fontBody, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
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

    // MARK: - Time-Based Tint Color

    private var prayerTimeTintColor: Color {
        guard let prayer = viewModel.currentPrayer else {
            return Color(red: 0.08, green: 0.10, blue: 0.25) // default night
        }
        switch prayer {
        case .fajr:    return Color(red: 0.15, green: 0.20, blue: 0.50) // deep blue dawn
        case .sunrise: return Color(red: 0.95, green: 0.75, blue: 0.35) // warm gold
        case .dhuhr:   return Color(red: 0.95, green: 0.85, blue: 0.45) // bright golden
        case .asr:     return Color(red: 0.92, green: 0.65, blue: 0.30) // amber orange
        case .maghrib: return Color(red: 0.85, green: 0.35, blue: 0.25) // reddish sunset
        case .isha:    return Color(red: 0.12, green: 0.10, blue: 0.30) // dark indigo
        }
    }
}

// MARK: - Prayer Time Row

struct PrayerTimeRow: View {
    let name: String
    let time: String
    let isNext: Bool
    let prayer: Prayer
    let isWhiteAccent: Bool
    var progress: Double? = nil  // 0.0–1.0 for next prayer progress ring
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isHovered = false
    @State private var isPulsing = false

    private var accent: Color { .accentColor }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Circular Icon with optional pulsing glow + progress ring
            ZStack {
                // Pulsing glow behind next prayer icon
                if isNext {
                    Circle()
                        .fill(accent.opacity(0.25))
                        .frame(width: 34, height: 34)
                        .scaleEffect(isPulsing ? 1.15 : 0.95)
                        .opacity(isPulsing ? 0.0 : 0.5)
                        .animation(
                            reduceMotion ? nil : .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }

                // Progress ring
                if let progress = progress, isNext {
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(accent.opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(-90))
                }

                Circle()
                    .fill(isNext ? accent : Color.primary.opacity(0.08))
                    .frame(width: 28, height: 28)
                    .scaleEffect(isNext && isPulsing ? 1.06 : 1.0)
                    .animation(
                        reduceMotion ? nil : (isNext ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true) : .default),
                        value: isPulsing
                    )

                Image(systemName: prayerIconName(prayer))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isNext ? (isWhiteAccent ? .black : .white) : .primary.opacity(0.8))
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
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: isHovered)
        .onHover { h in withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.1)) { isHovered = h } }
        .onAppear {
            if isNext { isPulsing = true }
        }
        .onChange(of: isNext) { newValue in
            isPulsing = newValue
        }
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
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }

            Text(event.title)
                .font(.system(size: DS.fontBody, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 8)

            Text(event.countdownText(lang: lang))
                .font(.system(size: DS.fontBody, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .monospacedDigit()
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, DS.rowV)
        .background(isHovered ? Color.primary.opacity(0.04) : Color.clear)
        .onHover { h in withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.1)) { isHovered = h } }
        .help(event.tooltipText(lang: lang))
    }
}

// MARK: - Hover Button Style

struct HoverMenuButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isHovered = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(isHovered || configuration.isPressed ? Color.primary.opacity(0.05) : Color.clear)
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: isHovered)
            .onHover { h in withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.1)) { isHovered = h } }
    }
}

// MARK: - Rolling Digit Text (macOS 13+ compatible)

/// Animates each character individually with a vertical slide transition.
/// Provides an airport-departure-board feel for countdown text.
struct RollingDigitText: View {
    let text: String
    let font: Font
    let color: Color
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, char in
                SingleCharView(char: char, font: font, color: color)
                    .id("\(index)-\(char)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal:   .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: text)
        .clipped()
    }
}

/// Renders a single character in a fixed-width slot for digit alignment.
private struct SingleCharView: View {
    let char: Character
    let font: Font
    let color: Color

    var body: some View {
        Text(String(char))
            .font(font)
            .foregroundColor(color)
            .monospacedDigit()
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
