//
//  Localization.swift
//  DariSholat
//
//  Multi-language support: English, Indonesian (Bahasa), Arabic
//

import Foundation

struct L10n {

    // MARK: - Prayer Names

    static func fajr(_ lang: String) -> String {
        switch lang {
        case "ar": return "الفجر"
        case "id": return "Subuh"
        default:   return "Fajr"
        }
    }

    static func sunrise(_ lang: String) -> String {
        switch lang {
        case "ar": return "الشروق"
        case "id": return "Terbit"
        default:   return "Sunrise"
        }
    }

    static func dhuhr(_ lang: String) -> String {
        switch lang {
        case "ar": return "الظهر"
        case "id": return "Dzuhur"
        default:   return "Dhuhr"
        }
    }

    static func asr(_ lang: String) -> String {
        switch lang {
        case "ar": return "العصر"
        case "id": return "Ashar"
        default:   return "Asr"
        }
    }

    static func maghrib(_ lang: String) -> String {
        switch lang {
        case "ar": return "المغرب"
        case "id": return "Maghrib"
        default:   return "Maghrib"
        }
    }

    static func isha(_ lang: String) -> String {
        switch lang {
        case "ar": return "العشاء"
        case "id": return "Isya"
        default:   return "Isha"
        }
    }

    // MARK: - UI Strings

    static func now(_ lang: String) -> String {
        switch lang {
        case "ar": return "الآن"
        case "id": return "Sekarang"
        default:   return "Now"
        }
    }

    static func settings(_ lang: String) -> String {
        switch lang {
        case "ar": return "الإعدادات"
        case "id": return "Pengaturan"
        default:   return "Settings"
        }
    }

    static func about(_ lang: String) -> String {
        switch lang {
        case "ar": return "حول"
        case "id": return "Tentang"
        default:   return "About"
        }
    }

    static func quit(_ lang: String) -> String {
        switch lang {
        case "ar": return "إنهاء"
        case "id": return "Keluar"
        default:   return "Quit"
        }
    }

    static func nextPrayer(_ lang: String) -> String {
        switch lang {
        case "ar": return "الصلاة القادمة"
        case "id": return "Sholat Berikutnya"
        default:   return "Next Prayer"
        }
    }

    static func calculationMethod(_ lang: String) -> String {
        switch lang {
        case "ar": return "طريقة الحساب"
        case "id": return "Metode Perhitungan"
        default:   return "Calculation Method"
        }
    }

    static func madhab(_ lang: String) -> String {
        switch lang {
        case "ar": return "المذهب"
        case "id": return "Mazhab"
        default:   return "Madhab"
        }
    }

    static func shafi(_ lang: String) -> String {
        switch lang {
        case "ar": return "شافعي"
        case "id": return "Syafi'i"
        default:   return "Shafi'i"
        }
    }

    static func hanafi(_ lang: String) -> String {
        switch lang {
        case "ar": return "حنفي"
        case "id": return "Hanafi"
        default:   return "Hanafi"
        }
    }

    static func notifications(_ lang: String) -> String {
        switch lang {
        case "ar": return "الإشعارات"
        case "id": return "Notifikasi"
        default:   return "Notifications"
        }
    }

    static func enableNotifications(_ lang: String) -> String {
        switch lang {
        case "ar": return "تفعيل الإشعارات"
        case "id": return "Aktifkan Notifikasi"
        default:   return "Enable Notifications"
        }
    }

    static func language(_ lang: String) -> String {
        switch lang {
        case "ar": return "اللغة"
        case "id": return "Bahasa"
        default:   return "Language"
        }
    }

    static func location(_ lang: String) -> String {
        switch lang {
        case "ar": return "الموقع"
        case "id": return "Lokasi"
        default:   return "Location"
        }
    }

    static func detecting(_ lang: String) -> String {
        switch lang {
        case "ar": return "جارٍ الكشف..."
        case "id": return "Mendeteksi..."
        default:   return "Detecting..."
        }
    }

    static func prayerTimeReached(_ lang: String, prayerName: String) -> String {
        switch lang {
        case "ar": return "حان وقت صلاة \(prayerName)"
        case "id": return "Waktu \(prayerName) telah tiba"
        default:   return "It's time for \(prayerName) prayer"
        }
    }

