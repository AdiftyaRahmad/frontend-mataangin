# Dokumentasi Proyek Frontend Mataangin

Folder ini berisi semua dokumentasi teknis untuk proyek aplikasi keuangan Flutter + Firebase.

## 📋 Daftar Dokumentasi

### Keamanan & API Keys
- [README_SECURITY.md](./README_SECURITY.md) - Panduan keamanan umum
- [URGENT_SECURITY_STEPS.md](./URGENT_SECURITY_STEPS.md) - Langkah darurat keamanan
- [REGENERATE_API_KEYS.md](./REGENERATE_API_KEYS.md) - Cara regenerasi API keys
- [GUIDE_GENERATE_NEW_API_KEYS.md](./GUIDE_GENERATE_NEW_API_KEYS.md) - Panduan lengkap generate API keys baru
- [QUICK_REFERENCE_API_KEYS.md](./QUICK_REFERENCE_API_KEYS.md) - Referensi cepat API keys
- [CARA_MUDAH_GENERATE_KEYS.md](./CARA_MUDAH_GENERATE_KEYS.md) - Cara mudah generate keys
- [GENERATE_MANUAL_SIMPLE.md](./GENERATE_MANUAL_SIMPLE.md) - Generate manual sederhana

### Setup & Konfigurasi
- [SETUP_FIREBASE.md](./SETUP_FIREBASE.md) - Setup Firebase
- [ANDROID_SETUP_DETAIL.md](./ANDROID_SETUP_DETAIL.md) - Detail setup Android
- [ANDROID_CONFIG_EXTRACTED.md](./ANDROID_CONFIG_EXTRACTED.md) - Konfigurasi Android yang diekstrak

### Role & Permission
- [IMPLEMENT_ROLE_BASED_ACCESS.md](./IMPLEMENT_ROLE_BASED_ACCESS.md) - Implementasi role-based access control
- [ROLE_PERMISSION_FINAL.md](./ROLE_PERMISSION_FINAL.md) - Dokumentasi final role & permission
- [SETUP_ROLE_QUICK_GUIDE.md](./SETUP_ROLE_QUICK_GUIDE.md) - Panduan cepat setup role
- [FIX_PERMISSION_DENIED.md](./FIX_PERMISSION_DENIED.md) - Fix error permission denied

### Testing
- [TESTING_CHECKLIST.md](./TESTING_CHECKLIST.md) - Checklist testing aplikasi

## 🔑 Role & Permission

Aplikasi ini menggunakan 2 role:

### Admin
- ✅ Akses penuh ke semua fitur
- ✅ Tambah, edit, hapus data (pemasukan, pengeluaran, utang piutang)
- ✅ Export PDF laporan
- ✅ Kelola user

### Operator
- ✅ Tambah dan edit data (pemasukan, pengeluaran, utang piutang)
- ✅ Lihat dashboard dan laporan
- ❌ Tidak bisa hapus data
- ❌ Tidak bisa export PDF
- ❌ Tidak bisa kelola user

## 🔒 Keamanan

File-file sensitif yang sudah di-gitignore:
- `lib/firebase_options.dart` - Firebase configuration
- `android/app/google-services.json` - Google Services Android
- `ios/Runner/GoogleService-Info.plist` - Google Services iOS
- `.env` files
- Private keys

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web

## 🛠️ Tech Stack

- Flutter
- Firebase (Auth, Firestore, Storage)
- Provider (State Management)
- PDF Package untuk export laporan
