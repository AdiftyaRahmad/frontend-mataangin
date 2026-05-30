# 🔥 Generate API Keys Manual - Paling Mudah

## Step 1: Buka Firebase Console

Klik link ini: https://console.firebase.google.com/project/mata-angin-e1f8d/settings/general

## Step 2: Scroll ke "Your apps"

Cari section **"Your apps"** di halaman tersebut.

## Step 3: Klik Web App (atau tambah jika belum ada)

### Jika sudah ada Web App:
1. Klik pada app yang ada (icon **</>**)
2. Scroll ke bagian **SDK setup and configuration**
3. Pilih **Config** (bukan npm)
4. Copy semua nilai yang ada

### Jika belum ada Web App:
1. Klik tombol **"Add app"** atau icon **</>**
2. Isi:
   - App nickname: `Mata Angin Web`
   - ✅ Centang "Also set up Firebase Hosting"
3. Klik **Register app**
4. Copy config yang muncul

## Step 4: Copy Config

Anda akan melihat config seperti ini:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "mata-angin-e1f8d.firebaseapp.com",
  projectId: "mata-angin-e1f8d",
  storageBucket: "mata-angin-e1f8d.firebasestorage.app",
  messagingSenderId: "342544453468",
  appId: "1:342544453468:web:...",
  measurementId: "G-..."
};
```

**Copy semua nilai ini!**

## Step 5: Update firebase_options.dart

Buka file: `lib/firebase_options.dart`

Jika file tidak ada, copy dari template:
```bash
copy lib\firebase_options.dart.template lib\firebase_options.dart
```

Update bagian **web**:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'PASTE_apiKey_DISINI',
  appId: 'PASTE_appId_DISINI',
  messagingSenderId: 'PASTE_messagingSenderId_DISINI',
  projectId: 'mata-angin-e1f8d',
  storageBucket: 'PASTE_storageBucket_DISINI',
  authDomain: 'PASTE_authDomain_DISINI',
  measurementId: 'PASTE_measurementId_DISINI',
);
```

## Step 6: Untuk Android (Opsional)

Jika butuh Android:

1. Di Firebase Console, klik icon **Android**
2. Jika belum ada, klik **Add app**
   - Package name: `com.example.frontendMataangin`
   - App nickname: `Mata Angin Android`
3. Copy config yang muncul
4. Update bagian `android` di `firebase_options.dart`

## Step 7: Untuk iOS (Opsional)

Jika butuh iOS:

1. Di Firebase Console, klik icon **Apple**
2. Jika belum ada, klik **Add app**
   - Bundle ID: `com.example.frontendMataangin`
   - App nickname: `Mata Angin iOS`
3. Copy config yang muncul
4. Update bagian `ios` di `firebase_options.dart`

## Step 8: Test!

```bash
flutter run -d chrome
```

Coba login dan akses data. Jika berhasil, selesai!

---

## ✅ Hasil Akhir

File `lib/firebase_options.dart` Anda sekarang punya API keys baru yang aman!

**JANGAN commit file ini ke Git!** (sudah di-gitignore)

---

## 🔒 Set Restrictions (Opsional tapi Recommended)

Setelah selesai, set restrictions di:
https://console.cloud.google.com/apis/credentials?project=mata-angin-e1f8d

Untuk Web API Key:
- Application restrictions: **HTTP referrers**
- Tambahkan:
  - `http://localhost:*/*`
  - `https://mata-angin-e1f8d.web.app/*`
  - `https://mata-angin-e1f8d.firebaseapp.com/*`
