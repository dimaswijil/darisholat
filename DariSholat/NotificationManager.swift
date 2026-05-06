//
//  NotificationManager.swift
//  DariSholat
//
//  Schedules macOS notifications for each prayer time using UNUserNotificationCenter.
//

import Foundation
import UserNotifications
import Adhan

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
        requestPermission()
    }

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                if !granted {
                    self.isEnabled = false
                }
            }
        }
    }

    // MARK: - Schedule Notifications

    func schedulePrayerNotifications(prayers: PrayerTimes, language: String) {
        guard isEnabled else { return }

        // Remove all pending notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

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
