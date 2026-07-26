//
//  CalendarEventsSectionView.swift
//  DariSholat
//

import SwiftUI

// MARK: - Calendar Events Section

struct CalendarEventsSectionView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel

    var body: some View {
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
            RamadanCountdownRow(viewModel: viewModel)

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
                // Event list — scrolls when there are many events
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.upcomingEvents) { event in
                            CalendarEventRow(
                                event: event,
                                lang: viewModel.selectedLanguage
                            )
                        }
                    }
                }
            }
        }
        .padding(.bottom, DS.f3)
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

// MARK: - Ramadan Countdown Row

struct RamadanCountdownRow: View {
    @ObservedObject var viewModel: PrayerTimeViewModel

    var body: some View {
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
