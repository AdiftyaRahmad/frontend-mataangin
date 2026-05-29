# 🔑 Panduan Step-by-Step: Generate API Keys Baru dengan Restrictions

## 📌 Overview

Anda perlu generate 3 API keys baru (atau set restrictions untuk yang existing):
1. **Web API Key** - untuk aplikasi web/browser
2. **Android API Key** - untuk aplikasi Android
3. **iOS API Key** - untuk aplikasi iOS

---

## 🌐 PART 1: Web API Key (Untuk Flutter Web)

### Step 1: Buka Google Cloud Console

1. Buka browser dan pergi ke: https://console.cloud.google.com/
2. Login dengan akun Google yang sama dengan Firebase
3. Pastikan project yang dipilih adalah: **mata-angin-e1f8d**
   - Lihat di bagian atas, ada dropdown project name
   - Jika bukan, klik dropdown dan pilih **mata-angin-e1f8d**

### Step 2: Pergi ke API Credentials

1. Di sidebar kiri, klik **☰** (hamburger menu)
2. Scroll ke bawah, cari section **APIs & Services**
3. Klik **Credentials**
4. Anda akan melihat list API keys yang ada

### Step 3: Cari Web API Key yang Lama

1. Di list credentials, cari API key dengan nama yang mengandung "Web" atau "Browser"
2. Atau cari key dengan value: `AIzaSyA8RIwN1LBnvsnGAXZ5Qcjo_M8Kb3c6by0`
3. Klik nama API key tersebut untuk membuka detail

### Step 4: Set Restrictions untuk Web API Key

#### A. Application Restrictions:

1. Di halaman detail API key, scroll ke section **Application restrictions**
2. Pilih radio button: **HTTP referrers (web sites)**
3. Klik **+ ADD AN ITEM**
4. Masukkan referrers berikut satu per satu:

   ```
   http://localhost:*/*
   ```
   Klik **DONE**, lalu klik **+ ADD AN ITEM** lagi

   ```
   https://mata-angin-e1f8d.web.app/*
   ```
   Klik **DONE**, lalu klik **+ ADD AN ITEM** lagi

   ```
   https://mata-angin-e1f8d.firebaseapp.com/*
   ```
   Klik **DONE**

5. Jika Anda punya custom domain, tambahkan juga:
   ```
   https://yourdomain.com/*
   ```

#### B. API Restrictions:

1. Scroll ke bawah ke section **API restrictions**
2. Pilih radio button: **Restrict key**
3. Klik dropdown **Select APIs**
4. Centang API berikut (cari dengan search box):
   - ✅ **Cloud Firestore API**
   - ✅ **Firebase Authentication API** (atau Identity Toolkit API)
   - ✅ **Firebase Storage API**
   - ✅ **Firebase Installations API**
   - ✅ **Token Service API**
   - ✅ **Firebase App Check API** (jika ada)

5. Klik **OK**

#### C. Save Changes:

1. Scroll ke atas
2. Klik tombol **SAVE** (biru, di bagian atas)
3. Tunggu beberapa detik sampai muncul notifikasi "API key saved"

### Step 5: Copy Web API Key Baru

1. Setelah save, Anda akan kembali ke halaman detail
2. Di bagian atas, ada field **API key** dengan tombol **SHOW KEY**
3. Klik **SHOW KEY**
4. Copy key tersebut (klik icon copy atau select + Ctrl+C)
5. Simpan di notepad sementara dengan label "WEB API KEY"

---

## 🤖 PART 2: Android API Key

### Step 1: Dapatkan SHA-1 Fingerprint

Anda perlu SHA-1 fingerprint dari keystore Android Anda.

#### Untuk Debug Keystore (Development):

