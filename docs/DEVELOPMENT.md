# Panduan Development

Dokumen untuk kontributor: setup, arsitektur, struktur proyek, dan konvensi.

## Daftar Isi

- [Setup](#setup)
- [Struktur Proyek](#struktur-proyek)
- [Arsitektur](#arsitektur)
- [Konvensi Desain](#konvensi-desain)
- [Pola Animasi (Penting)](#pola-animasi-penting)
- [Menambah File Baru](#menambah-file-baru)
- [Menambah Bahasa / String](#menambah-bahasa--string)
- [Build DMG](#build-dmg)

---

## Setup

**Prasyarat:** macOS 13+ (Ventura), Xcode 14+.

```bash
git clone https://github.com/dimaswijil/DariSholat.git
cd DariSholat
open DariSholat.xcodeproj
```

Dependency [adhan-swift](https://github.com/batoulapps/adhan-swift) diunduh otomatis via Swift Package Manager. Tekan `⌘R` untuk build & run — ikon muncul di menu bar (app bertipe `LSUIElement`, tanpa dock icon).

Build dari terminal:

```bash
xcodebuild -project DariSholat.xcodeproj -scheme DariSholat -configuration Debug build
```

## Struktur Proyek

```
DariSholat/
├── DariSholat/
│   ├── App/
│   │   └── DariSholatApp.swift        # Entry point, MenuBarExtra scene
│   ├── Views/
│   │   ├── ContentView.swift          # Popover menu bar (jadwal + events)
│   │   ├── SettingsView.swift
│   │   ├── AboutView.swift
│   │   ├── VisualEffectView.swift     # Bridge NSVisualEffectView (blur)
│   │   └── MainWindow/
│   │       ├── MainWindowView.swift   # Window desktop: sidebar + halaman
│   │       └── TodoListView.swift     # Kanban board + folder + detail sheet
│   ├── ViewModels/
│   │   └── PrayerTimeViewModel.swift  # Perhitungan sholat, countdown, wake observer
│   ├── Managers/
│   │   ├── LocationManager.swift      # CoreLocation + geocoding kota
│   │   ├── NotificationManager.swift  # UNUserNotificationCenter
│   │   ├── CalendarManager.swift      # EventKit (Apple Calendar)
│   │   ├── TodoManager.swift          # Model + persistence To-Doing
│   │   └── MainWindowManager.swift    # NSWindow desktop (lifecycle, wake takeover)
│   ├── Utils/
│   │   └── Localization.swift         # L10n — 9 bahasa, switch-based
│   └── Resources/                     # Assets, Info.plist, entitlements
├── DariSholatUITests/
├── docs/                              # Dokumentasi (file ini)
├── scripts/                           # Utility (tambah file ke pbxproj, dll)
├── assets/screenshots/                # Gambar untuk README
├── .github/workflows/ci.yml           # GitHub Actions
└── project.yml                        # Definisi XcodeGen (opsional)
```

## Arsitektur

- **MVVM ringan.** `PrayerTimeViewModel` adalah pusat state (jadwal sholat, countdown per detik, bahasa, tema). Manager-manager di-compose di dalamnya.
- **Dua permukaan UI:**
  1. **Popover menu bar** (`MenuBarExtra` + `ContentView`) — ringkas, selalu tersedia
  2. **Window desktop** (`MainWindowManager` + `MainWindowView`) — NSWindow yang dibuat manual (bukan SwiftUI `Window` scene) supaya bisa dibuka programmatic dari wake observer
- **Activation policy dinamis:** app berjalan `LSUIElement` (accessory). Saat window desktop dibuka → `.regular` (dapat main menu); ditutup → kembali `.accessory`.
- **Persistence:** UserDefaults + JSON (`TodoManager` menyimpan tugas & folder; decoder backward-compatible).
- **Wake from sleep:** `NSWorkspace.didWakeNotification` → refresh jadwal + buka window To-Doing paling depan (`orderFrontRegardless`, re-assert beberapa kali).

## Konvensi Desain

- **Spacing Fibonacci:** 5, 8, 13, 21, 34 pt. Margin halaman & grid sidebar = **21pt**.
- **Golden ratio (φ = 1.618):** lebar sidebar ≈ window/φ², empty state di 38.2% tinggi halaman, split kolom About 61.8/38.2.
- **Tipografi:** judul = serif bold 21pt; "suara manusia" (quote, placeholder, bisikan kolom) = font **Noteworthy** via `TodoListView.handFont()` dengan fallback rounded.
- **Warna:** elemen ekspresif mengikuti `accentColor` pilihan user; struktur tetap `.primary`/`.secondary`. App dipaksa dark (`NSApplication.shared.appearance = .darkAqua` di `DariSholatApp.init` — satu-satunya tempat).
- **Bahasa UI:** semua string user-facing lewat `L10n` (9 bahasa), jangan hardcode.

## Pola Animasi (Penting)

⚠️ **Jangan gunakan transisi insert/remove SwiftUI (`if x { view }` + `.transition`) di window desktop.** Kombinasi NSHostingView + animasi insertion memicu constraint-loop AppKit (warning "more Update Constraints passes than views" hingga crash SIGILL di macOS 13). Pola yang benar — semua view **selalu ter-mount**:

- **Sidebar:** animasikan `frame(width:)` + `clipped()` + opacity
- **Ganti tab:** ketiga halaman di ZStack, animasikan `opacity` + `allowsHitTesting`
- Satu sumber animasi saja (`.animation(value:)` di view; tanpa `withAnimation` ganda)
- `NSHostingView.sizingOptions = []` + container autoresizing di `MainWindowManager` — jangan dihapus

## Menambah File Baru

`project.pbxproj` memakai referensi file eksplisit (bukan folder-sync). Setelah membuat file Swift baru, daftarkan via script Ruby (gem `xcodeproj` sudah terpasang):

```bash
ruby scripts/add_files_script.rb   # edit dulu daftar file di dalamnya
```

⚠️ **Tutup Xcode dulu** sebelum menjalankan script — Xcode yang terbuka bisa menimpa pbxproj dengan salinan lamanya (sumber error "Cannot find X in scope" berulang).

## Menambah Bahasa / String

Semua string di `DariSholat/Utils/Localization.swift`, pola:

```swift
static func namaString(_ lang: String) -> String {
    switch lang {
    case "ar": return "…"
    case "id": return "…"
    // tr, ja, kk, fa, ur, ms
    default:   return "English text"
    }
}
```

Tambahkan fungsi baru untuk string baru; tambahkan `case` baru di setiap fungsi untuk bahasa baru (plus entri picker di `SettingsView`).

## Build DMG

Artefak release ada di `build/` (di-ignore git). Ringkasnya:

```bash
xcodebuild -project DariSholat.xcodeproj -scheme DariSholat -configuration Release build
# salin .app ke staging, lalu:
hdiutil create -volname DariSholat -srcfolder build/dmg-staging -ov -format UDZO build/DariSholat-x.y.z.dmg
```
