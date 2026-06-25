//
//  NotificationManager.swift
//  DariSholat
//
//  Schedules macOS notifications for each prayer time using UNUserNotificationCenter.
//

import Foundation
import UserNotifications
import Adhan
import AppKit

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "notificationsEnabled")
        }
    }

    override init() {
        self.isEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        super.init()
        UNUserNotificationCenter.current().delegate = self
        // Check current status before requesting
        checkAndRequestPermission()
    }

    // MARK: - Permission

    func requestPermission() {
        checkAndRequestPermission(explicit: true)
    }

    private func checkAndRequestPermission(explicit: Bool = false) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch settings.authorizationStatus {
                case .notDetermined:
                    // First time — request permission
                    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if let error = error {
                            print("Notification permission error: \(error.localizedDescription)")
                        }
                        DispatchQueue.main.async {
                            if !granted {
                                self.isEnabled = false
                            }
                        }
                    }
                case .denied:
                    // Previously denied — disable and guide user to Settings
                    self.isEnabled = false
                    if explicit {
                        self.showPermissionDeniedAlert()
                    } else {
                        print("Notifications denied. Please enable in System Settings → Notifications → DariSholat")
                    }
                case .authorized, .provisional, .ephemeral:
                    // Already authorized — nothing to do
                    break
                @unknown default:
                    break
                }
            }
        }
    }

    private func showPermissionDeniedAlert() {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "id"
        let alert = NSAlert()
        alert.messageText = L10n.notificationPermissionDeniedTitle(lang)
        alert.informativeText = L10n.notificationPermissionDeniedMessage(lang)
        alert.alertStyle = .warning
        alert.addButton(withTitle: L10n.openSettings(lang))
        alert.addButton(withTitle: L10n.cancel(lang))
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            self.openNotificationSettings()
        }
    }

    /// Opens System Settings → Notifications
    func openNotificationSettings() {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        if let modernUrl = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(bundleId)"),
           NSWorkspace.shared.open(modernUrl) {
            return
        }
        if let oldUrl = URL(string: "x-apple.systempreferences:com.apple.preference.notifications?id=\(bundleId)") {
            NSWorkspace.shared.open(oldUrl)
        }
    }

    // MARK: - Schedule Notifications

    func schedulePrayerNotifications(prayers: PrayerTimes, language: String) {
        guard isEnabled else { return }

        // Verify we actually have permission before scheduling
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional else {
                DispatchQueue.main.async {
                    self?.isEnabled = false
                }
                return
            }

            // Remove all pending notifications first
            center.removeAllPendingNotificationRequests()

            self?.doSchedule(prayers: prayers, language: language, center: center)
        }
    }

    private func doSchedule(prayers: PrayerTimes, language: String, center: UNUserNotificationCenter) {

        let prayerList: [(Prayer, Date, String)] = [
            (.fajr,    prayers.fajr,    L10n.fajr(language)),
            (.dhuhr,   prayers.dhuhr,   L10n.dhuhr(language)),
            (.asr,     prayers.asr,     L10n.asr(language)),
            (.maghrib, prayers.maghrib, L10n.maghrib(language)),
            (.isha,    prayers.isha,    L10n.isha(language)),
        ]

        let now = Date()

        for (prayer, time, name) in prayerList {
            // Only schedule future notifications
            guard time > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "🕌 \(L10n.prayerReminder(language))"
            content.body = L10n.prayerTimeReached(language, prayerName: name)
            content.sound = .default
            content.categoryIdentifier = "PRAYER_NOTIFICATION"

            // Use the exact prayer time
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "prayer_\(prayer)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule \(name) notification: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Remove All

    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner even when app is in foreground
        completionHandler([.banner, .sound])
    }
}
