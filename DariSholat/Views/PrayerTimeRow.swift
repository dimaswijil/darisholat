//
//  PrayerTimeRow.swift
//  DariSholat
//

import SwiftUI
import Adhan

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

    private var accent: Color { .accentColor }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Circular Icon with progress ring
            ZStack {
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
