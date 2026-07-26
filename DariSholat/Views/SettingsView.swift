//
//  SettingsView.swift
//  darisholat
//
//  Settings layout matching the reference screenshot and optimized using
//  the Golden Ratio (φ = 1.618) and Fibonacci spacing tokens.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            // Partition columns based on Golden Ratio, keeping a minimum width for the right column
            let rightWidth = max(210, totalWidth * 0.382)
            let leftWidth = totalWidth - rightWidth

            VStack(spacing: 0) {

                // ── Navigation header ─────────────────────────────────
                HStack {
                    Spacer()

                    Text(L10n.settings(viewModel.selectedLanguage))
                        .font(.system(size: 15, weight: .bold, design: .rounded)) // Golden ratio scaled title
                        .foregroundColor(.primary)

                    Spacer()
                }
                .frame(height: 21) // Fibonacci f21
                .padding(.horizontal, 13) // Fibonacci f13
                .padding(.top, 24)        // clears macOS traffic lights & aligns with sidebar
                .padding(.bottom, 5)      // Fibonacci f5

                Divider().opacity(0.35) // Match main view divider opacity

                HStack(alignment: .top, spacing: 0) {
                    // Left Column: General & Notifications (width: Golden ratio proportional)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 8) { // Fibonacci f8 spacing

                            // ───────────────────────────────────────────────
                            // GENERAL
                            // ───────────────────────────────────────────────
                            sectionHeader("General")

                            settingsCard {
                                settingsRow {
                                    Text("24-Hour Time")
                                        .settingsLabel()
                                    Spacer()
                                    Toggle("", isOn: $viewModel.uses24HourTime)
                                        .toggleStyle(.switch)
                                        .labelsHidden()
                                }

                                cardDivider

                                settingsRow {
                                    Text("Run at Login")
                                        .settingsLabel()
                                    Spacer()
                                    Toggle("", isOn: $viewModel.runAtLogin)
                                        .toggleStyle(.switch)
                                        .labelsHidden()
                                }

                                cardDivider

                                settingsRow {
                                    Text(L10n.language(viewModel.selectedLanguage))
                                        .settingsLabel()
                                    Spacer()
                                    Picker("", selection: $viewModel.selectedLanguage) {
                                        Text("🇮🇩 Bahasa").tag("id")
                                        Text("🇬🇧 English").tag("en")
                                        Text("🇸🇦 العربية").tag("ar")
                                        Text("🇹🇷 Türkçe").tag("tr")
                                        Text("🇯🇵 日本語").tag("ja")
                                        Text("🇰🇿 Қазақша").tag("kk")
                                        Text("🇮🇷 فارسی").tag("fa")
                                        Text("🇵🇰 اردو").tag("ur")
                                        Text("🇲🇾 Melayu").tag("ms")
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 130) // wider for Қазақша, فارسی etc.
                                }
                            }

                            // ───────────────────────────────────────────────
                            // NOTIFICATIONS
                            // ───────────────────────────────────────────────
                            sectionHeader("Notifications")

                            settingsCard {
                                settingsRow {
                                    Text("Prayer Notifications")
                                        .settingsLabel()
                                    Spacer()
                                    Toggle("", isOn: $viewModel.notificationManager.isEnabled)
                                        .toggleStyle(.switch)
                                        .labelsHidden()
                                        .onChange(of: viewModel.notificationManager.isEnabled) { enabled in
                                            if enabled {
                                                viewModel.notificationManager.requestPermission()
                                                viewModel.refreshPrayerTimes()
                                            } else {
                                                viewModel.notificationManager.removeAllNotifications()
                                            }
                                        }
                                }
                            }

                            Spacer(minLength: 13) // Fibonacci f13
                        }
                        .padding(.top, 8) // Fibonacci f8
                    }
                    .frame(width: leftWidth)

                    Divider()

                    // Right Column: Location, Calculation & Theme (width: Golden ratio proportional)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 8) { // Fibonacci f8 spacing

                            // ───────────────────────────────────────────────
                            // LOCATION & CALCULATION
                            // ───────────────────────────────────────────────
                            sectionHeader("Location & Calculation")

                            settingsCard {
                                settingsRow {
                                    Text("Method")
                                        .settingsLabel()
                                    Spacer()
                                    Picker("", selection: $viewModel.selectedMethod) {
                                        ForEach(DariSholatMethod.allCases) { method in
                                            Text(method.displayName).tag(method)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 140) // wider for "Kemenag (Indonesia)"
                                }

                                cardDivider

                                settingsRow {
                                    HStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.accentColor.opacity(0.12))
                                                .frame(width: 24, height: 24)
                                            Image(systemName: "location.fill")
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.accentColor)
                                        }
                                        Text("Automatic: \(viewModel.cityName)")
                                            .settingsLabel()
                                    }
                                    Spacer()
                                }

                                cardDivider

                                settingsRow {
                                    Button(action: { viewModel.requestLocationUpdate() }) {
                                        Text("Change Manual Location")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 5)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.primary.opacity(0.06))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            // ───────────────────────────────────────────────
                            // THEME
                            // ───────────────────────────────────────────────
                            sectionHeader("Theme")

                            settingsCard {
                                settingsRow {
                                    Text("Accent Color")
                                        .settingsLabel()
                                    Spacer()
                                    Picker("", selection: $viewModel.appAccentColor) {
                                        ForEach(AppAccentColor.allCases) { color in
                                            HStack {
                                                Circle()
                                                    .fill(color.swatchColor)
                                                    .overlay(
                                                        Circle().strokeBorder(Color.primary.opacity(0.2), lineWidth: 0.5)
                                                    )
                                                    .frame(width: 10, height: 10)
                                                Text(color.displayName)
                                            }.tag(color)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 100)
                                }
                            }

                            Spacer(minLength: 13) // Fibonacci f13
                        }
                        .padding(.top, 8) // Fibonacci f8
                    }
                    .frame(width: rightWidth)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(minHeight: 460)
    }

    // MARK: - Section header helper

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 13) // Fibonacci f13
            .padding(.top, 13)        // Fibonacci f13
            .padding(.bottom, 5)       // Fibonacci f5
    }

    // MARK: - Row wrapper

    @ViewBuilder
    private func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack {
            content()
        }
        .padding(.horizontal, 13) // Fibonacci f13
        .padding(.vertical, 8)     // Fibonacci f8
    }

    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 8) // Fibonacci f8
                .fill(Color.primary.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8) // Fibonacci f8
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 13) // Fibonacci f13
    }

    private var cardDivider: some View {
        Divider()
            .opacity(0.1)
            .padding(.horizontal, 13) // Fibonacci f13
    }
}

// MARK: - Text extension

extension Text {
    func settingsLabel() -> some View {
        self.font(.system(size: 13, weight: .regular))
            .foregroundColor(.primary)
    }
}