1. Buka Command Prompt atau Terminal
2. Jalankan command berikut:

   **Windows:**
   ```cmd
   cd %USERPROFILE%\.android
   keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

   **Mac/Linux:**
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

3. Cari baris yang berisi **SHA1:**
4. Copy nilai SHA-1 (format: `AA:BB:CC:DD:...`)
5. Simpan di notepad dengan label "DEBUG SHA-1"

#### Untuk Release Keystore (Production):

Jika Anda sudah punya release keystore:

```cmd
keytool -list -v -keystore path\to\your\release.keystore -alias your-alias
```

Masukkan password keystore Anda, lalu copy SHA-1 fingerprint.

### Step 2: Buka Firebase Console

1. Buka: https://console.firebase.google.com/
2. Pilih project: **mata-angin-e1f8d**
3. Klik icon ⚙️ (Settings) di sidebar kiri
4. Klik **Project settings**

### Step 3: Tambahkan SHA-1 ke Android App

1. Scroll ke bawah ke section **Your apps**
2. Cari Android app Anda (icon Android hijau)
3. Jika belum ada Android app, klik **Add app** > **Android**
   - Package name: `com.example.frontendMataangin`
   - App nickname: `Mata Angin Android`
   - Klik **Register app**

4. Jika sudah ada, klik pada Android app tersebut
5. Scroll ke section **SHA certificate fingerprints**
6. Klik **Add fingerprint**
7. Paste SHA-1 yang Anda copy tadi
8. Klik **Save**

### Step 4: Set Restrictions untuk Android API Key

1. Kembali ke Google Cloud Console: https://console.cloud.google.com/
2. Pergi ke **APIs & Services** > **Credentials**
3. Cari API key untuk Android (atau yang lama: `AIzaSyBdyppWEtpdG_FyuSAnwcJbHj8clvJ3AVE`)
4. Klik nama API key tersebut

#### A. Application Restrictions:

1. Di section **Application restrictions**
2. Pilih radio button: **Android apps**
3. Klik **+ ADD AN ITEM**
4. Masukkan:
   - **Package name:** `com.example.frontendMataangin`
   - **SHA-1 certificate fingerprint:** (paste SHA-1 yang Anda copy)
5. Klik **DONE**

#### B. API Restrictions:

1. Scroll ke section **API restrictions**
2. Pilih: **Restrict key**
3. Centang API yang sama seperti Web:
   - ✅ Cloud Firestore API
   - ✅ Firebase Authentication API
   - ✅ Firebase Storage API
   - ✅ Firebase Installations API
   - ✅ Token Service API

#### C. Save:

1. Klik **SAVE** di bagian atas
2. Copy API key dan simpan dengan label "ANDROID API KEY"

---

## 🍎 PART 3: iOS API Key

### Step 1: Dapatkan Bundle ID

Bundle ID untuk iOS app Anda adalah: `com.example.frontendMataangin`

(Ini sudah terlihat di `firebase_options.dart` Anda)

### Step 2: Tambahkan iOS App di Firebase Console

1. Buka: https://console.firebase.google.com/
2. Pilih project: **mata-angin-e1f8d**
3. Klik ⚙️ > **Project settings**
4. Scroll ke **Your apps**
5. Jika belum ada iOS app, klik **Add app** > **iOS**
   - iOS bundle ID: `com.example.frontendMataangin`
   - App nickname: `Mata Angin iOS`
   - Klik **Register app**

### Step 3: Set Restrictions untuk iOS API Key

1. Kembali ke Google Cloud Console: https://console.cloud.google.com/
2. Pergi ke **APIs & Services** > **Credentials**
3. Cari API key untuk iOS (atau yang lama: `AIzaSyB6wOuj1LaFwoW7WDnfqHuRUV6m6TSpx4M`)
4. Klik nama API key tersebut

#### A. Application Restrictions:

1. Di section **Application restrictions**
2. Pilih radio button: **iOS apps**
3. Klik **+ ADD AN ITEM**
4. Masukkan Bundle ID: `com.example.frontendMataangin`
5. Klik **DONE**

#### B. API Restrictions:

1. Scroll ke section **API restrictions**
2. Pilih: **Restrict key**
3. Centang API yang sama:
   - ✅ Cloud Firestore API
   - ✅ Firebase Authentication API
   - ✅ Firebase Storage API
   - ✅ Firebase Installations API
   - ✅ Token Service API

#### C. Save:

1. Klik **SAVE**
2. Copy API key dan simpan dengan label "IOS API KEY"

---

## 🔄 PART 4: Update firebase_options.dart

Sekarang Anda punya 3 API keys baru. Saatnya update file lokal.

### Step 1: Buka File

1. Buka file: `d:\frontend-mataangin\lib\firebase_options.dart`
2. Jika file tidak ada (karena sudah di-gitignore), copy dari template:
   ```cmd
   copy lib\firebase_options.dart.template lib\firebase_options.dart
   ```

### Step 2: Replace API Keys

Edit file `firebase_options.dart` dan ganti API keys:

```dart
class DefaultFirebaseOptions {
  // ... kode lainnya ...

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PASTE_ANDROID_API_KEY_BARU_DISINI',  // ← Ganti ini
    appId: '1:342544453468:android:1288cef4d3500905b67b99',
    messagingSenderId: '342544453468',
    projectId: 'mata-angin-e1f8d',
    storageBucket: 'mata-angin-e1f8d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PASTE_IOS_API_KEY_BARU_DISINI',  // ← Ganti ini
    appId: '1:342544453468:ios:8d79e8f2964eb668b67b99',
    messagingSenderId: '342544453468',
    projectId: 'mata-angin-e1f8d',
    storageBucket: 'mata-angin-e1f8d.firebasestorage.app',
    iosBundleId: 'com.example.frontendMataangin',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PASTE_WEB_API_KEY_BARU_DISINI',  // ← Ganti ini
    appId: '1:342544453468:web:60621eace4711b7bb67b99',
    messagingSenderId: '342544453468',
    projectId: 'mata-angin-e1f8d',
    storageBucket: 'mata-angin-e1f8d.firebasestorage.app',
    authDomain: 'mata-angin-e1f8d.firebaseapp.com',
    measurementId: 'G-LL0G9ZLF3J',
  );
}
```

### Step 3: Save File

1. Save file (Ctrl+S)
2. **JANGAN commit file ini ke Git!** (sudah di-gitignore)

---

## ✅ PART 5: Test Aplikasi

### Step 1: Test Flutter Web

```bash
flutter run -d chrome
```

1. Coba login
2. Coba akses Firestore (lihat dashboard, laporan, dll)
3. Pastikan tidak ada error di console

### Step 2: Test Android (Jika Ada)

```bash
flutter run -d android
```

Test fungsi yang sama.

### Step 3: Monitor Firebase Console

1. Buka Firebase Console
2. Pergi ke **Authentication** > **Users**
3. Coba login dari app, pastikan muncul di sini
4. Pergi ke **Firestore Database**
5. Pastikan data bisa dibaca/ditulis

---

## 🗑️ PART 6: Hapus API Keys Lama

**HANYA setelah memastikan app berjalan dengan keys baru:**

### Step 1: Kembali ke Google Cloud Console

1. Buka: https://console.cloud.google.com/
2. Pergi ke **APIs & Services** > **Credentials**

### Step 2: Hapus atau Disable Keys Lama

Untuk setiap key lama:

1. Klik **⋮** (three dots) di sebelah kanan API key
2. Pilih **Delete** atau **Disable**
3. Confirm

**Keys yang harus dihapus:**
- ❌ `AIzaSyBdyppWEtpdG_FyuSAnwcJbHj8clvJ3AVE` (Android lama)
- ❌ `AIzaSyB6wOuj1LaFwoW7WDnfqHuRUV6m6TSpx4M` (iOS lama)
- ❌ `AIzaSyA8RIwN1LBnvsnGAXZ5Qcjo_M8Kb3c6by0` (Web lama)

---

## 📋 Checklist Final

- [ ] ✅ Generate/Set restrictions untuk Web API Key
- [ ] ✅ Dapatkan SHA-1 fingerprint untuk Android
- [ ] ✅ Generate/Set restrictions untuk Android API Key
- [ ] ✅ Generate/Set restrictions untuk iOS API Key
- [ ] ✅ Update `firebase_options.dart` dengan keys baru
- [ ] ✅ Test aplikasi (Web, Android, iOS)
- [ ] ✅ Verifikasi di Firebase Console
- [ ] ✅ Hapus API keys lama
- [ ] ✅ Monitor usage untuk 24-48 jam

---

## 🆘 Troubleshooting

### Error: "API key not valid"

**Solusi:**
1. Pastikan API restrictions sudah include semua API yang dibutuhkan
2. Tunggu 5-10 menit untuk propagation
3. Clear browser cache dan restart app

### Error: "This app is not authorized to use Firebase Authentication"

**Solusi:**
1. Cek Application restrictions sudah benar (HTTP referrers untuk Web)
2. Pastikan domain sudah ditambahkan di Firebase Console > Authentication > Settings > Authorized domains

### Error: "The provided API key is invalid"

**Solusi:**
1. Double-check API key yang di-copy (tidak ada spasi atau karakter extra)
2. Pastikan menggunakan key yang benar untuk platform yang benar

### SHA-1 Fingerprint Tidak Ditemukan

**Solusi:**
1. Pastikan Java JDK terinstall
2. Pastikan `keytool` ada di PATH
3. Cek lokasi keystore dengan benar

---

## 📞 Butuh Bantuan?

Jika ada masalah:
1. Screenshot error message
2. Check Firebase Console > Usage untuk melihat request yang failed
3. Check browser console (F12) untuk error details
4. Hubungi Firebase Support: https://firebase.google.com/support

---

## 🎉 Selesai!

Setelah semua langkah ini, API keys Anda sekarang:
- ✅ Aman dengan restrictions yang tepat
- ✅ Hanya bisa digunakan dari app/domain yang authorized
- ✅ Tidak akan bocor lagi karena sudah di-gitignore
- ✅ Monitored di Firebase Console

**Jangan lupa:** Hapus keys lama setelah memastikan semuanya berjalan!
