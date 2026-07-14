//
//  HabitManager.swift
//  DariSholat
//
//  Tracks daily prayer completion ("sudah sholat / belum") per fard prayer,
//  persists history to UserDefaults, and computes the current/best streak
//  (consecutive days where all 5 fard prayers were marked as prayed).
//

import Foundation
import Combine
import Adhan

/// One day's completion record, keyed by `Prayer.rawValueKey`.
typealias DailyPrayerLog = [String: Bool]

class HabitManager: ObservableObject {

    // MARK: - Published State
    @Published private(set) var todayLog: DailyPrayerLog = [:]
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var bestStreak: Int = 0

    // MARK: - Tracked Prayers (fard only — sunrise/syuruq is not a prayer)
    let trackedPrayers: [Prayer] = [.fajr, .dhuhr, .asr, .maghrib, .isha]

    // MARK: - Storage
    private let defaults = UserDefaults.standard
    private let storageKey = "prayerHabitLog"        // [String: DailyPrayerLog] keyed by "yyyy-MM-dd"
    private let bestStreakKey = "prayerHabitBestStreak"

    private var allLogs: [String: DailyPrayerLog] = [:]
    private var todayKey: String = ""

    // MARK: - Init

    init() {
        loadAll()
        todayKey = Self.dayKey(for: Date())
        todayLog = allLogs[todayKey] ?? [:]
        bestStreak = defaults.integer(forKey: bestStreakKey)
        recalculateStreak()
    }

    // MARK: - Day Key Formatting

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - Persistence

    private func loadAll() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: DailyPrayerLog].self, from: data) else {
            allLogs = [:]
            return
        }
        allLogs = decoded
    }

    private func saveAll() {
        guard let data = try? JSONEncoder().encode(allLogs) else { return }
        defaults.set(data, forKey: storageKey)
    }

    // MARK: - Day Rollover

    /// Call on midnight reset so `todayLog` reflects the correct (new) day.
    func refreshForToday() {
        let key = Self.dayKey(for: Date())
        guard key != todayKey else { return }
        todayKey = key
        todayLog = allLogs[todayKey] ?? [:]
        recalculateStreak()
    }

    // MARK: - Mutations

    func toggle(_ prayer: Prayer) {
        let current = todayLog[prayer.rawValueKey] ?? false
        setPrayed(!current, for: prayer)
    }

    /// Marks a prayer as done. Used by the "Prayed" notification action.
    func markPrayed(_ prayer: Prayer) {
        setPrayed(true, for: prayer)
    }

    private func setPrayed(_ value: Bool, for prayer: Prayer) {
        todayLog[prayer.rawValueKey] = value
        allLogs[todayKey] = todayLog
        saveAll()
        recalculateStreak()
    }

    // MARK: - Today Progress

    func isPrayed(_ prayer: Prayer) -> Bool {
        todayLog[prayer.rawValueKey] == true
    }

    /// e.g. "3/5"
    var todayProgressText: String {
        "\(prayedTodayCount)/\(trackedPrayers.count)"
    }

    var todayProgressRatio: Double {
        trackedPrayers.isEmpty ? 0 : Double(prayedTodayCount) / Double(trackedPrayers.count)
    }

    var isTodayComplete: Bool {
        isComplete(todayLog)
    }

    private var prayedTodayCount: Int {
        trackedPrayers.filter { todayLog[$0.rawValueKey] == true }.count
    }

    // MARK: - Streak Calculation

    /// Consecutive days (ending yesterday or today) where all 5 fard prayers were marked done.
    private func recalculateStreak() {
        let cal = Calendar(identifier: .gregorian)
        var streak = 0
        var cursor = Date()

        // Today still "in progress" shouldn't break an ongoing streak — only count
        // it once complete; otherwise start counting from yesterday.
        if !isTodayComplete {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: cursor) else {
                currentStreak = 0
                return
            }
            cursor = yesterday
        }

        while true {
            let key = Self.dayKey(for: cursor)
            guard let log = allLogs[key], isComplete(log) else { break }
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }

        currentStreak = streak
        if streak > bestStreak {
            bestStreak = streak
            defaults.set(bestStreak, forKey: bestStreakKey)
        }
    }

    private func isComplete(_ log: DailyPrayerLog) -> Bool {
        trackedPrayers.allSatisfy { log[$0.rawValueKey] == true }
    }
}

// MARK: - Prayer Raw Key Helper

extension Prayer {
    /// Stable string key for persistence/notification userInfo (independent of
    /// any future changes to the Adhan library's internal representation).
    var rawValueKey: String {
        switch self {
        case .fajr:    return "fajr"
        case .sunrise: return "sunrise"
        case .dhuhr:   return "dhuhr"
        case .asr:     return "asr"
        case .maghrib: return "maghrib"
        case .isha:    return "isha"
        }
    }

    static func from(rawValueKey: String) -> Prayer? {
        switch rawValueKey {
        case "fajr":    return .fajr
        case "sunrise": return .sunrise
        case "dhuhr":   return .dhuhr
        case "asr":     return .asr
        case "maghrib": return .maghrib
        case "isha":    return .isha
        default:        return nil
        }
    }
}
