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
        case "tr": return "İmsak"
        case "ja": return "ファジル"
        case "kk": return "Таң"
        case "fa": return "فجر"
        case "ur": return "فجر"
        case "ms": return "Subuh"
        default:   return "Fajr"
        }
    }

    static func sunrise(_ lang: String) -> String {
        switch lang {
        case "ar": return "الشروق"
        case "id": return "Terbit"
        case "tr": return "Güneş"
        case "ja": return "日の出"
        case "kk": return "Күннің шығуы"
        case "fa": return "طلوع آفتاب"
        case "ur": return "طلوع آفتاب"
        case "ms": return "Syuruk"
        default:   return "Sunrise"
        }
    }

    
    static func jumuah(_ lang: String) -> String {
        switch lang {
        case "ar": return "الجمعة"
        case "id": return "Jumat"
        case "tr": return "Cuma"
        case "ja": return "ジュムア"
        case "kk": return "Жұма"
        case "fa": return "جمعه"
        case "ur": return "جمعہ"
        case "ms": return "Jumaat"
        default:   return "Jumu'ah"
        }
    }

    static func dhuhr(_ lang: String) -> String {
        switch lang {
        case "ar": return "الظهر"
        case "id": return "Dzuhur"
        case "tr": return "Öğle"
        case "ja": return "ズフル"
        case "kk": return "Бесін"
        case "fa": return "ظهر"
        case "ur": return "ظہر"
        case "ms": return "Zohor"
        default:   return "Dhuhr"
        }
    }

    static func asr(_ lang: String) -> String {
        switch lang {
        case "ar": return "العصر"
        case "id": return "Ashar"
        case "tr": return "İkindi"
        case "ja": return "アスル"
        case "kk": return "Екінті"
        case "fa": return "عصر"
        case "ur": return "عصر"
        case "ms": return "Asar"
        default:   return "Asr"
        }
    }

    static func maghrib(_ lang: String) -> String {
        switch lang {
        case "ar": return "المغرب"
        case "id": return "Maghrib"
        case "tr": return "Akşam"
        case "ja": return "マグリブ"
        case "kk": return "Ақшам"
        case "fa": return "مغرب"
        case "ur": return "مغرب"
        case "ms": return "Maghrib"
        default:   return "Maghrib"
        }
    }

    static func isha(_ lang: String) -> String {
        switch lang {
        case "ar": return "العشاء"
        case "id": return "Isya"
        case "tr": return "Yatsı"
        case "ja": return "イシャー"
        case "kk": return "Құптан"
        case "fa": return "عشاء"
        case "ur": return "عشاء"
        case "ms": return "Isyak"
        default:   return "Isha"
        }
    }

    // MARK: - UI Strings

    static func now(_ lang: String) -> String {
        switch lang {
        case "ar": return "الآن"
        case "id": return "Sekarang"
        case "tr": return "Şimdi"
        case "ja": return "今"
        case "kk": return "Қазір"
        case "fa": return "اکنون"
        case "ur": return "اب"
        case "ms": return "Sekarang"
        default:   return "Now"
        }
    }

    static func settings(_ lang: String) -> String {
        switch lang {
        case "ar": return "الإعدادات"
        case "id": return "Pengaturan"
        case "tr": return "Ayarlar"
        case "ja": return "設定"
        case "kk": return "Параметрлер"
        case "fa": return "تنظیمات"
        case "ur": return "ترتیبات"
        case "ms": return "Tetapan"
        default:   return "Settings"
        }
    }

    static func about(_ lang: String) -> String {
        switch lang {
        case "ar": return "حول"
        case "id": return "Tentang"
        case "tr": return "Hakkında"
        case "ja": return "概要"
        case "kk": return "Туралы"
        case "fa": return "درباره"
        case "ur": return "کے بارے میں"
        case "ms": return "Tentang"
        default:   return "About"
        }
    }

    static func quit(_ lang: String) -> String {
        switch lang {
        case "ar": return "إنهاء"
        case "id": return "Keluar"
        case "tr": return "Çıkış"
        case "ja": return "終了"
        case "kk": return "Шығу"
        case "fa": return "خروج"
        case "ur": return "باہر نکلیں"
        case "ms": return "Keluar"
        default:   return "Quit"
        }
    }

    static func nextPrayer(_ lang: String) -> String {
        switch lang {
        case "ar": return "الصلاة القادمة"
        case "id": return "Sholat Berikutnya"
        case "tr": return "Sonraki Vakit"
        case "ja": return "次の礼拝"
        case "kk": return "Келесі уақыт"
        case "fa": return "نماز بعدی"
        case "ur": return "اگلی نماز"
        case "ms": return "Solat Seterusnya"
        default:   return "Next Prayer"
        }
    }

    static func calculationMethod(_ lang: String) -> String {
        switch lang {
        case "ar": return "طريقة الحساب"
        case "id": return "Metode Perhitungan"
        case "tr": return "Hesaplama Yöntemi"
        case "ja": return "計算方法"
        case "kk": return "Есептеу әдісі"
        case "fa": return "روش محاسبه"
        case "ur": return "حساب کا طریقہ"
        case "ms": return "Kaedah Pengiraan"
        default:   return "Calculation Method"
        }
    }

    static func madhab(_ lang: String) -> String {
        switch lang {
        case "ar": return "المذهب"
        case "id": return "Mazhab"
        case "tr": return "Mezhep"
        case "ja": return "マズハブ"
        case "kk": return "Мәзһаб"
        case "fa": return "مذهب"
        case "ur": return "فقہ"
        case "ms": return "Mazhab"
        default:   return "Madhab"
        }
    }

    static func shafi(_ lang: String) -> String {
        switch lang {
        case "ar": return "شافعي"
        case "id": return "Syafi'i"
        case "tr": return "Şafii"
        case "ja": return "シャーフィイー"
        case "kk": return "Шафии"
        case "fa": return "شافعی"
        case "ur": return "شافعی"
        case "ms": return "Syafi'i"
        default:   return "Shafi'i"
        }
    }

    static func hanafi(_ lang: String) -> String {
        switch lang {
        case "ar": return "حنفي"
        case "id": return "Hanafi"
        case "tr": return "Hanefi"
        case "ja": return "ハナフィー"
        case "kk": return "Ханафи"
        case "fa": return "حنفی"
        case "ur": return "حنفی"
        case "ms": return "Hanafi"
        default:   return "Hanafi"
        }
    }

    static func notifications(_ lang: String) -> String {
        switch lang {
        case "ar": return "الإشعارات"
        case "id": return "Notifikasi"
        case "tr": return "Bildirimler"
        case "ja": return "通知"
        case "kk": return "Хабарландырулар"
        case "fa": return "اعلان‌ها"
        case "ur": return "اطلاعات"
        case "ms": return "Notifikasi"
        default:   return "Notifications"
        }
    }

    static func enableNotifications(_ lang: String) -> String {
        switch lang {
        case "ar": return "تفعيل الإشعارات"
        case "id": return "Aktifkan Notifikasi"
        case "tr": return "Bildirimleri Etkinleştir"
        case "ja": return "通知を有効にする"
        case "kk": return "Хабарландыруларды қосу"
        case "fa": return "فعال‌سازی اعلان‌ها"
        case "ur": return "اطلاعات فعال کریں"
        case "ms": return "Aktifkan Notifikasi"
        default:   return "Enable Notifications"
        }
    }

    static func language(_ lang: String) -> String {
        switch lang {
        case "ar": return "اللغة"
        case "id": return "Bahasa"
        case "tr": return "Dil"
        case "ja": return "言語"
        case "kk": return "Тіл"
        case "fa": return "زبان"
        case "ur": return "زبان"
        case "ms": return "Bahasa"
        default:   return "Language"
        }
    }

    static func location(_ lang: String) -> String {
        switch lang {
        case "ar": return "الموقع"
        case "id": return "Lokasi"
        case "tr": return "Konum"
        case "ja": return "位置"
        case "kk": return "Орын"
        case "fa": return "مکان"
        case "ur": return "مقام"
        case "ms": return "Lokasi"
        default:   return "Location"
        }
    }

    static func detecting(_ lang: String) -> String {
        switch lang {
        case "ar": return "جارٍ الكشف..."
        case "id": return "Mendeteksi..."
        case "tr": return "Algılanıyor..."
        case "ja": return "検出中..."
        case "kk": return "Анықталуда..."
        case "fa": return "در حال تشخیص..."
        case "ur": return "پتہ لگایا جا رہا ہے..."
        case "ms": return "Mengesan..."
        default:   return "Detecting..."
        }
    }

    static func prayerTimeReached(_ lang: String, prayerName: String) -> String {
        switch lang {
        case "ar": return "حان وقت صلاة \(prayerName)"
        case "id": return "Waktu \(prayerName) telah tiba"
        case "tr": return "\(prayerName) vakti girdi"
        case "ja": return "\(prayerName) の時間です"
        case "kk": return "\(prayerName) уақыты кірді"
        case "fa": return "وقت نماز \(prayerName) فرا رسید"
        case "ur": return "\(prayerName) کا وقت ہو گیا ہے"
        case "ms": return "Telah masuk waktu solat \(prayerName)"
        default:   return "It's time for \(prayerName) prayer"
        }
    }

    static func prayerReminder(_ lang: String) -> String {
        switch lang {
        case "ar": return "تذكير بالصلاة"
        case "id": return "Pengingat Sholat"
        case "tr": return "Namaz Hatırlatıcısı"
        case "ja": return "礼拝のリマインダー"
        case "kk": return "Намаз ескертуі"
        case "fa": return "یادآور نماز"
        case "ur": return "نماز کی یاد دہانی"
        case "ms": return "Peringatan Solat"
        default:   return "Prayer Reminder"
        }
    }

    static func back(_ lang: String) -> String {
        switch lang {
        case "ar": return "رجوع"
        case "id": return "Kembali"
        case "tr": return "Geri"
        case "ja": return "戻る"
        case "kk": return "Артқа"
        case "fa": return "بازگشت"
        case "ur": return "واپس"
        case "ms": return "Kembali"
        default:   return "Back"
        }
    }

    static func version(_ lang: String) -> String {
        switch lang {
        case "ar": return "الإصدار"
        case "id": return "Versi"
        case "tr": return "Sürüm"
        case "ja": return "バージョン"
        case "kk": return "Нұсқа"
        case "fa": return "نسخه"
        case "ur": return "ورژن"
        case "ms": return "Versi"
        default:   return "Version"
        }
    }

    static func madeWith(_ lang: String) -> String {
        switch lang {
        case "ar": return "صنع بـ ❤️ للمسلمين"
        case "id": return "Dibuat dengan ❤️ untuk umat Muslim"
        case "tr": return "Müslümanlar için ❤️ ile yapıldı"
        case "ja": return "ムスリムのために ❤️ を込めて"
        case "kk": return "Мұсылмандар үшін ❤️ жасалған"
        case "fa": return "ساخته شده با ❤️ برای مسلمانان"
        case "ur": return "مسلمانوں کے لیے ❤️ کے ساتھ بنایا گیا"
        case "ms": return "Dibuat dengan ❤️ untuk umat Islam"
        default:   return "Made with ❤️ for Muslims"
        }
    }

    static func poweredBy(_ lang: String) -> String {
        switch lang {
        case "ar": return "مدعوم من Adhan Library"
        case "id": return "Didukung oleh Adhan Library"
        case "tr": return "Adhan Library tarafından desteklenmektedir"
        case "ja": return "Adhan Library を使用"
        case "kk": return "Adhan Library арқылы"
        case "fa": return "با قدرت Adhan Library"
        case "ur": return "Adhan Library کی مدد سے"
        case "ms": return "Dikuasakan oleh Adhan Library"
        default:   return "Powered by Adhan Library"
        }
    }

    static func todaySchedule(_ lang: String) -> String {
        switch lang {
        case "ar": return "مواقيت اليوم"
        case "id": return "Jadwal Hari Ini"
        case "tr": return "Bugünün Vakitleri"
        case "ja": return "今日のスケジュール"
        case "kk": return "Бүгінгі кесте"
        case "fa": return "برنامه امروز"
        case "ur": return "آج کا شیڈول"
        case "ms": return "Jadual Hari Ini"
        default:   return "Today's Schedule"
        }
    }

    // MARK: - Calendar Events

    static func events(_ lang: String) -> String {
        switch lang {
        case "ar": return "الأحداث"
        case "id": return "Acara"
        case "tr": return "Etkinlikler"
        case "ja": return "イベント"
        case "kk": return "Оқиғалар"
        case "fa": return "رویدادها"
        case "ur": return "تقریبات"
        case "ms": return "Acara"
        default:   return "Events"
        }
    }

    static func noEvents(_ lang: String) -> String {
        switch lang {
        case "ar": return "لا أحداث قادمة"
        case "id": return "Tidak ada acara mendatang"
        case "tr": return "Yaklaşan etkinlik yok"
        case "ja": return "予定されているイベントはありません"
        case "kk": return "Алдағы оқиғалар жоқ"
        case "fa": return "رویداد آینده‌ای نیست"
        case "ur": return "کوئی آنے والی تقریب نہیں"
        case "ms": return "Tiada acara akan datang"
        default:   return "No upcoming events"
        }
    }

    static func grantCalendarAccess(_ lang: String) -> String {
        switch lang {
        case "ar": return "السماح بالوصول للتقويم"
        case "id": return "Izinkan Akses Kalender"
        case "tr": return "Takvim Erişimine İzin Ver"
        case "ja": return "カレンダーへのアクセスを許可"
        case "kk": return "Күнтізбеге рұқсат беру"
        case "fa": return "اعطای دسترسی به تقویم"
        case "ur": return "کیلنڈر تک رسائی کی اجازت دیں"
        case "ms": return "Benarkan Akses Kalendar"
        default:   return "Grant Calendar Access"
        }
    }

    static func tomorrow(_ lang: String) -> String {
        switch lang {
        case "ar": return "غداً"
        case "id": return "Besok"
        case "tr": return "Yarın"
        case "ja": return "明日"
        case "kk": return "Ертең"
        case "fa": return "فردا"
        case "ur": return "کل"
        case "ms": return "Esok"
        default:   return "Tomorrow"
        }
    }

    static func showCalendarEvents(_ lang: String) -> String {
        switch lang {
        case "ar": return "عرض أحداث التقويم"
        case "id": return "Tampilkan Acara Kalender"
        case "tr": return "Takvim Etkinliklerini Göster"
        case "ja": return "カレンダーのイベントを表示"
        case "kk": return "Күнтізбе оқиғаларын көрсету"
        case "fa": return "نمایش رویدادهای تقویم"
        case "ur": return "کیلنڈر کی تقریبات دکھائیں"
        case "ms": return "Tunjukkan Acara Kalendar"
        default:   return "Show Calendar Events"
        }
    }

    static func selectedCalendars(_ lang: String) -> String {
        switch lang {
        case "ar": return "تصفية التقويم"
        case "id": return "Filter Kalender"
        case "tr": return "Takvim Filtreleri"
        case "ja": return "カレンダーのフィルター"
        case "kk": return "Күнтізбе сүзгілері"
        case "fa": return "فیلترهای تقویم"
        case "ur": return "کیلنڈر فلٹرز"
        case "ms": return "Penapis Kalendar"
        default:   return "Calendar Filters"
        }
    }

    // MARK: - Notification Permission Denied Alert

    static func notificationPermissionDeniedTitle(_ lang: String) -> String {
        switch lang {
        case "ar": return "تم رفض إذن الإشعارات"
        case "id": return "Izin Notifikasi Ditolak"
        case "tr": return "Bildirim İzni Reddedildi"
        case "ja": return "通知の許可が拒否されました"
        case "kk": return "Хабарландыруға рұқсат берілмеді"
        case "fa": return "مجوز اعلان رد شد"
        case "ur": return "اطلاع کی اجازت سے انکار کر دیا گیا"
        case "ms": return "Kebenaran Notifikasi Ditolak"
        default:   return "Notification Permission Denied"
        }
    }

    static func notificationPermissionDeniedMessage(_ lang: String) -> String {
        switch lang {
        case "ar": return "يرجى تمكين الإشعارات لـ DariSholat في إعدادات النظام لتلقي تنبيهات الصلاة."
        case "id": return "Silakan aktifkan notifikasi untuk DariSholat di Pengaturan Sistem untuk menerima peringatan sholat."
        case "tr": return "Namaz uyarılarını almak için lütfen Sistem Ayarlarından DariSholat için bildirimleri etkinleştirin."
        case "ja": return "礼拝の通知を受け取るには、システム設定で DariSholat の通知を有効にしてください。"
        case "kk": return "Намаз ескертулерін алу үшін Жүйелік реттеулерде DariSholat хабарландыруларын қосыңыз."
        case "fa": return "لطفاً اعلان‌های DariSholat را در تنظیمات سیستم فعال کنید تا هشدارهای نماز را دریافت کنید."
        case "ur": return "براہ کرم نماز کے انتباہات حاصل کرنے کے لیے سسٹم کی ترتیبات میں DariSholat کے لیے اطلاعات کو فعال کریں۔"
        case "ms": return "Sila aktifkan notifikasi untuk DariSholat di Tetapan Sistem untuk menerima amaran solat."
        default:   return "Please enable notifications for DariSholat in System Settings to receive prayer alerts."
        }
    }

    static func openSettings(_ lang: String) -> String {
        switch lang {
        case "ar": return "فتح الإعدادات"
        case "id": return "Buka Pengaturan"
        case "tr": return "Ayarları Aç"
        case "ja": return "設定を開く"
        case "kk": return "Реттеулерді ашу"
        case "fa": return "باز کردن تنظیمات"
        case "ur": return "ترتیبات کھولیں"
        case "ms": return "Buka Tetapan"
        default:   return "Open Settings"
        }
    }

    static func cancel(_ lang: String) -> String {
        switch lang {
        case "ar": return "إلغاء"
        case "id": return "Batal"
        case "tr": return "İptal"
        case "ja": return "キャンセル"
        case "kk": return "Бас тарту"
        case "fa": return "لغو"
        case "ur": return "منسوخ کریں"
        case "ms": return "Batal"
        default:   return "Cancel"
        }
    }

    // MARK: - Ramadan Countdown

    static func ramadan(_ lang: String) -> String {
        switch lang {
        case "ar": return "رمضان"
        case "id": return "Ramadhan"
        case "tr": return "Ramazan"
        case "ja": return "ラマダーン"
        case "kk": return "Рамазан"
        case "fa": return "رمضان"
        case "ur": return "رمضان"
        case "ms": return "Ramadan"
        default:   return "Ramadan"
        }
    }

    static func ramadanCountdownLabel(_ lang: String) -> String {
        switch lang {
        case "ar": return "حتى رمضان"
        case "id": return "Menuju Ramadhan"
        case "tr": return "Ramazan'a Kalan"
        case "ja": return "ラマダーンまで"
        case "kk": return "Рамазанға дейін"
        case "fa": return "تا رمضان"
        case "ur": return "رمضان تک"
        case "ms": return "Menuju Ramadan"
        default:   return "Until Ramadan"
        }
    }

    // MARK: - Prayer Habits / Tracking

    static func habits(_ lang: String) -> String {
        switch lang {
        case "ar": return "العادات"
        case "id": return "Kebiasaan"
        case "tr": return "Alışkanlıklar"
        case "ja": return "習慣"
        case "kk": return "Әдеттер"
        case "fa": return "عادات"
        case "ur": return "عادات"
        case "ms": return "Kebiasaan"
        default:   return "Habits"
        }
    }

    static func prayedNow(_ lang: String) -> String {
        switch lang {
        case "ar": return "صليت"
        case "id": return "Sudah Sholat"
        case "tr": return "Kıldım"
        case "ja": return "礼拝済み"
        case "kk": return "Оқыдым"
        case "fa": return "نماز خواندم"
        case "ur": return "نماز پڑھ لی"
        case "ms": return "Sudah Solat"
        default:   return "Prayed"
        }
    }

    static func snooze(_ lang: String) -> String {
        switch lang {
        case "ar": return "تأجيل"
        case "id": return "Tunda"
        case "tr": return "Ertele"
        case "ja": return "後で"
        case "kk": return "Кейінге қалдыру"
        case "fa": return "تعویق"
        case "ur": return "مؤخر کریں"
        case "ms": return "Tunda"
        default:   return "Snooze"
        }
    }

    static func snoozeMinutes(_ lang: String, minutes: Int) -> String {
        switch lang {
        case "ar": return "\(minutes) دقيقة"
        case "id": return "\(minutes) menit"
        case "tr": return "\(minutes) dakika"
        case "ja": return "\(minutes)分"
        case "kk": return "\(minutes) минут"
        case "fa": return "\(minutes) دقیقه"
        case "ur": return "\(minutes) منٹ"
        case "ms": return "\(minutes) minit"
        default:   return "\(minutes) min"
        }
    }

    static func snoozedReminder(_ lang: String, prayerName: String) -> String {
        switch lang {
        case "ar": return "تذكير: \(prayerName)"
        case "id": return "Pengingat: \(prayerName)"
        case "tr": return "Hatırlatma: \(prayerName)"
        case "ja": return "リマインダー: \(prayerName)"
        case "kk": return "Ескерту: \(prayerName)"
        case "fa": return "یادآوری: \(prayerName)"
        case "ur": return "یاد دہانی: \(prayerName)"
        case "ms": return "Peringatan: \(prayerName)"
        default:   return "Reminder: \(prayerName)"
        }
    }

    static func prayerCompleted(_ lang: String) -> String {
        switch lang {
        case "ar": return "تمت"
        case "id": return "Selesai"
        case "tr": return "Tamamlandı"
        case "ja": return "完了"
        case "kk": return "Аяқталды"
        case "fa": return "انجام شد"
        case "ur": return "مکمل"
        case "ms": return "Selesai"
        default:   return "Completed"
        }
    }

    static func prayerMissed(_ lang: String) -> String {
        switch lang {
        case "ar": return "فائتة"
        case "id": return "Terlewat"
        case "tr": return "Kaçırıldı"
        case "ja": return "未実施"
        case "kk": return "Өткізіп алынды"
        case "fa": return "از دست رفته"
        case "ur": return "قضا"
        case "ms": return "Terlepas"
        default:   return "Missed"
        }
    }

    static func todayProgress(_ lang: String) -> String {
        switch lang {
        case "ar": return "اليوم"
        case "id": return "Hari Ini"
        case "tr": return "Bugün"
        case "ja": return "今日"
        case "kk": return "Бүгін"
        case "fa": return "امروز"
        case "ur": return "آج"
        case "ms": return "Hari Ini"
        default:   return "Today"
        }
    }

    static func prayerTimeArrived(_ lang: String, prayerName: String) -> String {
        switch lang {
        case "ar": return "حان وقت صلاة \(prayerName)"
        case "id": return "Waktu \(prayerName) telah tiba"
        case "tr": return "\(prayerName) vakti geldi"
        case "ja": return "\(prayerName)の時間です"
        case "kk": return "\(prayerName) уақыты келді"
        case "fa": return "وقت نماز \(prayerName) رسید"
        case "ur": return "\(prayerName) کا وقت آ گیا ہے"
        case "ms": return "Waktu \(prayerName) telah tiba"
        default:   return "\(prayerName) time has arrived"
        }
    }
}
