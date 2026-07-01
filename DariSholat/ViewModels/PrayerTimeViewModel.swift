//
//  PrayerTimeViewModel.swift
//  darisholat
//
//  Core ViewModel: Adhan prayer time calculation, countdown timer with seconds,
//  and prayer-related state management.
//

import Foundation
import SwiftUI
import Combine
import Adhan
import ServiceManagement
import EventKit

// MARK: - Navigation State

enum AppScreen {
    case main, settings, about
}

// MARK: - App Blur Style

enum AppBlurStyle: String, CaseIterable, Identifiable {
    case hud = "hud"
    case popover = "popover"
    case menu = "menu"
    case sidebar = "sidebar"
    case liquidGlass = "liquidGlass"
    case custom = "custom"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .hud: return "HUD (Dark Glass)"
        case .popover: return "Popover (Light)"
        case .menu: return "Menu (Standard)"
        case .sidebar: return "Sidebar"
        case .liquidGlass: return "Liquid Glass"
        case .custom: return "Custom..."
        }
    }
}

// MARK: - Menu Bar Style

enum MenuBarStyle: String, CaseIterable, Identifiable {
    case iconOnly   = "iconOnly"
    case compact    = "compact"
    var id: String { rawValue }
}

// MARK: - Accent Color Preset

enum AppAccentColor: String, CaseIterable, Identifiable {
    case white  = "white"
    case green  = "green"
    case blue   = "blue"
    case purple = "purple"
    case orange = "orange"
    case red    = "red"
    case yellow = "yellow"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .white:  return "White (Default)"
        case .green:  return "Green"
        case .blue:   return "Blue"
        case .purple: return "Purple"
        case .orange: return "Orange"
        case .red:    return "Red"
        case .yellow: return "Yellow"
        }
    }

    var color: Color {
        switch self {
        case .white:  return Color.white
        case .green:  return Color(red: 0.196, green: 0.784, blue: 0.439) // original accent
        case .blue:   return Color(red: 0.20, green: 0.50, blue: 0.95)
        case .purple: return Color(red: 0.58, green: 0.34, blue: 0.92)
        case .orange: return Color(red: 0.95, green: 0.55, blue: 0.20)
        case .red:    return Color(red: 0.92, green: 0.28, blue: 0.28)
        case .yellow: return Color.yellow
        }
    }

    var swatchColor: Color {
        color
    }
}

// MARK: - Calculation Method Enum

enum DariSholatMethod: String, CaseIterable, Identifiable {
    case kemenag = "kemenag"
    case mwl = "mwl"
    case isna = "isna"
    case ummAlQura = "ummalqura"
    case egyptian = "egyptian"
    case singapore = "singapore"
    case turkey = "turkey"
    case tehran = "tehran"
    case karachi = "karachi"
    case dubai = "dubai"
    case kuwait = "kuwait"
    case qatar = "qatar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kemenag:   return "Kemenag RI"
        case .mwl:       return "Muslim World League"
        case .isna:      return "ISNA (North America)"
        case .ummAlQura: return "Umm al-Qura (Makkah)"
        case .egyptian:  return "Egyptian Authority"
        case .singapore: return "Singapore (MUIS)"
        case .turkey:    return "Diyanet (Turkey)"
        case .tehran:    return "Tehran"
        case .karachi:   return "Karachi"
        case .dubai:     return "Dubai (AWQAF)"
        case .kuwait:    return "Kuwait"
        case .qatar:     return "Qatar"
        }
    }

    var params: CalculationParameters {
        switch self {
        case .kemenag:
            var p = CalculationMethod.other.params
            p.fajrAngle = 20.0
            p.ishaAngle = 18.0
            return p
        case .mwl:       return CalculationMethod.muslimWorldLeague.params
        case .isna:      return CalculationMethod.northAmerica.params
        case .ummAlQura: return CalculationMethod.ummAlQura.params
        case .egyptian:  return CalculationMethod.egyptian.params
        case .singapore: return CalculationMethod.singapore.params
        case .turkey:    return CalculationMethod.turkey.params
        case .tehran:    return CalculationMethod.tehran.params
        case .karachi:   return CalculationMethod.karachi.params
        case .dubai:     return CalculationMethod.dubai.params
        case .kuwait:    return CalculationMethod.kuwait.params
        case .qatar:     return CalculationMethod.qatar.params
        }
    }
}

