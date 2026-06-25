# DariSholat 🕋

> Aplikasi menu bar macOS yang ringan dan elegan untuk memantau waktu sholat harian langsung dari desktop kamu.

<p align="center">
  <img src="https://github.com/user-attachments/assets/54bbe120-5ea2-4391-abad-3a6ae4554811" width="450" alt="DariSholat Preview">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2013%2B-black?style=flat-square&logo=apple" alt="macOS 13+">
  <img src="https://img.shields.io/badge/Bahasa-Swift-orange?style=flat-square&logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/Harga-Gratis-brightgreen?style=flat-square" alt="Gratis">
  <img src="https://img.shields.io/badge/Versi-1.0.0-blue?style=flat-square" alt="v1.0.0">
  <img src="https://img.shields.io/badge/Status-Active%20Development-brightgreen?style=flat-square" alt="Active Development">
</p>

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 📍 **Lokasi Otomatis** | Mendeteksi kota secara otomatis dan menampilkan waktu sholat berdasarkan koordinat GPS |
| ⏳ **Hitung Mundur Real-time** | Countdown di menu bar memperlihatkan sisa waktu menuju sholat berikutnya secara langsung (contoh: `Fajr -40:32`) |
| 📅 **Integrasi Kalender (Events)** | Menyinkronkan jadwal sholat dengan acara/event di kalender bawaan Mac (iCloud Calendar) Anda |
| 🌍 **Multi-Bahasa (9 Bahasa)** | Dukungan multibahasa: Indonesia, English, Arabic (العربية), Turkish (Türkçe), Japanese (日本語), Kazakh (Қазақша), Persian (فارسی), Urdu (اردو), dan Malay (Melayu) |
| 🎨 **Personalisasi Tema & UI** | Sesuaikan warna aksen (Accent Color) aplikasi sesuai selera, dengan dukungan penuh mode gelap/terang native macOS |
| 🕒 **Jadwal Lengkap** | Menampilkan semua waktu sholat: Subuh, Syuruq, Dzuhur, Ashar, Maghrib, dan Isya |
| ⚙️ **Metode Kemenag RI & Global** | Menggunakan metode perhitungan dari Kementerian Agama Republik Indonesia maupun standar global lainnya |
| 🌙 **Mode Hanafi / Syafi'i** | Toggle madhhab yang memengaruhi waktu Ashar (Hanafi lebih akhir dibanding Syafi'i) |
| 🔔 **Notifikasi Sholat** | Pengingat otomatis saat waktu sholat tiba agar tidak terlewat saat sedang bekerja |
| 🌅 **Tampilkan Sholat Sunnah** | Opsi untuk menampilkan waktu sholat-sholat sunnah rawatib |

---

## 🖼️ Tampilan Aplikasi

<p align="center">
  <img src="https://github.com/user-attachments/assets/54bbe120-5ea2-4391-abad-3a6ae4554811" width="280" alt="Menu utama DariSholat">
</p>

> Waktu sholat hari ini untuk Surabaya, dengan countdown real-time di menu bar.

---

## ⚙️ Pengaturan yang Tersedia

- **Tampilan:** Compact / expanded menu bar, format waktu 24 jam, accent color, background blur (Liquid Glass)
- **Perhitungan:** Pilihan metode (Kemenag RI, dll.), toggle Hanafi Madhhab untuk waktu Ashar
- **Lokasi:** Otomatis via GPS atau atur manual
- **Sistem:** Jalankan saat login, notifikasi sholat
- **Bahasa:** Tersedia pilihan bahasa antarmuka

---

## 🛠️ Teknologi

- **Bahasa:** Swift
- **Framework:** SwiftUI / AppKit
- **Platform:** macOS 13.0+ (Ventura atau lebih baru)
- **Dependency:** [adhan-swift](https://github.com/batoulapps/adhan-swift) oleh Batoul Apps — library open-source yang teruji untuk perhitungan waktu sholat

---

## 🚀 Cara Install (Untuk Pengguna / User)

Jika Anda hanya ingin menggunakan aplikasi tanpa harus berurusan dengan *coding* atau Xcode, Anda bisa langsung mengunduh aplikasinya:

1. Pergi ke halaman **[Releases](../../releases/latest)** di repositori ini.
2. Unduh file **`DariSholat-1.0.0.dmg`** (atau versi terbaru).
3. Setelah selesai, buka file `.dmg` tersebut.
4. **Drag & Drop** (seret dan lepas) ikon aplikasi **DariSholat** ke folder **Applications**.
5. Buka Launchpad atau Spotlight (`Cmd + Space`), lalu cari **DariSholat** dan jalankan.
6. Saat pertama kali dibuka, berikan izin lokasi agar aplikasi bisa menentukan waktu sholat yang tepat untuk kota Anda.
7. Aplikasi akan muncul di **Menu Bar** (pojok kanan atas layar) dengan ikon 🌙.

---

## 💻 Cara Build Lokal (Untuk Developer)

Ikuti langkah-langkah berikut untuk build dan menjalankan aplikasi di Mac kamu:

### Prasyarat

- macOS 13.0 (Ventura) atau lebih baru
- Xcode 14 atau lebih baru
- Koneksi internet (untuk mengunduh dependency saat pertama kali)

### Langkah-langkah

**1. Clone repository**

```bash
git clone https://github.com/dimaswijil/darisholat-mac.git
cd darisholat-mac
```

**2. Buka di Xcode**

```bash
open DariSholat.xcodeproj
```

> Jika menggunakan Swift Package Manager workspace, buka file `.xcworkspace`.

**3. Resolve dependencies**

Xcode akan otomatis mengunduh dependency `adhan-swift` melalui Swift Package Manager. Tunggu hingga proses selesai (ditandai dengan hilangnya loading di status bar Xcode).

**4. Build dan jalankan**

Tekan `⌘R` atau klik tombol **Run** di Xcode. Setelah berhasil, ikon DariSholat akan muncul di menu bar macOS kamu.

---

## 📁 Struktur Proyek

```
darisholat-mac/
├── DariSholat/
│   ├── App/                  # Entry point aplikasi
│   ├── Views/                # Komponen tampilan SwiftUI
│   ├── Models/               # Model data waktu sholat
│   ├── Helpers/              # Utility dan extension
│   └── Assets.xcassets/      # Ikon dan aset visual
├── DariSholat.xcodeproj/
└── README.md
```

> Struktur di atas adalah perkiraan umum — sesuaikan dengan struktur aktual proyekmu.

---

## 🤝 Kontribusi

Kontribusi sangat disambut! Berikut cara berkontribusi:

1. **Fork** repository ini
2. Buat branch baru: `git checkout -b fitur/nama-fitur`
3. Commit perubahan: `git commit -m 'Menambahkan fitur X'`
4. Push ke branch: `git push origin fitur/nama-fitur`
5. Buat **Pull Request**

Untuk perubahan besar atau fitur baru, disarankan membuka **Issue** terlebih dahulu untuk mendiskusikan arah perubahan.

---

## Kredit 🙏

- Perhitungan waktu sholat menggunakan [adhan-swift](https://github.com/batoulapps/adhan-swift) oleh **Batoul Apps**
- Metode perhitungan default mengacu pada standar **Kementerian Agama Republik Indonesia (Kemenag RI)**

---

<p align="center">
  Dibuat dengan ♥ untuk komunitas Muslim Indonesia 🇮🇩
  <br>
  🍉 Free Palestine, From Fiver To The Sea
</p>
