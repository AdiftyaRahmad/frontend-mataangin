# 🔑 Quick Reference: API Key Restrictions

## 📱 Ringkasan Cepat

### 1️⃣ Web API Key

**Google Cloud Console** → **APIs & Services** → **Credentials** → Pilih Web API Key

```
Application Restrictions: HTTP referrers (web sites)
├─ http://localhost:*/*
├─ https://mata-angin-e1f8d.web.app/*
└─ https://mata-angin-e1f8d.firebaseapp.com/*

API Restrictions: Restrict key
├─ Cloud Firestore API
├─ Firebase Authentication API
├─ Firebase Storage API
├─ Firebase Installations API
└─ Token Service API
```

---

### 2️⃣ Android API Key

**Dapatkan SHA-1 dulu:**
```cmd
cd %USERPROFILE%\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Google Cloud Console** → **APIs & Services** → **Credentials** → Pilih Android API Key

```
Application Restrictions: Android apps
├─ Package name: com.example.frontendMataangin
└─ SHA-1: [YOUR_SHA1_FINGERPRINT]

API Restrictions: Restrict key
├─ Cloud Firestore API
├─ Firebase Authentication API
├─ Firebase Storage API
├─ Firebase Installations API
└─ Token Service API
```

---

### 3️⃣ iOS API Key

**Google Cloud Console** → **APIs & Services** → **Credentials** → Pilih iOS API Key

```
Application Restrictions: iOS apps
└─ Bundle ID: com.example.frontendMataangin

API Restrictions: Restrict key
├─ Cloud Firestore API
├─ Firebase Authentication API
├─ Firebase Storage API
├─ Firebase Installations API
└─ Token Service API
```

---

## 🔗 Links Penting

| Resource | URL |
|----------|-----|
| Google Cloud Console | https://console.cloud.google.com/ |
| Firebase Console | https://console.firebase.google.com/ |
| API Credentials | https://console.cloud.google.com/apis/credentials |
| Firebase Project Settings | https://console.firebase.google.com/project/mata-angin-e1f8d/settings/general |

---

## 📝 Update firebase_options.dart

```dart
// lib/firebase_options.dart

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_NEW_ANDROID_API_KEY',  // ← Update
  appId: '1:342544453468:android:1288cef4d3500905b67b99',
  messagingSenderId: '342544453468',
  projectId: 'mata-angin-e1f8d',
  storageBucket: 'mata-angin-e1f8d.firebasestorage.app',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_NEW_IOS_API_KEY',  // ← Update
  appId: '1:342544453468:ios:8d79e8f2964eb668b67b99',
  messagingSenderId: '342544453468',
  projectId: 'mata-angin-e1f8d',
  storageBucket: 'mata-angin-e1f8d.firebasestorage.app',
  iosBundleId: 'com.example.frontendMataangin',
);

static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_NEW_WEB_API_KEY',  // ← Update
  appId: '1:342544453468:web:60621eace4711b7bb67b99',
  messagingSenderId: '342544453468',
  projectId: 'mata-angin-e1f8d',
  storageBucket: 'mata-angin-e1f8d.firebasestorage.app',
  authDomain: 'mata-angin-e1f8d.firebaseapp.com',
  measurementId: 'G-LL0G9ZLF3J',
);
```

---

## ✅ Checklist

```
[ ] 1. Buka Google Cloud Console
[ ] 2. Pergi ke APIs & Services > Credentials
[ ] 3. Set restrictions untuk Web API Key
[ ] 4. Dapatkan SHA-1 fingerprint (Android)
[ ] 5. Set restrictions untuk Android API Key
[ ] 6. Set restrictions untuk iOS API Key
[ ] 7. Copy semua 3 API keys baru
[ ] 8. Update lib/firebase_options.dart
[ ] 9. Test aplikasi (flutter run -d chrome)
[ ] 10. Verifikasi di Firebase Console
[ ] 11. Hapus API keys lama
[ ] 12. Monitor usage 24-48 jam
```

---

## 🗑️ Keys Lama yang Harus Dihapus

**SETELAH memastikan app berjalan dengan keys baru:**

```
❌ AIzaSyBdyppWEtpdG_FyuSAnwcJbHj8clvJ3AVE  (Android)
❌ AIzaSyB6wOuj1LaFwoW7WDnfqHuRUV6m6TSpx4M  (iOS)
❌ AIzaSyA8RIwN1LBnvsnGAXZ5Qcjo_M8Kb3c6by0  (Web)
```

**Cara hapus:**
Google Cloud Console → APIs & Services → Credentials → ⋮ → Delete

---

## 🆘 Quick Troubleshooting

| Error | Solusi |
|-------|--------|
| "API key not valid" | Tunggu 5-10 menit untuk propagation |
| "Not authorized" | Cek Application restrictions |
| "Invalid API key" | Double-check tidak ada spasi/typo |
| SHA-1 not found | Install Java JDK, cek PATH |

---

## 📞 Support

- Firebase Support: https://firebase.google.com/support
- Documentation: https://firebase.google.com/docs/projects/api-keys

---

**💡 Tip:** Simpan API keys baru di password manager (1Password, LastPass, dll) untuk backup!
