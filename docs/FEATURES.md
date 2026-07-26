# Panduan Fitur DariSholat

Dokumen ini menjelaskan setiap fitur aplikasi beserta cara memakainya.

## Daftar Isi

- [Menu Bar (Popover)](#menu-bar-popover)
- [To-Doing — Papan Kanban](#to-doing--papan-kanban)
- [Folder Tugas](#folder-tugas)
- [Detail Tugas (ala Notion)](#detail-tugas-ala-notion)
- [Wake from Sleep](#wake-from-sleep)
- [Home & Wallpaper](#home--wallpaper)
- [Events & Kalender Hijriah](#events--kalender-hijriah)
- [Pengaturan](#pengaturan)
- [Pintasan Keyboard](#pintasan-keyboard)

---

## Menu Bar (Popover)

Klik ikon 🌙 di menu bar untuk membuka popover:

- **Jadwal sholat hari ini** — sholat berikutnya di-highlight dengan warna aksen dan progress ring
- **Countdown menu bar** — teks seperti `Fajr -40:32` diperbarui tiap detik; berubah oranye → merah saat < 5 menit
- **Kolom Events** — tanggal Hijriah, countdown Ramadan, dan semua event Apple Calendar (scroll bila banyak)
- **Baris ikon bawah** — ☑️ buka window To-Doing (dengan badge jumlah tugas pending), 🔗 GitHub repo
- **Quit** — keluar aplikasi

## To-Doing — Papan Kanban

Klik ikon ☑️ di popover (atau item **To-Doing** di sidebar window) untuk membuka papan tugas:

- Tiga kolom: **Todo → In Progress → Done**, masing-masing dengan bisikan handwritten kecil
- **Tambah tugas**: ketik di field atas lalu Enter (folder harus dipilih dulu)
- **Pindah kolom**: drag & drop kartu antar kolom, atau hover kartu → tombol ‹ ›
- **Hapus**: hover kartu → ikon 🗑
- Footer menampilkan jumlah pending folder aktif + tombol **Clear completed**
- **Quote harian** handwritten muncul saat papan kosong — berganti otomatis tiap hari, warnanya mengikuti aksen

## Folder Tugas

Tugas hidup di dalam folder (chips di bawah judul):

| Aksi | Cara |
|---|---|
| Buat folder | Klik chip **+** → ketik nama → Enter |
| Pindah folder | Klik chip-nya |
| Kembali ke daftar default | Klik lagi chip yang sedang aktif |
| Ganti nama | Klik kanan chip → **Rename** |
| Hapus | Klik kanan chip → **Delete folder** (tugasnya tidak hilang, kembali ke daftar default) |
| Ubah urutan | Tekan-tahan chip → geser → jatuhkan ke chip lain |

Bila chips melebihi lebar bar, muncul panah **›** — scroll ke samping untuk folder lainnya.

## Detail Tugas (ala Notion)

Klik kartu mana pun untuk membuka halaman detail:

- **Cover banner** gradien mengikuti warna status
- **Judul** besar (bisa diedit langsung)
- **Status switcher** — pill Todo / In Progress / Done
- **Catatan bebas** — tersimpan otomatis saat sheet ditutup; preview 1 baris tampil di kartu
- `⌘↩` untuk simpan & tutup

## Wake from Sleep

Saat Mac bangun dari sleep, window To-Doing **otomatis tampil paling depan** — merebut fokus dari app apa pun yang aktif (Zoom, Spotify, dst.) supaya hari dimulai dengan melihat rencana. Jadwal sholat dan countdown juga langsung di-refresh (timer beku selama sleep).

## Home & Wallpaper

Klik tulisan **DariSholat** di sidebar untuk membuka halaman Home:

- Wallpaper full-bleed — pilihannya sinkron dengan popover
- **Kartu Events lengkap** melayang di kanan atas: tanggal Hijriah + Ramadan + semua event kalender (scrollable)
- Thumbnail bulat di bawah untuk berganti wallpaper

## Events & Kalender Hijriah

- Event diambil dari **Apple Calendar** (butuh izin kalender; semua event non-all-day setahun ke depan)
- Countdown format `9d 8h`
- Tanggal **Hijriah** hari ini tampil di popover, header To-Doing, dan Home
- Countdown **Ramadan** selalu terpasang di atas daftar

## Pengaturan

Buka dari sidebar window → **Settings**:

| Bagian | Isi |
|---|---|
| Display | Compact view, format 24 jam |
| System | Run at Login, notifikasi sholat |
| Theme | Warna aksen, gaya blur, wallpaper |
| Calculation | Metode (Kemenag RI, MWL, ISNA, …), madhab |
| Location | Otomatis (GPS) atau manual 18 kota Indonesia |
| Language | 9 bahasa |

## Pintasan Keyboard

| Pintasan | Aksi |
|---|---|
| `⌘\` | Tampilkan / sembunyikan sidebar |
| `⌘↩` | Simpan & tutup detail tugas |
| `Esc` | Batal rename folder / tutup field |
| `⌘W` | Tutup window (app tetap jalan di menu bar) |
