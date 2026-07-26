//
//  ContentView.swift
//  darisholat
//
//  Layout menggunakan prinsip Golden Ratio & Fibonacci spacing:
//  φ = 1.618 | Fibonacci: 1,1,2,3,5,8,13,21,34,55,89...
//

import SwiftUI
import Adhan
import AppKit

// MARK: - ContentView

struct ContentView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var hasAppeared = false

    /// Maximum popover height = screen height minus menu bar (37pt) and
    /// safety margin (55pt for the popover arrow + spacing from edges).
    /// Falls back to 500pt if no screen is available.
    private var maxPopoverHeight: CGFloat {
        let screenH = NSScreen.main?.visibleFrame.height ?? 800
        return min(screenH - 55, 700)  // never exceed 700pt
    }

    var body: some View {
        ZStack(alignment: .top) {
            VisualEffectView(material: viewModel.blurStyle.material, blendingMode: .behindWindow)
                .opacity(viewModel.blurStyle == .custom ? viewModel.customBlurOpacity : 1.0)
                .ignoresSafeArea()

            // Subtle dark overlay to match the Control Center's dark frosted glass depth
            if viewModel.blurStyle == .hud || viewModel.blurStyle == .liquidGlass {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
            }

            HStack(alignment: .top, spacing: 0) {
                // Left Column (Prayer times; Settings/About live in the desktop window)
                leftMainColumn
                    .frame(width: DS.panelWidth)

                if viewModel.showCalendarEvents {
                    // Vertical separator
                    Divider()

                    // Right Column (Calendar events or Habits)
                    VStack(spacing: 0) {
                        CalendarEventsSectionView(viewModel: viewModel)
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
        .frame(width: viewModel.showCalendarEvents ? (DS.panelWidth + 240) : DS.panelWidth)
        .frame(maxHeight: maxPopoverHeight)
        .environment(\.layoutDirection,
                      viewModel.selectedLanguage == "ar" ? .rightToLeft : .leftToRight)
        .preferredColorScheme(.dark)
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

                Menu {
                    Button(action: {
                        viewModel.useAutomaticLocation()
                    }) {
                        Text(!viewModel.isManualLocation ? "✓ \(L10n.automaticLocation(viewModel.selectedLanguage))" : L10n.automaticLocation(viewModel.selectedLanguage))
                    }

                    Divider()

                    ForEach(viewModel.indonesianCities) { city in
                        Button(action: {
                            viewModel.selectCity(city: city)
                        }) {
                            Text(viewModel.isManualLocation && viewModel.selectedManualCityName == city.name ? "✓ \(city.name)" : city.name)
                        }
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                        Text(viewModel.cityName)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
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
                }
            }
        }
        .padding(.horizontal, DS.paddingH)
        .padding(.vertical, DS.headerV)
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
            return viewModel.resolvedAccentColor
        } else if ratio > 0.15 {
            return Color(red: 0.95, green: 0.55, blue: 0.20)
        } else {
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
            // Single compact row: icon-only actions (To-Doing + GitHub)
            HStack(spacing: 13) {
                iconAction(icon: "checklist",
                           help: L10n.todo(viewModel.selectedLanguage)) {
                    MainWindowManager.shared.show(tab: .todo, viewModel: viewModel)
                }

                if let url = URL(string: "https://github.com/dimaswijil/DariSholat") {
                    Link(destination: url) {
                        iconCircle("link")
                    }
                    .buttonStyle(.plain)
                    .help("GitHub — dimaswijil/DariSholat")
                }

                Spacer()
            }
            .padding(.horizontal, DS.paddingH)
            .padding(.vertical, DS.rowV)

            hairline
            menuBtn(L10n.quit(viewModel.selectedLanguage), color: .red) {
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                NSApplication.shared.terminate(nil)
            }
        }
    }

    /// Icon-only circular action button for the compact bottom row.
    private func iconAction(icon: String, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            iconCircle(icon)
        }
        .buttonStyle(.plain)
        .help(help)
    }

    private func iconCircle(_ icon: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 28, height: 28)
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.accentColor)
        }
        .contentShape(Circle())
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