// MARK: - Prayer Schedule Item

struct PrayerScheduleItem: Identifiable {
    let id = UUID()
    let prayer: Prayer
    let name: String
    let time: Date
}

// MARK: - PrayerTimeViewModel

class PrayerTimeViewModel: ObservableObject {

    // MARK: - Published UI State
    @Published var menuBarText: String = "DariSholat"
    @Published var currentScreen: AppScreen = .main
    @Published var countdownText: String = "--:--:--"
    @Published var nextPrayerDisplayName: String = ""
    @Published var nextPrayerIconName: String = "moon.stars.fill"
    @Published var currentPrayerDisplayName: String = ""
    @Published var prayerSchedule: [PrayerScheduleItem] = []
    @Published var currentHijriDate: String = ""
    @Published var cityName: String = "Mendeteksi..."
    @Published var isLocationAvailable: Bool = false

    // MARK: - Settings: Display
    @Published var menuBarStyle: MenuBarStyle {
        didSet {
            UserDefaults.standard.set(menuBarStyle.rawValue, forKey: "menuBarStyle")
            updateCountdown()
        }
    }
    @Published var compactMainView: Bool {
        didSet { UserDefaults.standard.set(compactMainView, forKey: "compactMainView") }
    }
    @Published var uses24HourTime: Bool {
        didSet { UserDefaults.standard.set(uses24HourTime, forKey: "uses24HourTime") }
    }
    @Published var useAccentColor: Bool {
        didSet { UserDefaults.standard.set(useAccentColor, forKey: "useAccentColor") }
    }
    @Published var showSunnahPrayers: Bool {
        didSet {
            UserDefaults.standard.set(showSunnahPrayers, forKey: "showSunnahPrayers")
            refreshPrayerTimes()
        }
    }
    @Published var showCalendarEvents: Bool {
        didSet {
            UserDefaults.standard.set(showCalendarEvents, forKey: "showCalendarEvents")
            if showCalendarEvents { calendarManager.requestAccess() }
        }
    }
    @Published var blurStyle: AppBlurStyle {
        didSet { UserDefaults.standard.set(blurStyle.rawValue, forKey: "blurStyle") }
    }
    @Published var customBlurOpacity: Double {
        didSet { UserDefaults.standard.set(customBlurOpacity, forKey: "customBlurOpacity") }
    }

    // MARK: - Settings: Event Wallpaper
    @Published var selectedEventWallpaper: String {
        didSet { UserDefaults.standard.set(selectedEventWallpaper, forKey: "selectedEventWallpaper") }
    }

    // MARK: - Settings: Accent Color
    @Published var appAccentColor: AppAccentColor {
        didSet { UserDefaults.standard.set(appAccentColor.rawValue, forKey: "appAccentColor") }
    }

    /// The resolved accent color based on preset
    var resolvedAccentColor: Color {
        return appAccentColor.color
    }

    // MARK: - Settings: Calculation
    @Published var selectedMethod: DariSholatMethod {
        didSet {
            UserDefaults.standard.set(selectedMethod.rawValue, forKey: "calculationMethod")
            refreshPrayerTimes()
        }
    }

