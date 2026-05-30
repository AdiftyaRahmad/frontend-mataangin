# 📱 Setup Android API Key - Step by Step

## 🎯 Tujuan
Generate API key Android yang BARU dan aman untuk menggantikan yang bocor.

---

## 📋 Step 1: Buka Firebase Console

**Klik link ini:**
```
https://console.firebase.google.com/project/mata-angin-e1f8d/settings/general
```

Login dengan akun Google Anda.

---

## 📋 Step 2: Cari Android App

1. Scroll ke bawah sampai ketemu section **"Your apps"**
2. Cari app dengan icon **Android** (robot hijau)
3. Anda akan lihat app dengan nama seperti:
   - Package name: `com.example.frontend_mataangin`
   - App ID: `1:342544453468:android:1288cef4d3500905b67b99`

---

## 📋 Step 3: Hapus Android App Lama (Opsional tapi Recommended)

**Untuk generate API key baru yang benar-benar fresh:**

1. Klik icon **⚙️** (settings) di sebelah kanan Android app
2. Pilih **"Delete app"**
3. Ketik nama app untuk konfirmasi
4. Klik **Delete**

⚠️ **Jangan khawatir!** Data Firestore Anda tidak akan terhapus. Hanya konfigurasi app yang dihapus.

---

## 📋 Step 4: Tambah Android App Baru

1. Klik tombol **"Add app"**
2. Pilih icon **Android**
3. Isi form:

   **Android package name:**
   ```
   com.example.frontend_mataangin
   ```
   
   **App nickname (optional):**
   ```
   Mata Angin Android
   ```
   
   **Debug signing certificate SHA-1 (optional):**
   - Kosongkan dulu (bisa ditambah nanti)
   - Atau dapatkan dengan command:
     ```cmd
     cd %USERPROFILE%\.android
     keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
     Copy nilai SHA-1 yang muncul

4. Klik **"Register app"**

---

## 📋 Step 5: Download google-services.json BARU

1. Setelah register, akan muncul tombol **"Download google-services.json"**
2. Klik tombol tersebut
3. File akan terdownload ke folder Downloads Anda

---

## 📋 Step 6: Replace File Lama

1. **Backup file lama dulu:**
   ```cmd
   copy android\app\google-services.json android\app\google-services.json.backup
   ```

2. **Copy file baru:**
   - Buka folder Downloads
   - Copy file `google-services.json` yang baru didownload
   - Paste ke: `d:\frontend-mataangin\android\app\`
   - Replace file yang lama

---

## 📋 Step 7: Extract API Key dari File Baru

Buka file `android\app\google-services.json` yang baru.

Cari bagian ini:
```json
"api_key": [
  {
    "current_key": "AIzaSy..."  // ← INI API KEY BARU
  }
]
```

Dan ini:
```json
"mobilesdk_app_id": "1:342544453468:android:..."  // ← INI APP ID
```

**Copy kedua nilai tersebut!**

---

## 📋 Step 8: Update firebase_options.dart

Buka file: `lib\firebase_options.dart`

Update bagian Android:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'PASTE_current_key_DISINI',           // ← Dari google-services.json
  appId: 'PASTE_mobilesdk_app_id_DISINI',       // ← Dari google-services.json
  messagingSenderId: '342544453468',
  projectId: 'mata-angin-e1f8d',
  storageBucket: 'mata-angin-e1f8d.firebasestorage.app',
);
```

**Save file!**

---

## 📋 Step 9: Test Android App

```bash
flutter run -d android
```

Atau jika pakai emulator:
```bash
flutter emulators --launch <emulator_name>
flutter run
```

**Test:**
1. Coba login
2. Coba akses data (dashboard, laporan)
3. Pastikan tidak ada error

---

## 📋 Step 10: Set API Restrictions (PENTING!)

1. **Buka Google Cloud Console:**
   ```
   https://console.cloud.google.com/apis/credentials?project=mata-angin-e1f8d
   ```

2. **Cari API key Android yang baru** (biasanya bernama "Android key (auto created by Firebase)")

3. **Klik nama API key tersebut**

4. **Set Application restrictions:**
   - Pilih: **Android apps**
   - Klik **+ ADD AN ITEM**
   - Package name: `com.example.frontend_mataangin`
   - SHA-1 fingerprint: (paste SHA-1 yang Anda dapatkan tadi)
   - Klik **DONE**

5. **Set API restrictions:**
   - Pilih: **Restrict key**
   - Centang:
     - ✅ Cloud Firestore API
     - ✅ Firebase Authentication API
     - ✅ Firebase Installations API
     - ✅ Firebase Storage API
     - ✅ Token Service API

6. **Klik SAVE**

---

## ✅ Checklist

- [ ] Buka Firebase Console
- [ ] Hapus Android app lama (opsional)
- [ ] Tambah Android app baru
- [ ] Download google-services.json baru
- [ ] Backup file lama
- [ ] Replace dengan file baru
- [ ] Extract API key dan App ID
- [ ] Update firebase_options.dart
- [ ] Test app di Android
- [ ] Set API restrictions di Google Cloud Console
- [ ] Hapus API key lama

---

## 🆘 Troubleshooting

**Error: "Default FirebaseApp is not initialized"**
- Pastikan `google-services.json` ada di `android/app/`
- Clean dan rebuild: `flutter clean && flutter pub get`

**Error: "API key not valid"**
- Tunggu 5-10 menit untuk propagation
- Cek API restrictions sudah benar

**Error: "Package name mismatch"**
- Pastikan package name di Firebase Console sama dengan di `android/app/build.gradle`
- Cek: `applicationId "com.example.frontend_mataangin"`

---

## 📞 Butuh Bantuan?

Jika ada error, screenshot dan tunjukkan:
1. Error message
2. File `google-services.json` (bagian api_key)
3. File `firebase_options.dart` (bagian android)
