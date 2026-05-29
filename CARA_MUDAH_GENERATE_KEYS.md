# ⚡ Cara Paling Mudah Generate API Keys Baru

## Opsi 1: FlutterFire CLI (Otomatis) ⭐ RECOMMENDED

### Command:
```bash
dart pub global run flutterfire_cli:flutterfire configure
```

### Atau jalankan script:
```bash
regenerate_keys.bat
```

### Jawab pertanyaan:
1. "Reuse existing firebase.json?" → Ketik: **yes** → Enter
2. "Select project" → Pilih: **mata-angin-e1f8d** → Enter
3. "Select platforms" → Pilih semua (android, ios, web) → Enter

### Selesai!
File `lib/firebase_options.dart` akan otomatis dibuat dengan API keys baru.

---

## Opsi 2: Manual dari Firebase Console

### 1. Buka Firebase Console
https://console.firebase.google.com/project/mata-angin-e1f8d/settings/general

### 2. Scroll ke "Your apps"

### 3. Untuk Web:
- Klik icon **</>** (Web)
- Jika belum ada app, klik "Add app"
- Copy semua config (apiKey, appId, dll)

### 4. Untuk Android:
- Klik icon **Android**
- Jika belum ada app, klik "Add app"
- Download `google-services.json`
- Atau copy config manual

### 5. Untuk iOS:
- Klik icon **Apple**
- Jika belum ada app, klik "Add app"
- Download `GoogleService-Info.plist`
- Atau copy config manual

### 6. Update lib/firebase_options.dart
Paste semua config ke file tersebut.

---

## Opsi 3: Buat API Key Baru di Google Cloud Console

### 1. Buka:
https://console.cloud.google.com/apis/credentials?project=mata-angin-e1f8d

### 2. Klik "CREATE CREDENTIALS" → "API key"

### 3. Ulangi 3x untuk:
- Web API Key
- Android API Key  
- iOS API Key

### 4. Set restrictions (lihat GUIDE_GENERATE_NEW_API_KEYS.md)

### 5. Copy keys dan update firebase_options.dart

---

## ✅ Verifikasi

Test app:
```bash
flutter run -d chrome
```

Coba login dan akses data. Jika berhasil, API keys sudah bekerja!

---

## 🆘 Troubleshooting

**Error: "flutterfire not found"**
```bash
dart pub global activate flutterfire_cli
```

**Error: "Firebase CLI not installed"**
```bash
npm install -g firebase-tools
firebase login
```

**Error: "Project not found"**
- Pastikan sudah login: `firebase login`
- Cek project ID: `mata-angin-e1f8d`
