//
//  SettingsView.swift
//  darisholat
//
//  Settings layout matching the reference screenshot:
//  Section "Display"  → Menu Bar Style, Compact Main View, 24-Hour Time, Use Accent Color, Show Sunnah Prayers
//  Section "Calculation" → Method picker, Hanafi Madhhab toggle
//  Section "Location"    → Automatic location, Change Manual Location button
//  Section "System"      → Run at Login, Prayer Notifications
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: PrayerTimeViewModel
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            // ── Navigation header ─────────────────────────────────
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text(L10n.back(viewModel.selectedLanguage))
                            .font(.system(size: 13, weight: .regular))
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(L10n.settings(viewModel.selectedLanguage))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                // Balance spacer
                HStack(spacing: 3) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                    Text(L10n.back(viewModel.selectedLanguage))
                        .font(.system(size: 13))
                }
                .opacity(0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider().opacity(0.5)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ───────────────────────────────────────────────
                    // DISPLAY
                    // ───────────────────────────────────────────────
                    sectionHeader("Display")

                    settingsRow {
                        Text("Menu Bar Style")
                            .settingsLabel()
                        Spacer()
                        Picker("", selection: $viewModel.menuBarStyle) {
                            Text("Countdown").tag(MenuBarStyle.countdown)
                            Text("Prayer Time").tag(MenuBarStyle.prayerTime)
                            Text("Icon Only").tag(MenuBarStyle.iconOnly)
                            Text("Compact").tag(MenuBarStyle.compact)
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 130)
                    }

                    settingsDivider

                    settingsRow {
                        Text("Background Blur")
                            .settingsLabel()
                        Spacer()
                        Picker("", selection: $viewModel.blurStyle) {
                            ForEach(AppBlurStyle.allCases) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 130)
                    }
                    
                    if viewModel.blurStyle == .custom {
                        settingsRow {
                            Text("Blur Opacity")
                                .settingsLabel()
                            Spacer()
                            Slider(value: $viewModel.customBlurOpacity, in: 0.1...1.0)
                                .frame(width: 130)
                        }
                    }

                    settingsDivider

                    settingsRow {
                        Text("Compact Main View")
                            .settingsLabel()
                        Spacer()
                        Toggle("", isOn: $viewModel.compactMainView)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    settingsDivider

                    settingsRow {
                        Text("24-Hour Time")
                            .settingsLabel()
                        Spacer()
                        Toggle("", isOn: $viewModel.uses24HourTime)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    settingsDivider

                    settingsRow {
                        Text("Use Accent Color")
                            .settingsLabel()
                        Spacer()
                        Toggle("", isOn: $viewModel.useAccentColor)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    settingsDivider

                    settingsRow {
                        Text("Show Sunnah Prayers")
                            .settingsLabel()
                        Spacer()
                        Toggle("", isOn: $viewModel.showSunnahPrayers)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    // ───────────────────────────────────────────────
                    // CALCULATION
                    // ───────────────────────────────────────────────
                    sectionHeader("Calculation")

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
                        .frame(width: 130)
                    }

                    settingsDivider

                    settingsRow {
                        Text("Hanafi Madhhab")
                            .settingsLabel()
                        Spacer()
                        Toggle("", isOn: $viewModel.usesHanafi)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    // ───────────────────────────────────────────────
                    // LOCATION
                    // ───────────────────────────────────────────────
                    sectionHeader("Location")

                    settingsRow {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.accentColor)
                            Text("Automatic: \(viewModel.cityName)")
                                .settingsLabel()
                        }
                        Spacer()
                    }

                    settingsDivider

                    settingsRow {
                        Button(action: { viewModel.requestLocationUpdate() }) {
                            Text("Change Manual Location")
                                .font(.system(size: 13))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.primary.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .strokeBorder(Color.primary.opacity(0.15), lineWidth: 0.5)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    // ───────────────────────────────────────────────
                    // LANGUAGE (extra, matching localization feature)
                    // ───────────────────────────────────────────────
                    sectionHeader("Language")

                    settingsRow {
                        Text(L10n.language(viewModel.selectedLanguage))
                            .settingsLabel()
                        Spacer()
                        Picker("", selection: $viewModel.selectedLanguage) {
                            Text("🇮🇩 Bahasa Indonesia").tag("id")
                            Text("🇬🇧 English").tag("en")
                            Text("🇸🇦 العربية").tag("ar")
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 130)
                    }

                    // ───────────────────────────────────────────────
                    // SYSTEM
                    // ───────────────────────────────────────────────
                    sectionHeader("System")

                    settingsRow {
                        Text("Run at Login")
                            .settingsLabel()
                        Spacer()
                        Toggle("", isOn: $viewModel.runAtLogin)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    settingsDivider

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

                    Spacer(minLength: 16)
                }
                .padding(.top, 4)
            }
        }
        .frame(minHeight: 460)
    }

    // MARK: - Section header helper

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 4)
    }

    // MARK: - Row wrapper

    @ViewBuilder
    private func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack {
            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
    }

    private var settingsDivider: some View {
        Divider()
            .padding(.leading, 14)
            .opacity(0.35)
    }
}

// MARK: - Text extension

extension Text {
    func settingsLabel() -> some View {
        self.font(.system(size: 13, weight: .regular))
            .foregroundColor(.primary)
    }
}
