//
//  PrayerTimeViewModel.swift
//  darisholat
//
//  Core ViewModel: Adhan prayer time calculation, countdown timer with seconds,
//  and prayer-related state management.
//

import Foundation
import Combine
import Adhan
import ServiceManagement

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
    case countdown  = "countdown"
    case prayerTime = "prayerTime"
    case iconOnly   = "iconOnly"
    case compact    = "compact"
    var id: String { rawValue }
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
    @Published var menuBarText: String = "darisholat"
    @Published var countdownText: String = "--:--:--"
    @Published var nextPrayerDisplayName: String = ""
    @Published var currentPrayerDisplayName: String = ""
    @Published var prayerSchedule: [PrayerScheduleItem] = []
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
    @Published var blurStyle: AppBlurStyle {
        didSet { UserDefaults.standard.set(blurStyle.rawValue, forKey: "blurStyle") }
    }
    @Published var customBlurOpacity: Double {
        didSet { UserDefaults.standard.set(customBlurOpacity, forKey: "customBlurOpacity") }
    }

    // MARK: - Settings: Calculation
    @Published var selectedMethod: DariSholatMethod {
        didSet {
            UserDefaults.standard.set(selectedMethod.rawValue, forKey: "calculationMethod")
            refreshPrayerTimes()
        }
    }
    @Published var usesHanafi: Bool {
        didSet {
            UserDefaults.standard.set(usesHanafi, forKey: "usesHanafi")
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

    // MARK: - Private
    private var timerCancellable: AnyCancellable?
    private var locationCancellable: AnyCancellable?
    private var cityCancellable: AnyCancellable?
    private var prayerTimes: PrayerTimes?
    private var lastLatitude: Double = -6.2088  // Jakarta default
    private var lastLongitude: Double = 106.8456

    // MARK: - Init

    init() {
        let ud = UserDefaults.standard

        // Restore all persisted settings
        let methodRaw = ud.string(forKey: "calculationMethod") ?? "kemenag"
        self.selectedMethod   = DariSholatMethod(rawValue: methodRaw) ?? .kemenag
        self.usesHanafi       = ud.bool(forKey: "usesHanafi")
        self.selectedLanguage = ud.string(forKey: "appLanguage") ?? "id"

        let styleRaw = ud.string(forKey: "menuBarStyle") ?? "countdown"
        self.menuBarStyle     = MenuBarStyle(rawValue: styleRaw) ?? .countdown
        self.compactMainView  = ud.bool(forKey: "compactMainView")
        self.uses24HourTime   = ud.object(forKey: "uses24HourTime") as? Bool ?? true  // default 24h
        self.useAccentColor   = ud.object(forKey: "useAccentColor") as? Bool ?? true
        self.showSunnahPrayers = ud.bool(forKey: "showSunnahPrayers")
        
        let blurRaw = ud.string(forKey: "blurStyle") ?? "liquidGlass"
        self.blurStyle        = AppBlurStyle(rawValue: blurRaw) ?? .liquidGlass
        self.customBlurOpacity = ud.object(forKey: "customBlurOpacity") as? Double ?? 0.85
        
        self.runAtLogin       = ud.bool(forKey: "runAtLogin")

        setupLocationListener()
        startCountdownTimer()
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
        params.madhab = usesHanafi ? .hanafi : .shafi

        guard let prayers = PrayerTimes(coordinates: coordinates, date: date,
                                        calculationParameters: params) else { return }
        self.prayerTimes = prayers
        let lang = selectedLanguage

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            var schedule: [PrayerScheduleItem] = [
                PrayerScheduleItem(prayer: .fajr,    name: L10n.fajr(lang),    time: prayers.fajr),
                PrayerScheduleItem(prayer: .dhuhr,   name: L10n.dhuhr(lang),   time: prayers.dhuhr),
                PrayerScheduleItem(prayer: .asr,     name: L10n.asr(lang),     time: prayers.asr),
                PrayerScheduleItem(prayer: .maghrib, name: L10n.maghrib(lang), time: prayers.maghrib),
                PrayerScheduleItem(prayer: .isha,    name: L10n.isha(lang),    time: prayers.isha),
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
                self?.checkMidnightReset()
            }
    }

    func updateCountdown() {
        guard let prayers = prayerTimes else {
            menuBarText  = "darisholat"
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
                case .countdown:
                    menuBarText = h > 0
                        ? "\(prayerName) \(h):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
                        : "\(prayerName) \(m):\(String(format: "%02d", s))"
                case .prayerTime:
                    let formatted = formattedTime(nextTime, use24h: uses24HourTime)
                    menuBarText = "\(prayerName) \(formatted)"
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

    // MARK: - Tomorrow Fajr fallback

    private func calculateTomorrowFajr(prayers: PrayerTimes, now: Date, lang: String) {
        let cal = Calendar(identifier: .gregorian)
        guard let tomorrow = cal.date(byAdding: .day, value: 1, to: now) else { return }
        let tComponents = cal.dateComponents([.year, .month, .day], from: tomorrow)
        let coords      = Coordinates(latitude: lastLatitude, longitude: lastLongitude)
        var params      = selectedMethod.params
        params.madhab   = usesHanafi ? .hanafi : .shafi

        if let tp = PrayerTimes(coordinates: coords, date: tComponents, calculationParameters: params) {
            let diff = tp.fajr.timeIntervalSince(now)
            guard diff > 0 else { return }
            let h = Int(diff) / 3600
            let m = (Int(diff) % 3600) / 60
            let s = Int(diff) % 60
            let fName = L10n.fajr(lang)
            nextPrayerDisplayName = fName
            countdownText = h > 0
                ? "\(h):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
                : "\(m):\(String(format: "%02d", s))"
            menuBarText = h > 0
                ? "\(fName) \(h):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
                : "\(fName) \(m):\(String(format: "%02d", s))"
        }
    }

    private func checkMidnightReset() {
        let c = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        if c.hour == 0 && c.minute == 0 && c.second == 0 { refreshPrayerTimes() }
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
        case .dhuhr:   return L10n.dhuhr(l)
        case .asr:     return L10n.asr(l)
        case .maghrib: return L10n.maghrib(l)
        case .isha:    return L10n.isha(l)
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
        prayerTimes?.nextPrayer(at: Date()) == prayer
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
}
