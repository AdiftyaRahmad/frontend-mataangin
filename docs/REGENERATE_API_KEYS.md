# 🔄 Regenerate API Keys Otomatis

## Cara Tercepat: Gunakan FlutterFire CLI

### Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Step 2: Login ke Firebase

```bash
firebase login
```

Jika belum punya Firebase CLI, install dulu:
```bash
npm install -g firebase-tools
```

### Step 3: Generate API Keys Baru

```bash
flutterfire configure
```

### Step 4: Pilih Options

1. Pilih project: **mata-angin-e1f8d**
2. Pilih platforms yang mau di-generate:
   - [x] android
   - [x] ios  
   - [x] web
3. Tekan Enter

### Step 5: Selesai!

File `lib/firebase_options.dart` akan otomatis ter-generate dengan API keys baru!

---

## ✅ Hasil

FlutterFire CLI akan:
- ✅ Generate API keys baru untuk semua platform
- ✅ Buat file `lib/firebase_options.dart` otomatis
- ✅ Set basic restrictions
- ✅ Register apps di Firebase Console

---

## 🔒 Setelah Generate

Jangan lupa set restrictions tambahan di Google Cloud Console:
https://console.cloud.google.com/apis/credentials

Untuk Web API Key, tambahkan HTTP referrers:
- http://localhost:*/*
- https://mata-angin-e1f8d.web.app/*
- https://mata-angin-e1f8d.firebaseapp.com/*
