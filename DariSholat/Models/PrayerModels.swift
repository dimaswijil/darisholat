//
//  PrayerModels.swift
//  DariSholat
//

import Foundation
import Adhan

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

// MARK: - Indonesian City

struct IndonesianCity: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

// MARK: - Prayer Schedule Item

struct PrayerScheduleItem: Identifiable {
    let id = UUID()
    let prayer: Prayer
    let name: String
    let time: Date
}