    static func prayerReminder(_ lang: String) -> String {
        switch lang {
        case "ar": return "تذكير بالصلاة"
        case "id": return "Pengingat Sholat"
        default:   return "Prayer Reminder"
        }
    }

    static func back(_ lang: String) -> String {
        switch lang {
        case "ar": return "رجوع"
        case "id": return "Kembali"
        default:   return "Back"
        }
    }

    static func version(_ lang: String) -> String {
        switch lang {
        case "ar": return "الإصدار"
        case "id": return "Versi"
        default:   return "Version"
        }
    }

    static func madeWith(_ lang: String) -> String {
        switch lang {
        case "ar": return "صنع بـ ❤️ للمسلمين"
        case "id": return "Dibuat dengan ❤️ untuk umat Muslim"
        default:   return "Made with ❤️ for Muslims"
        }
    }

    static func poweredBy(_ lang: String) -> String {
        switch lang {
        case "ar": return "مدعوم من Adhan Library"
        case "id": return "Didukung oleh Adhan Library"
        default:   return "Powered by Adhan Library"
        }
    }

    static func todaySchedule(_ lang: String) -> String {
        switch lang {
        case "ar": return "مواقيت اليوم"
        case "id": return "Jadwal Hari Ini"
        default:   return "Today's Schedule"
        }
    }

    // MARK: - Calendar Events

    static func events(_ lang: String) -> String {
        switch lang {
        case "ar": return "الأحداث"
        case "id": return "Acara"
        default:   return "Events"
        }
    }

    static func noEvents(_ lang: String) -> String {
        switch lang {
        case "ar": return "لا أحداث قادمة"
        case "id": return "Tidak ada acara mendatang"
        default:   return "No upcoming events"
        }
    }

    static func grantCalendarAccess(_ lang: String) -> String {
        switch lang {
        case "ar": return "السماح بالوصول للتقويم"
        case "id": return "Izinkan Akses Kalender"
        default:   return "Grant Calendar Access"
        }
    }

    static func tomorrow(_ lang: String) -> String {
        switch lang {
        case "ar": return "غداً"
        case "id": return "Besok"
        default:   return "Tomorrow"
        }
    }

    static func showCalendarEvents(_ lang: String) -> String {
        switch lang {
        case "ar": return "عرض أحداث التقويم"
        case "id": return "Tampilkan Acara Kalender"
        default:   return "Show Calendar Events"
        }
    }

    static func selectedCalendars(_ lang: String) -> String {
        switch lang {
        case "ar": return "تصفية التقويم"
        case "id": return "Filter Kalender"
        default:   return "Calendar Filters"
        }
    }

    // MARK: - Notification Permission Denied Alert

    static func notificationPermissionDeniedTitle(_ lang: String) -> String {
        switch lang {
        case "ar": return "تم رفض إذن الإشعارات"
        case "id": return "Izin Notifikasi Ditolak"
        default:   return "Notification Permission Denied"
        }
    }

    static func notificationPermissionDeniedMessage(_ lang: String) -> String {
        switch lang {
        case "ar": return "يرجى تمكين الإشعارات لـ DariSholat في إعدادات النظام لتلقي تنبيهات الصلاة."
        case "id": return "Silakan aktifkan notifikasi untuk DariSholat di Pengaturan Sistem untuk menerima peringatan sholat."
        default:   return "Please enable notifications for DariSholat in System Settings to receive prayer alerts."
        }
    }

    static func openSettings(_ lang: String) -> String {
        switch lang {
        case "ar": return "فتح الإعدادات"
        case "id": return "Buka Pengaturan"
        default:   return "Open Settings"
        }
    }

    static func cancel(_ lang: String) -> String {
        switch lang {
        case "ar": return "إلغاء"
        case "id": return "Batal"
        default:   return "Cancel"
        }
    }

    // MARK: - Ramadan Countdown

    static func ramadan(_ lang: String) -> String {
        switch lang {
        case "ar": return "رمضان"
        case "id": return "Ramadhan"
        default:   return "Ramadan"
        }
    }

    static func ramadanCountdownLabel(_ lang: String) -> String {
        switch lang {
        case "ar": return "حتى رمضان"
        case "id": return "Menuju Ramadhan"
        default:   return "Until Ramadan"
        }
    }
}
