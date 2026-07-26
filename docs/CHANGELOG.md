# Changelog

Semua perubahan berarti dicatat di sini. Format mengikuti [Keep a Changelog](https://keepachangelog.com/), versi mengikuti [Semantic Versioning](https://semver.org/).

## [1.2.0] — 2026-07-21

### Ditambahkan
- **To-Doing**: papan kanban (Todo → In Progress → Done) di window desktop baru dengan sidebar navigasi
- **Folder tugas**: buat / rename / hapus / drag-reorder; tugas tersimpan per folder
- **Detail tugas ala Notion**: cover status, judul editable, catatan bebas
- **Wake from sleep**: window To-Doing otomatis tampil paling depan saat Mac bangun; jadwal & countdown ikut di-refresh
- **Home**: halaman wallpaper full-bleed dengan kartu Events lengkap (Hijriah + Ramadan + semua event kalender)
- **Quote harian** handwritten (Noteworthy) berganti tiap hari, mengikuti warna aksen
- Semua event Apple Calendar ditampilkan (sebelumnya dibatasi 3), daftar scrollable
- Toggle sidebar (`⌘\`) dengan animasi spring; panah overflow pada bar folder
- Launch at Login via `SMAppService`; menu bar app menjadi `.regular` saat window terbuka (main menu tampil)

### Diubah
- Popover menu bar diringkas: baris ikon (To-Doing + GitHub) menggantikan menu teks; Settings & About pindah ke window desktop
- About didesain ulang: satu halaman di atas wallpaper, kolom golden-ratio (info app / developer)
- Tipografi diselaraskan: judul serif 21pt, grid margin 21pt, spacing Fibonacci
- Appearance dipaksa dark di satu tempat (app-level) — konsisten di mode terang/gelap sistem

### Diperbaiki
- Crash / warning constraint-loop AppKit pada animasi window (pola animasi ditulis ulang: width/opacity, tanpa insertion)
- Window jatuh ke belakang setelah wake & tidak bisa dinaikkan kembali dengan klik
- Timer countdown ngaco setelah Mac bangun dari sleep
- Badge pending tidak ter-update (wiring ObservableObject bersarang)
- Shortcut Shift+/ tidak berfungsi (kemudian fiturnya dihapus)

## [1.1.0]

### Ditambahkan
- Integrasi Apple Calendar (kolom Events + countdown)
- Kalender Hijriah di popover
- Wallpaper Events yang bisa diganti
- Lokasi manual 18 kota besar Indonesia

## [1.0.0]

- Rilis awal: jadwal sholat menu bar dengan countdown real-time, notifikasi, 9 bahasa, metode Kemenag RI & global, tema aksen