    // MARK: - Settings: System
    @Published var runAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(runAtLogin, forKey: "runAtLogin")
            applyLoginItem()
        }
    }

    // MARK: - Settings: Language
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "appLanguage")
            refreshPrayerTimes()
        }
    }

    // MARK: - Managers
    private var locationManager = LocationManager()
    var notificationManager = NotificationManager()
    var calendarManager = CalendarManager()

    // MARK: - Ramadan Countdown
    @Published var daysToRamadan: Int = 0
    @Published var ramadanCountdownText: String = ""
    @Published var ramadanDateTooltip: String = ""
    @Published var isCurrentlyRamadan: Bool = false

    // MARK: - Calendar Events
    @Published var upcomingEvents: [CalendarEventItem] = []
    @Published var nextEventCountdown: String = ""
    @Published var isCalendarAuthorized: Bool = false
    @Published var availableCalendars: [EKCalendar] = []
    @Published var selectedCalendarIdentifiers: Set<String> = []

    // MARK: - Private
    private var timerCancellable: AnyCancellable?
    private var locationCancellable: AnyCancellable?
    private var cityCancellable: AnyCancellable?
    private var calendarCancellable: AnyCancellable?
    private var calendarAuthCancellable: AnyCancellable?
    private var calendarCalendarsCancellable: AnyCancellable?
    private var calendarSelCancellable: AnyCancellable?
    private var prayerTimes: PrayerTimes?
    private var lastCalculationDay: Int = -1  // day-of-year when prayer times were last calculated
    private var lastLatitude: Double = -6.2088  // Jakarta default
    private var lastLongitude: Double = 106.8456

    // MARK: - Init

    init() {
        let ud = UserDefaults.standard

        // Restore all persisted settings
        let methodRaw = ud.string(forKey: "calculationMethod") ?? "kemenag"
        self.selectedMethod   = DariSholatMethod(rawValue: methodRaw) ?? .kemenag
        self.selectedLanguage = ud.string(forKey: "appLanguage") ?? "id"

        let styleRaw = ud.string(forKey: "menuBarStyle") ?? "compact"
        self.menuBarStyle     = MenuBarStyle(rawValue: styleRaw) ?? .compact
        self.compactMainView  = ud.bool(forKey: "compactMainView")
        self.uses24HourTime   = ud.object(forKey: "uses24HourTime") as? Bool ?? true  // default 24h
        self.useAccentColor   = ud.object(forKey: "useAccentColor") as? Bool ?? true
        self.showSunnahPrayers = ud.bool(forKey: "showSunnahPrayers")
        self.showCalendarEvents = ud.object(forKey: "showCalendarEvents") as? Bool ?? true
        
        let blurRaw = ud.string(forKey: "blurStyle") ?? "hud"
        self.blurStyle        = AppBlurStyle(rawValue: blurRaw) ?? .hud
        self.customBlurOpacity = ud.object(forKey: "customBlurOpacity") as? Double ?? 0.85

        let accentRaw = ud.string(forKey: "appAccentColor") ?? "white"
        self.appAccentColor   = AppAccentColor(rawValue: accentRaw) ?? .white
        
        self.selectedEventWallpaper = ud.string(forKey: "selectedEventWallpaper") ?? "AboutWallpaper"

        self.runAtLogin       = ud.bool(forKey: "runAtLogin")

        setupLocationListener()
        startCountdownTimer()
        updateRamadanCountdown()
        setupCalendarListener()
    }

    // MARK: - Location Listener

    private func setupLocationListener() {
        locationCancellable = locationManager.$currentLocation
            .compactMap { $0 }
            .removeDuplicates(by: {
                abs($0.coordinate.latitude - $1.coordinate.latitude) < 0.001 &&
                abs($0.coordinate.longitude - $1.coordinate.longitude) < 0.001
            })
            .sink { [weak self] location in
                guard let self = self else { return }
                self.isLocationAvailable = true
                self.lastLatitude  = location.coordinate.latitude
                self.lastLongitude = location.coordinate.longitude
                self.calculatePrayerTimes(latitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude)
            }

        cityCancellable = locationManager.$cityName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in self?.cityName = name }
    }

    // MARK: - Prayer Time Calculation (Adhan)

    func calculatePrayerTimes(latitude: Double, longitude: Double) {
        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        let cal = Calendar(identifier: .gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())

        var params = selectedMethod.params
        params.madhab = .shafi

        guard let prayers = PrayerTimes(coordinates: coordinates, date: date,
                                        calculationParameters: params) else { return }
        self.prayerTimes = prayers
        self.lastCalculationDay = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? -1
        let lang = selectedLanguage

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            var schedule: [PrayerScheduleItem] = [
                PrayerScheduleItem(prayer: .fajr,    name: self.localizedPrayerName(.fajr, lang: lang),    time: prayers.fajr),
                PrayerScheduleItem(prayer: .dhuhr,   name: self.localizedPrayerName(.dhuhr, lang: lang),   time: prayers.dhuhr),
                PrayerScheduleItem(prayer: .asr,     name: self.localizedPrayerName(.asr, lang: lang),     time: prayers.asr),
                PrayerScheduleItem(prayer: .maghrib, name: self.localizedPrayerName(.maghrib, lang: lang), time: prayers.maghrib),
                PrayerScheduleItem(prayer: .isha,    name: self.localizedPrayerName(.isha, lang: lang),    time: prayers.isha),
            ]

            // Optionally include sunnah prayers
            if self.showSunnahPrayers {
                if let sunnah = SunnahTimes(from: prayers) {
                    schedule.insert(
                        PrayerScheduleItem(prayer: .sunrise, name: L10n.sunrise(lang), time: prayers.sunrise),
                        at: 1
                    )
                    _ = sunnah // SunnahTimes used for future Qiyam display
                }
            }

            self.prayerSchedule = schedule

            self.notificationManager.schedulePrayerNotifications(
                prayers: prayers,
                language: lang
            )
            self.updateCountdown()
        }
    }

    // MARK: - Countdown Timer (every second)

    private func startCountdownTimer() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCountdown()
                self?.updateCalendarCountdown()
                self?.checkMidnightReset()
            }
    }

    func updateCountdown() {
        guard let prayers = prayerTimes else {
            menuBarText  = "DariSholat"
            countdownText = "--:--:--"
            return
        }

        let now  = Date()
        let lang = selectedLanguage

        // Current prayer
        if let current = prayers.currentPrayer(at: now) {
            currentPrayerDisplayName = localizedPrayerName(current, lang: lang)
        }

        // Next prayer countdown
        if let nextPrayer = prayers.nextPrayer(at: now) {
            let nextTime = prayers.time(for: nextPrayer)
            let prayerName = localizedPrayerName(nextPrayer, lang: lang)
            nextPrayerDisplayName = prayerName
            nextPrayerIconName = prayerIconName(nextPrayer)

            let diff = nextTime.timeIntervalSince(now)
            if diff > 0 {
                let h = Int(diff) / 3600
                let m = (Int(diff) % 3600) / 60
                let s = Int(diff) % 60

                // Countdown: "1:52:23" (no leading zero on hours)
                countdownText = h > 0
                    ? "\(h):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
                    : "\(m):\(String(format: "%02d", s))"

                // Menu bar text based on style
                switch menuBarStyle {
                case .iconOnly:
                    menuBarText = ""
                case .compact:
                    menuBarText = h > 0
                        ? "\(prayerName) -\(h):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
                        : "\(prayerName) -\(m):\(String(format: "%02d", s))"
                }
            } else {
                menuBarText   = "\(prayerName) \(L10n.now(lang))"
                countdownText = L10n.now(lang)
            }
        } else {
            calculateTomorrowFajr(prayers: prayers, now: now, lang: lang)
        }
    }

    // MARK: - Next Fajr fallback (today or tomorrow)

    private func calculateTomorrowFajr(prayers: PrayerTimes, now: Date, lang: String) {
        let cal = Calendar(identifier: .gregorian)
        let coords = Coordinates(latitude: lastLatitude, longitude: lastLongitude)
        var params = selectedMethod.params
        params.madhab = .shafi

        // First, try TODAY's Fajr (handles midnight–Fajr window when prayerTimes is stale)
        let todayComponents = cal.dateComponents([.year, .month, .day], from: now)
        if let todayPrayers = PrayerTimes(coordinates: coords, date: todayComponents, calculationParameters: params) {
            let diffToday = todayPrayers.fajr.timeIntervalSince(now)
            if diffToday > 0 {
                // Today's Fajr is still upcoming — use it and force-refresh stale prayerTimes
                self.prayerTimes = todayPrayers
                self.lastCalculationDay = Calendar.current.ordinality(of: .day, in: .era, for: now) ?? -1
                applyFajrCountdown(diff: diffToday, lang: lang)
                return
            }
        }

        // Today's Fajr has passed — calculate tomorrow's
        guard let tomorrow = cal.date(byAdding: .day, value: 1, to: now) else { return }
        let tComponents = cal.dateComponents([.year, .month, .day], from: tomorrow)
        if let tp = PrayerTimes(coordinates: coords, date: tComponents, calculationParameters: params) {
            let diff = tp.fajr.timeIntervalSince(now)
            guard diff > 0 else { return }
            applyFajrCountdown(diff: diff, lang: lang)
        }
    }

    private func applyFajrCountdown(diff: TimeInterval, lang: String) {
        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        let s = Int(diff) % 60
        let fName = L10n.fajr(lang)
        nextPrayerDisplayName = fName
        nextPrayerIconName = prayerIconName(.fajr)
        countdownText = h > 0
            ? "\(h):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
            : "\(m):\(String(format: "%02d", s))"
        switch menuBarStyle {
        case .iconOnly:
            menuBarText = ""
        case .compact:
            menuBarText = h > 0
                ? "\(fName) -\(h):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
                : "\(fName) -\(m):\(String(format: "%02d", s))"
        }
    }

    private func checkMidnightReset() {
        let today = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? -1
        if today != lastCalculationDay {
            refreshPrayerTimes()
            updateRamadanCountdown()
        }
    }

    // MARK: - Ramadan Countdown (Islamic/Hijri Calendar)

    func updateRamadanCountdown() {
        let hijri = Calendar(identifier: .islamicUmmAlQura)
        let now = Date()
        let lang = selectedLanguage

        // Get current Hijri date
        let currentComponents = hijri.dateComponents([.year, .month, .day], from: now)
        let hijriFormatter = DateFormatter()
        hijriFormatter.calendar = hijri
        hijriFormatter.dateFormat = "d MMMM yyyy"
        hijriFormatter.locale = Locale(identifier: lang == "id" ? "id_ID" : lang == "ar" ? "ar_SA" : "en_US")
        currentHijriDate = hijriFormatter.string(from: now)
        
        guard let currentMonth = currentComponents.month,
              let currentYear = currentComponents.year else { return }

        // Ramadan is month 9 in the Islamic calendar
        let ramadanMonth = 9

        if currentMonth == ramadanMonth {
            // We are IN Ramadan right now
            isCurrentlyRamadan = true
            daysToRamadan = 0

            // Tooltip: show current Ramadan date range
            let currentDay = currentComponents.day ?? 1
            let hijriDateStr = "\(currentDay) Ramadan \(currentYear) H"
            let gregFormatter = DateFormatter()
            gregFormatter.dateFormat = "d MMMM yyyy"
            gregFormatter.locale = Locale(identifier: lang == "id" ? "id_ID" : lang == "ar" ? "ar_SA" : "en_US")
            let gregDateStr = gregFormatter.string(from: now)
            ramadanDateTooltip = "\(hijriDateStr)\n\(gregDateStr)"

            switch lang {
            case "ar": ramadanCountdownText = "رمضان مبارك!"
            case "id": ramadanCountdownText = "Ramadhan Mubarak!"
            default:   ramadanCountdownText = "Ramadan Mubarak!"
            }
            return
        }

        isCurrentlyRamadan = false

        // Calculate next Ramadan 1st
        var nextRamadanComponents = DateComponents()
        nextRamadanComponents.month = ramadanMonth
        nextRamadanComponents.day = 1

        if currentMonth < ramadanMonth {
            // Ramadan is later this Hijri year
            nextRamadanComponents.year = currentYear
        } else {
            // Ramadan already passed this Hijri year → next year
            nextRamadanComponents.year = currentYear + 1
        }

        guard let nextRamadanDate = hijri.date(from: nextRamadanComponents) else { return }

        // Calculate days between now and next Ramadan
        let gregorian = Calendar(identifier: .gregorian)
        let days = gregorian.dateComponents([.day], from: gregorian.startOfDay(for: now),
                                            to: gregorian.startOfDay(for: nextRamadanDate)).day ?? 0
        daysToRamadan = max(0, days)

        // Format tooltip with Gregorian + Hijri date
        let gregFormatter = DateFormatter()
        gregFormatter.dateFormat = "EEEE, d MMMM yyyy"
        gregFormatter.locale = Locale(identifier: lang == "id" ? "id_ID" : lang == "ar" ? "ar_SA" : "en_US")
        let gregDateStr = gregFormatter.string(from: nextRamadanDate)

        let targetYear = nextRamadanComponents.year ?? (currentYear + 1)
        let hijriLabel: String
        switch lang {
        case "ar": hijriLabel = "1 رمضان \(targetYear) هـ"
        case "id": hijriLabel = "1 Ramadhan \(targetYear) H"
        default:   hijriLabel = "1 Ramadan \(targetYear) AH"
        }
        ramadanDateTooltip = "\(hijriLabel)\n\(gregDateStr)"

        // Format countdown text
        switch lang {
        case "ar": ramadanCountdownText = "\(daysToRamadan) يوم"
        case "id": ramadanCountdownText = "\(daysToRamadan) hari"
        default:   ramadanCountdownText = "\(daysToRamadan) days"
        }
    }

    // MARK: - Run at Login

    private func applyLoginItem() {
        // ServiceManagement (macOS 13+): requires a Login Item helper / SMAppService
        // For now, stored in UserDefaults and handled on next launch check.
        // Full implementation requires SMAppService.mainApp.register()
        if #available(macOS 13.0, *) {
            if runAtLogin {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }

    // MARK: - Helpers

    func localizedPrayerName(_ prayer: Prayer, lang: String? = nil) -> String {
        let l = lang ?? selectedLanguage
        switch prayer {
        case .fajr:    return L10n.fajr(l)
        case .sunrise: return L10n.sunrise(l)
        case .dhuhr:
            let isFriday = Calendar.current.component(.weekday, from: Date()) == 6
            return isFriday ? L10n.jumuah(l) : L10n.dhuhr(l)
        case .asr:     return L10n.asr(l)
        case .maghrib: return L10n.maghrib(l)
        case .isha:    return L10n.isha(l)
        }
    }

    func prayerIconName(_ prayer: Prayer) -> String {
        switch prayer {
        case .fajr:    return "sunrise.fill"
        case .sunrise: return "sun.and.horizon.fill"
        case .dhuhr:   return "sun.max.fill"
        case .asr:     return "sun.min.fill"
        case .maghrib: return "sunset.fill"
        case .isha:    return "moon.stars.fill"
        }
    }

    func formattedTime(_ date: Date, use24h: Bool) -> String {
        let formatter = DateFormatter()
        // Dot-separator style: "04.13" — clean, no AM/PM clutter
        formatter.dateFormat = use24h ? "HH.mm" : "h.mm"
        switch selectedLanguage {
        case "ar": formatter.locale = Locale(identifier: "ar_SA")
        case "id": formatter.locale = Locale(identifier: "id_ID")
        default:   formatter.locale = Locale(identifier: "en_US")
        }
        return formatter.string(from: date)
    }

    func isNextPrayer(_ prayer: Prayer) -> Bool {
        if let next = prayerTimes?.nextPrayer(at: Date()) {
            return next == prayer
        } else {
            // All of today's prayers have passed, so the next prayer is tomorrow's Fajr.
            return prayer == .fajr
        }
    }

    func isCurrentPrayer(_ prayer: Prayer) -> Bool {
        prayerTimes?.currentPrayer(at: Date()) == prayer
    }

    func refreshPrayerTimes() {
        calculatePrayerTimes(latitude: lastLatitude, longitude: lastLongitude)
    }

    func requestLocationUpdate() {
        locationManager.requestLocation()
    }

    // MARK: - Calendar Integration

    private func setupCalendarListener() {
        calendarCancellable = calendarManager.$events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                guard let self = self else { return }
                // Show max 3 upcoming events
                self.upcomingEvents = Array(events.prefix(3))
                self.updateCalendarCountdown()
            }

        calendarAuthCancellable = calendarManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isCalendarAuthorized = self.calendarManager.isAuthorized
            }

        calendarCalendarsCancellable = calendarManager.$availableCalendars
            .receive(on: DispatchQueue.main)
            .sink { [weak self] calendars in
                self?.availableCalendars = calendars
            }

        calendarSelCancellable = calendarManager.$selectedCalendarIdentifiers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selected in
                self?.selectedCalendarIdentifiers = selected
            }

        // Request access if already enabled
        if showCalendarEvents {
            calendarManager.requestAccess()
        }
    }

    func toggleCalendar(identifier: String) {
        calendarManager.toggleCalendar(identifier: identifier)
    }

    func updateCalendarCountdown() {
        guard showCalendarEvents, let first = upcomingEvents.first else {
            nextEventCountdown = ""
            return
        }
        nextEventCountdown = first.countdownText(now: Date(), lang: selectedLanguage)
    }

    func refreshCalendarEvents() {
        calendarManager.fetchEvents()
    }
}
