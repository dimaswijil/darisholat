//
//  MainWindowManager.swift
//  DariSholat
//
//  Owns the resizable desktop window (To-Do / Settings / About).
//  AppKit-managed (not a SwiftUI Window scene) so it can be opened
//  programmatically from the wake-from-sleep observer.
//

import AppKit
import SwiftUI

enum MainWindowTab: String, CaseIterable, Identifiable {
    case home, todo, settings, about
    var id: String { rawValue }
}

final class MainWindowManager: NSObject, ObservableObject {

    static let shared = MainWindowManager()

    @Published var selectedTab: MainWindowTab = .todo

    /// Sidebar visibility — lives here so the AppKit titlebar button and the
    /// SwiftUI content share one source of truth. Persisted across launches.
    @Published var sidebarVisible: Bool {
        didSet { UserDefaults.standard.set(sidebarVisible, forKey: "mainWindowSidebarVisible") }
    }

    private var window: NSWindow?

    private override init() {
        self.sidebarVisible = UserDefaults.standard.object(forKey: "mainWindowSidebarVisible") as? Bool ?? true
        super.init()
    }

    func toggleSidebar() {
        // No withAnimation here — the view's `.animation(value:)` modifier is
        // the single animation source. Two competing animations made repeated
        // toggles interrupt each other and feel stiff.
        sidebarVisible.toggle()
    }

    /// Opens (or focuses) the desktop window on the given tab.
    func show(tab: MainWindowTab, viewModel: PrayerTimeViewModel) {
        selectedTab = tab

        // The app is LSUIElement (menu bar only). While the desktop window is
        // open, become a regular app so the main menu (DariSholat / File /
        // Edit / Window / Help) and Cmd-W/Cmd-Q etc. work; revert on close.
        NSApp.setActivationPolicy(.regular)

        if window == nil {
            let content = MainWindowView(viewModel: viewModel, windowManager: self)
            let hosting = NSHostingView(rootView: content)
            // Don't let the hosting view drive AppKit constraints from its
            // SwiftUI intrinsic size — with animated content (sidebar slide)
            // that loops constraint invalidation on every frame ("more Update
            // Constraints passes than views" warning).
            hosting.sizingOptions = []

            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 860, height: 540),
                // NOTE: no .fullSizeContentView. The crash report points at
                // NSThemeFrame._opaqueFullSizeContentViewRegionWithClipRect —
                // macOS 13 recomputes the draggable titlebar region from the
                // SwiftUI hierarchy on every animation frame, loops constraint
                // invalidation, and eventually raises (SIGILL via
                // _crashOnException). Keeping content below the titlebar
                // avoids that code path entirely.
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            win.title = "DariSholat"
            win.titlebarAppearsTransparent = true
            win.titleVisibility = .hidden
            win.minSize = NSSize(width: 700, height: 440)

            // Isolate SwiftUI from the window's Auto Layout entirely: the
            // hosting view sits inside a plain autoresizing container, so its
            // constant animation-driven invalidations never reach NSWindow's
            // constraint engine (the source of the Update-Constraints loop).
            let container = NSView(frame: NSRect(x: 0, y: 0, width: 860, height: 540))
            container.autoresizesSubviews = true
            hosting.frame = container.bounds
            hosting.autoresizingMask = [.width, .height]
            hosting.translatesAutoresizingMaskIntoConstraints = true
            container.addSubview(hosting)

            win.contentView = container
            win.isReleasedWhenClosed = false
            win.delegate = self
            win.center()
            window = win
        }

        // Activate first, then order front — the reverse triggers AppKit's
        // "ordered front from a non-active application" warning.
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}

// MARK: - NSWindowDelegate

extension MainWindowManager: NSWindowDelegate {
    /// Tear down on close so the SwiftUI hierarchy stops re-rendering
    /// (the view model publishes every second) while the window is hidden,
    /// and go back to being a pure menu bar app (no dock icon / main menu).
    func windowWillClose(_ notification: Notification) {
        window?.contentView = nil
        window = nil
        NSApp.setActivationPolicy(.accessory)
    }
}
