import re

translations = {
    "fajr": {"tr": "İmsak", "ja": "ファジル", "kk": "Таң", "fa": "فجر", "ur": "فجر", "ms": "Subuh"},
    "sunrise": {"tr": "Güneş", "ja": "日の出", "kk": "Күннің шығуы", "fa": "طلوع آفتاب", "ur": "طلوع آفتاب", "ms": "Syuruk"},
    "dhuhr": {"tr": "Öğle", "ja": "ズフル", "kk": "Бесін", "fa": "ظهر", "ur": "ظہر", "ms": "Zohor"},
    "asr": {"tr": "İkindi", "ja": "アスル", "kk": "Екінті", "fa": "عصر", "ur": "عصر", "ms": "Asar"},
    "maghrib": {"tr": "Akşam", "ja": "マグリブ", "kk": "Ақшам", "fa": "مغرب", "ur": "مغرب", "ms": "Maghrib"},
    "isha": {"tr": "Yatsı", "ja": "イシャー", "kk": "Құптан", "fa": "عشاء", "ur": "عشاء", "ms": "Isyak"},
    "now": {"tr": "Şimdi", "ja": "今", "kk": "Қазір", "fa": "اکنون", "ur": "اب", "ms": "Sekarang"},
    "settings": {"tr": "Ayarlar", "ja": "設定", "kk": "Параметрлер", "fa": "تنظیمات", "ur": "ترتیبات", "ms": "Tetapan"},
    "about": {"tr": "Hakkında", "ja": "概要", "kk": "Туралы", "fa": "درباره", "ur": "کے بارے میں", "ms": "Tentang"},
    "quit": {"tr": "Çıkış", "ja": "終了", "kk": "Шығу", "fa": "خروج", "ur": "باہر نکلیں", "ms": "Keluar"},
    "nextPrayer": {"tr": "Sonraki Vakit", "ja": "次の礼拝", "kk": "Келесі уақыт", "fa": "نماز بعدی", "ur": "اگلی نماز", "ms": "Solat Seterusnya"},
    "calculationMethod": {"tr": "Hesaplama Yöntemi", "ja": "計算方法", "kk": "Есептеу әдісі", "fa": "روش محاسبه", "ur": "حساب کا طریقہ", "ms": "Kaedah Pengiraan"},
    "madhab": {"tr": "Mezhep", "ja": "マズハブ", "kk": "Мәзһаб", "fa": "مذهب", "ur": "فقہ", "ms": "Mazhab"},
    "shafi": {"tr": "Şafii", "ja": "シャーフィイー", "kk": "Шафии", "fa": "شافعی", "ur": "شافعی", "ms": "Syafi'i"},
    "hanafi": {"tr": "Hanefi", "ja": "ハナフィー", "kk": "Ханафи", "fa": "حنفی", "ur": "حنفی", "ms": "Hanafi"},
    "notifications": {"tr": "Bildirimler", "ja": "通知", "kk": "Хабарландырулар", "fa": "اعلان‌ها", "ur": "اطلاعات", "ms": "Notifikasi"},
    "enableNotifications": {"tr": "Bildirimleri Etkinleştir", "ja": "通知を有効にする", "kk": "Хабарландыруларды қосу", "fa": "فعال‌سازی اعلان‌ها", "ur": "اطلاعات فعال کریں", "ms": "Aktifkan Notifikasi"},
    "language": {"tr": "Dil", "ja": "言語", "kk": "Тіл", "fa": "زبان", "ur": "زبان", "ms": "Bahasa"},
    "location": {"tr": "Konum", "ja": "位置", "kk": "Орын", "fa": "مکان", "ur": "مقام", "ms": "Lokasi"},
    "detecting": {"tr": "Algılanıyor...", "ja": "検出中...", "kk": "Анықталуда...", "fa": "در حال تشخیص...", "ur": "پتہ لگایا جا رہا ہے...", "ms": "Mengesan..."},
    "prayerTimeReached": {
        "tr": "\\(prayerName) vakti girdi",
        "ja": "\\(prayerName) の時間です",
        "kk": "\\(prayerName) уақыты кірді",
        "fa": "وقت نماز \\(prayerName) فرا رسید",
        "ur": "\\(prayerName) کا وقت ہو گیا ہے",
        "ms": "Telah masuk waktu solat \\(prayerName)"
    },
    "prayerReminder": {"tr": "Namaz Hatırlatıcısı", "ja": "礼拝のリマインダー", "kk": "Намаз ескертуі", "fa": "یادآور نماز", "ur": "نماز کی یاد دہانی", "ms": "Peringatan Solat"},
    "back": {"tr": "Geri", "ja": "戻る", "kk": "Артқа", "fa": "بازگشت", "ur": "واپس", "ms": "Kembali"},
    "version": {"tr": "Sürüm", "ja": "バージョン", "kk": "Нұсқа", "fa": "نسخه", "ur": "ورژن", "ms": "Versi"},
    "madeWith": {"tr": "Müslümanlar için ❤️ ile yapıldı", "ja": "ムスリムのために ❤️ を込めて", "kk": "Мұсылмандар үшін ❤️ жасалған", "fa": "ساخته شده با ❤️ برای مسلمانان", "ur": "مسلمانوں کے لیے ❤️ کے ساتھ بنایا گیا", "ms": "Dibuat dengan ❤️ untuk umat Islam"},
    "poweredBy": {"tr": "Adhan Library tarafından desteklenmektedir", "ja": "Adhan Library を使用", "kk": "Adhan Library арқылы", "fa": "با قدرت Adhan Library", "ur": "Adhan Library کی مدد سے", "ms": "Dikuasakan oleh Adhan Library"},
    "todaySchedule": {"tr": "Bugünün Vakitleri", "ja": "今日のスケジュール", "kk": "Бүгінгі кесте", "fa": "برنامه امروز", "ur": "آج کا شیڈول", "ms": "Jadual Hari Ini"},
    "events": {"tr": "Etkinlikler", "ja": "イベント", "kk": "Оқиғалар", "fa": "رویدادها", "ur": "تقریبات", "ms": "Acara"},
    "noEvents": {"tr": "Yaklaşan etkinlik yok", "ja": "予定されているイベントはありません", "kk": "Алдағы оқиғалар жоқ", "fa": "رویداد آینده‌ای نیست", "ur": "کوئی آنے والی تقریب نہیں", "ms": "Tiada acara akan datang"},
    "grantCalendarAccess": {"tr": "Takvim Erişimine İzin Ver", "ja": "カレンダーへのアクセスを許可", "kk": "Күнтізбеге рұқсат беру", "fa": "اعطای دسترسی به تقویم", "ur": "کیلنڈر تک رسائی کی اجازت دیں", "ms": "Benarkan Akses Kalendar"},
    "tomorrow": {"tr": "Yarın", "ja": "明日", "kk": "Ертең", "fa": "فردا", "ur": "کل", "ms": "Esok"},
    "showCalendarEvents": {"tr": "Takvim Etkinliklerini Göster", "ja": "カレンダーのイベントを表示", "kk": "Күнтізбе оқиғаларын көрсету", "fa": "نمایش رویدادهای تقویم", "ur": "کیلنڈر کی تقریبات دکھائیں", "ms": "Tunjukkan Acara Kalendar"},
    "selectedCalendars": {"tr": "Takvim Filtreleri", "ja": "カレンダーのフィルター", "kk": "Күнтізбе сүзгілері", "fa": "فیلترهای تقویم", "ur": "کیلنڈر فلٹرز", "ms": "Penapis Kalendar"},
    "notificationPermissionDeniedTitle": {"tr": "Bildirim İzni Reddedildi", "ja": "通知の許可が拒否されました", "kk": "Хабарландыруға рұқсат берілмеді", "fa": "مجوز اعلان رد شد", "ur": "اطلاع کی اجازت سے انکار کر دیا گیا", "ms": "Kebenaran Notifikasi Ditolak"},
    "notificationPermissionDeniedMessage": {"tr": "Namaz uyarılarını almak için lütfen Sistem Ayarlarından DariSholat için bildirimleri etkinleştirin.", "ja": "礼拝の通知を受け取るには、システム設定で DariSholat の通知を有効にしてください。", "kk": "Намаз ескертулерін алу үшін Жүйелік реттеулерде DariSholat хабарландыруларын қосыңыз.", "fa": "لطفاً اعلان‌های DariSholat را در تنظیمات سیستم فعال کنید تا هشدارهای نماز را دریافت کنید.", "ur": "براہ کرم نماز کے انتباہات حاصل کرنے کے لیے سسٹم کی ترتیبات میں DariSholat کے لیے اطلاعات کو فعال کریں۔", "ms": "Sila aktifkan notifikasi untuk DariSholat di Tetapan Sistem untuk menerima amaran solat."},
    "openSettings": {"tr": "Ayarları Aç", "ja": "設定を開く", "kk": "Реттеулерді ашу", "fa": "باز کردن تنظیمات", "ur": "ترتیبات کھولیں", "ms": "Buka Tetapan"},
    "cancel": {"tr": "İptal", "ja": "キャンセル", "kk": "Бас тарту", "fa": "لغو", "ur": "منسوخ کریں", "ms": "Batal"},
    "ramadan": {"tr": "Ramazan", "ja": "ラマダーン", "kk": "Рамазан", "fa": "رمضان", "ur": "رمضان", "ms": "Ramadan"},
    "ramadanCountdownLabel": {"tr": "Ramazan'a Kalan", "ja": "ラマダーンまで", "kk": "Рамазанға дейін", "fa": "تا رمضان", "ur": "رمضان تک", "ms": "Menuju Ramadan"}
}

with open("DariSholat/Localization.swift", "r") as f:
    lines = f.readlines()

out_lines = []
current_func = None

for line in lines:
    m = re.match(r'^\s*static func (\w+)', line)
    if m:
        current_func = m.group(1)
    
    if line.strip().startswith("default:") and current_func in translations:
        # inject translations before default:
        for lang, trans in translations[current_func].items():
            out_lines.append(f'        case "{lang}": return "{trans}"\n')
        
    out_lines.append(line)

with open("DariSholat/Localization.swift", "w") as f:
    f.writelines(out_lines)

print("Updated Localization.swift using python line matching.")
