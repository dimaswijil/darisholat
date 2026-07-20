//
//  MainWindowView.swift
//  DariSholat
//
//  Desktop window content: custom dark sidebar (To-Do / Settings / About)
//  next to a detail pane. Styled to match the menu bar panel's frosted look.
//

import SwiftUI

struct MainWindowView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel
    @ObservedObject var windowManager: MainWindowManager
    @ObservedObject private var todoManager: TodoManager

    /// Set by the palette when the user picks a task; TodoListView opens its detail.
    @State private var paletteSelection: TodoItem?

    init(viewModel: PrayerTimeViewModel, windowManager: MainWindowManager) {
        self.viewModel = viewModel
        self.windowManager = windowManager
        self.todoManager = viewModel.todoManager
    }

    var body: some View {
        ZStack {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .ignoresSafeArea()
            Color.black.opacity(0.15)
                .ignoresSafeArea()

            HStack(spacing: 0) {
                // The sidebar stays in the hierarchy and its width animates —
                // no view insertion/removal, so the slide is perfectly smooth.
                sidebar
                    .frame(width: 210, alignment: .leading) // ≈ width / φ²
                    .frame(width: windowManager.sidebarVisible ? 210 : 0, alignment: .trailing)
                    .clipped()
                    .opacity(windowManager.sidebarVisible ? 1 : 0)

                Divider()
                    .opacity(windowManager.sidebarVisible ? 1 : 0)

                detail
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    // When the sidebar is hidden the toggle button occupies the
                    // top-left; drop the content below it so the title clears
                    // the titlebar line symmetrically.
                    .padding(.top, windowManager.sidebarVisible ? 0 : 34)
            }
            .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: windowManager.sidebarVisible)

            // Fixed toggle above the "DariSholat" brand — lives in the ZStack
            // (not the animated HStack) so it never shifts when the sidebar
            // slides away.
            VStack {
                HStack {
                    Button(action: windowManager.toggleSidebar) {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help(viewModel.selectedLanguage == "id"
                          ? "Sembunyikan/tampilkan sidebar (⌘\\)"
                          : "Hide/show sidebar (⌘\\)")
                    .padding(.leading, 21) // same left edge as "DariSholat"
                    .padding(.top, 10)

                    Spacer()
                }
                Spacer()
            }

            // Invisible shortcut host: ⌘\ toggles sidebar.
            Button("") { windowManager.toggleSidebar() }
                .keyboardShortcut("\\", modifiers: .command)
                .hidden()
        }
        .frame(minWidth: 700, minHeight: 440)
        .preferredColorScheme(.dark)
        .tint(viewModel.resolvedAccentColor)
        .accentColor(viewModel.resolvedAccentColor)
        .environment(\.layoutDirection,
                      viewModel.selectedLanguage == "ar" ? .rightToLeft : .leftToRight)
    }

    // MARK: - Sidebar
    // Spacing follows the app's Fibonacci tokens (5, 8, 13, 21, 34, 55)
    // and the golden ratio φ for vertical rhythm.

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Brand block — accent-tinted, tappable: opens the Home page
            // (a calm wallpaper view matching the popover's selection).
            Button {
                windowManager.selectedTab = .home
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text("DariSholat")
                        .font(.system(size: 21, weight: .bold, design: .serif))
                        .foregroundColor(.accentColor)

                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 8))
                        Text(viewModel.cityName)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(viewModel.selectedLanguage == "id" ? "Beranda" : "Home")
            .padding(.horizontal, 21)
            .padding(.top, 42)      // below the fixed toggle button line
            .padding(.bottom, 13)   // tight gap to the nav below

            // Navigation
            VStack(alignment: .leading, spacing: 5) {
                sidebarItem(.todo,
                            icon: "checklist",
                            label: L10n.todo(viewModel.selectedLanguage),
                            showsBadge: true)
                sidebarItem(.settings,
                            icon: "gearshape.fill",
                            label: L10n.settings(viewModel.selectedLanguage))
                sidebarItem(.about,
                            icon: "info.circle.fill",
                            label: L10n.about(viewModel.selectedLanguage))
            }
            .padding(.horizontal, 13)

            Spacer()

            nextPrayerCard
        }
    }

    /// Next-prayer detail carried over from the menu bar popover header.
    @ViewBuilder
    private var nextPrayerCard: some View {
        if !viewModel.nextPrayerDisplayName.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.nextPrayer(viewModel.selectedLanguage))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                HStack(spacing: 6) {
                    Image(systemName: viewModel.nextPrayerIconName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.accentColor)
                    Text(viewModel.nextPrayerDisplayName)
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundColor(.primary)
                }

                Text(viewModel.countdownText)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.accentColor)
                    .monospacedDigit()
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primary.opacity(0.06))
            )
            .padding(.horizontal, 13)
            .padding(.bottom, 13)
        }
    }

    @ViewBuilder
    private func sidebarItem(_ tab: MainWindowTab, icon: String, label: String, showsBadge: Bool = false) -> some View {
        let isSelected = windowManager.selectedTab == tab
        Button {
            windowManager.selectedTab = tab
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(width: 18)
                Text(label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .primary)
                Spacer()
                if showsBadge {
                    PendingBadge(todoManager: todoManager)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.35) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Detail

    /// All three pages stay mounted; switching tabs only animates opacity.
    /// No view insertion/removal during animation — AppKit's addSubview inside
    /// NSAnimationContext (SwiftUI transitions) is what looped constraint
    /// invalidation on macOS 13 and crashed. Opacity never touches layout.
    private var detail: some View {
        ZStack {
            HomeWallpaperView(viewModel: viewModel)
                .opacity(windowManager.selectedTab == .home ? 1 : 0)
                .allowsHitTesting(windowManager.selectedTab == .home)

            TodoListView(todoManager: todoManager,
                         lang: viewModel.selectedLanguage,
                         viewModel: viewModel,
                         openItem: $paletteSelection)
                .opacity(windowManager.selectedTab == .todo ? 1 : 0)
                .allowsHitTesting(windowManager.selectedTab == .todo)

            SettingsView(viewModel: viewModel)
                .opacity(windowManager.selectedTab == .settings ? 1 : 0)
                .allowsHitTesting(windowManager.selectedTab == .settings)

            AboutView(language: viewModel.selectedLanguage)
                .opacity(windowManager.selectedTab == .about ? 1 : 0)
                .allowsHitTesting(windowManager.selectedTab == .about)
        }
        .animation(.easeInOut(duration: 0.18), value: windowManager.selectedTab)
    }
}

// MARK: - Home (wallpaper page)

/// Calm landing page: shows the wallpaper selected in the menu bar popover,
/// full-bleed, with the same wallpaper thumbnails to switch — nothing else.
private struct HomeWallpaperView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel

    private let wallpapers = ["AboutWallpaper", "EventWallpaper1", "EventWallpaper2", "EventWallpaper3"]

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                // Full-bleed wallpaper (synced with the popover's selection)
                Image(viewModel.selectedEventWallpaper)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .id(viewModel.selectedEventWallpaper)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.selectedEventWallpaper)

                // Soft bottom scrim so the thumbnails read on any image
                LinearGradient(
                    colors: [.clear, .black.opacity(0.45)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 96)

                // Wallpaper picker (same set as the popover's bottom bar)
                HStack(spacing: 13) {
                    ForEach(wallpapers, id: \.self) { wallpaper in
                        Button {
                            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.selectedEventWallpaper = wallpaper
                            }
                        } label: {
                            Image(wallpaper)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 34, height: 34)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().strokeBorder(
                                        viewModel.selectedEventWallpaper == wallpaper ? Color.white : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 21)
            }
        }
        .ignoresSafeArea()
    }
}
