# Pedoman Desain UI (Design System Reference) - Mata Angin

Dokumen ini berfungsi sebagai acuan/panduan standar desain antarmuka pengguna (UI) untuk memastikan konsistensi visual di seluruh halaman aplikasi.

---

## 1. Palet Warna (Color Palette)

* **Background Scaffold Utama:** `Color(0xFF1598A3)` (Teal Terang)
* **Background Utama Aplikasi (Dark Theme / Main):** `Color(0xFF121212)` (Pure Black)
* **Background Kartu / Bottom Sheet / Dialog / Dropdown:** `Color(0xFF1E1E1E)` (Abu-gelap / Lighter Black)
* **Warna Aksen Navigasi Bawah (Bottom Nav):** `Color(0xFF1A1A1A)` (Hitam Solid)
* **Warna Aksen Hijau (Income/Success):** `Color(0xFF22C55E)`
* **Warna Aksen Merah (Expense/Danger):** `Color(0xFFEF4444)`
* **Warna Aksen Jingga (Warning/Pending):** `Color(0xFFF59E0B)`
* **Background Card Total (Dark Teal):** `Color(0xFF0A4D54)` / `Color(0xFF0A7E8C)`

---

## 2. Tipografi & Penulisan (Typography & Capitalization)

* **Judul Halaman Utama (AppBar Title):**
  * Ukuran Font: `28`
  * Weight: `FontWeight.bold` (Tebal)
  * Warna: `Colors.white`
* **Format Kapitalisasi (Capitalization):**
  * Menggunakan **Title Case** untuk semua label teks.
  * *Contoh:* `"Total Pemasukan"`, `"Total Pengeluaran"`, `"Total Utang"`.
  * *Hindari:* `"TOTAL PENGELUARAN"` atau `"TOTAL UTANG"`.

---

## 3. Desain Kartu Ringkasan (Total Card / Banner)

Digunakan untuk menampilkan ringkasan data nominal di bagian atas halaman (Pemasukan, Pengeluaran, Utang Piutang, dan Laporan).

* **Layout:** `Row` horizontal
* **Spasi Luar (Margin):** `const EdgeInsets.fromLTRB(20, 8, 20, 16)`
* **Spasi Dalam (Padding):** `const EdgeInsets.symmetric(horizontal: 24, vertical: 20)`
* **Sudut Membulat (Border Radius):** `24` (`BorderRadius.circular(24)`)
* **Elemen Ikon:**
  * Dibungkus dalam `Container` berukuran `52x52`.
  * Warna latar kontainer: `Colors.white.withValues(alpha: 0.15)`.
  * Border Radius kontainer: `16`.
  * Ukuran Ikon di dalamnya: `28`.
* **Elemen Teks (Label & Nilai):**
  * Label: Font Size `13`, `FontWeight.w500`, warna `Colors.white70`.
  * Nilai Nominal: Font Size `26`, `FontWeight.bold`, warna `Colors.white`.

---

## 4. FloatingActionButton (FAB / Tombol Tambah)

Semua tombol tambah data di pojok kanan bawah halaman harus mengikuti spesifikasi berikut untuk ukuran dan bentuk:

* **Ukuran:** `SizedBox(width: 60, height: 60)`
* **Bentuk (Shape):** `RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))` (Squircle/Kotak Membulat)
* **Ukuran Ikon Tambah (`+`):** `30`
* **Warna Ikon:** `Colors.white`
* **Warna Latar Belakang:**
  * Pemasukan: `Color(0xFF0A7E8C)` (Teal Aksen)
  * Pengeluaran: `Color(0xFFB32626)` (Merah Aksen)
  * Utang Piutang: `Color(0xFF1598A3)` (Teal Utama)

---

## 5. Kartu Detail / Riwayat Data (List Card)

Digunakan untuk menampilkan entri data di dalam list (Daftar Pemasukan, Pengeluaran, Utang Piutang, Laporan Harian/Bulanan).

* **Warna Latar:** `Color(0xFF1E1E1E)`
* **Sudut Membulat (Border Radius):** `24`
* **Spasi Bawah (Margin Bottom):** `12` atau `16`
* **Spasi Dalam (Padding):** `const EdgeInsets.all(16)` atau `const EdgeInsets.all(20)`
* **Warna Teks Utama:** `Colors.white` (w600)
* **Warna Teks Sekunder/Detail:** `Colors.white38` atau `Colors.white54`
