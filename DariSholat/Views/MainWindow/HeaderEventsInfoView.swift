//
//  HeaderEventsInfoView.swift
//  DariSholat
//

import SwiftUI

// MARK: - Header Events Info (hijri date + upcoming events, right-aligned)

/// Compact glance card in the To-Doing header: hijri date on top, then
/// Ramadan countdown and the next couple of calendar events — mirroring the
/// menu bar popover's Events column.
struct HeaderEventsInfo: View {
    @ObservedObject var viewModel: PrayerTimeViewModel
    let lang: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Hijri date header
            HStack(spacing: 5) {
                Image(systemName: "calendar")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.accentColor.opacity(0.9))
                Text(viewModel.currentHijriDate + (lang == "id" ? " H" : " AH"))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.9))
            }

            Divider().opacity(0.25)

            // Ramadan countdown
            infoRow(icon: "moon.stars.fill",
                    title: L10n.ramadan(lang),
                    value: viewModel.ramadanCountdownText)

            // Next up to 2 calendar events
            ForEach(viewModel.upcomingEvents.prefix(2)) { event in
                infoRow(icon: "calendar.badge.clock",
                        title: event.title,
                        value: event.countdownText(lang: lang))
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .frame(width: 233) // 144 · φ — fixed so rows align in one grid
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(0.05))
        )
    }

    /// Icon + title lead from the left, value trails right — one aligned grid.
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(.secondary.opacity(0.8))
                .frame(width: 12)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.primary.opacity(0.85))
                .monospacedDigit()
                .lineLimit(1)
        }
    }
}

// MARK: - Pending Badge

/// Capsule counter of unfinished tasks; observes TodoManager directly so it
/// re-renders exactly when todos change (used in popover row + window sidebar).
struct PendingBadge: View {
    @ObservedObject var todoManager: TodoManager

    var body: some View {
        if todoManager.pendingCount > 0 {
            Text("\(todoManager.pendingCount)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.accentColor.opacity(0.8)))
        }
    }
}
