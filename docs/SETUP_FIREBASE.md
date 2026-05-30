# Firebase Setup Instructions

## ⚠️ IMPORTANT: API Keys Security

File `lib/firebase_options.dart` berisi API keys yang sensitif dan **TIDAK BOLEH** di-commit ke Git.

## Setup untuk Developer Baru

1. **Copy template file:**
   ```bash
   copy lib\firebase_options.dart.template lib\firebase_options.dart
   ```

2. **Dapatkan Firebase credentials:**
   - Buka [Firebase Console](https://console.firebase.google.com/)
   - Pilih project: `mata-angin-e1f8d`
   - Pergi ke Project Settings > General
   - Scroll ke bagian "Your apps"
   - Copy credentials untuk setiap platform (Android, iOS, Web)

3. **Update `lib/firebase_options.dart`:**
   - Ganti semua placeholder `YOUR_XXX_HERE` dengan credentials yang sebenarnya
   - Simpan file

4. **Verifikasi:**
   - File `lib/firebase_options.dart` TIDAK akan ter-commit ke Git (sudah ada di .gitignore)
   - Jangan pernah share file ini atau push ke repository

## Regenerate Firebase Options (Alternatif)

Jika Anda memiliki Firebase CLI terinstall:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login ke Firebase
firebase login

# Generate firebase_options.dart
flutterfire configure
```

## Jika API Key Bocor

1. **Segera revoke API key di Firebase Console:**
   - Buka Firebase Console > Project Settings > Service Accounts
   - Atau Google Cloud Console > APIs & Services > Credentials
   - Hapus atau restrict API key yang bocor

2. **Generate API key baru:**
   - Buat API key baru dengan restrictions yang tepat
   - Update `firebase_options.dart` dengan key baru

3. **Set API restrictions:**
   - HTTP referrers untuk Web
   - Package name untuk Android
   - Bundle ID untuk iOS

## Security Best Practices

- ✅ Selalu gunakan `.gitignore` untuk file sensitif
- ✅ Set API restrictions di Firebase Console
- ✅ Enable App Check untuk extra security
- ✅ Monitor usage di Firebase Console
- ❌ Jangan hardcode API keys di kode
- ❌ Jangan commit credentials ke Git
- ❌ Jangan share API keys via chat/email
