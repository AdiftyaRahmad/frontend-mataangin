# 🚨 URGENT: API Key Bocor - Langkah Keamanan

## ⚠️ PRIORITAS TERTINGGI - LAKUKAN SEGERA!

### 1. REVOKE API Keys di Firebase Console (SEKARANG!)

**Ini adalah langkah PALING PENTING:**

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project: `mata-angin-e1f8d`
3. Pergi ke **Project Settings** (⚙️ icon)
4. Klik tab **Service Accounts**
5. Atau buka [Google Cloud Console](https://console.cloud.google.com/)
6. Pergi ke **APIs & Services > Credentials**
7. **HAPUS atau RESTRICT** API keys berikut:
   - Android: `AIzaSyBdyppWEtpdG_FyuSAnwcJbHj8clvJ3AVE`
   - iOS: `AIzaSyB6wOuj1LaFwoW7WDnfqHuRUV6m6TSpx4M`
   - Web: `AIzaSyA8RIwN1LBnvsnGAXZ5Qcjo_M8Kb3c6by0`

### 2. Generate API Keys Baru dengan Restrictions

**Untuk Web API Key:**
```
- Application restrictions: HTTP referrers
- Website restrictions: 
  - https://mata-angin-e1f8d.web.app/*
  - https://mata-angin-e1f8d.firebaseapp.com/*
  - http://localhost:*/* (untuk development)
```

**Untuk Android API Key:**
```
- Application restrictions: Android apps
- Package name: com.example.frontendMataangin
- SHA-1 certificate fingerprint: (dapatkan dari keystore Anda)
```

**Untuk iOS API Key:**
```
- Application restrictions: iOS apps
- Bundle ID: com.example.frontendMataangin
```

### 3. Hapus File dari Git History

File `firebase_options.dart` sudah ter-commit ke Git. Kita perlu menghapusnya dari history:

**Opsi A: Menggunakan git filter-repo (Recommended)**
```bash
# Install git-filter-repo
pip install git-filter-repo

# Backup repository dulu
cd ..
xcopy /E /I frontend-mataangin frontend-mataangin-backup

# Hapus file dari history
cd frontend-mataangin
git filter-repo --path lib/firebase_options.dart --invert-paths

# Force push ke remote (HATI-HATI!)
git push origin --force --all
```

**Opsi B: Menggunakan BFG Repo-Cleaner**
```bash
# Download BFG dari https://rtyley.github.io/bfg-repo-cleaner/
# Backup repository dulu
cd ..
xcopy /E /I frontend-mataangin frontend-mataangin-backup

# Hapus file dari history
cd frontend-mataangin
java -jar bfg.jar --delete-files firebase_options.dart

# Cleanup
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push
git push origin --force --all
```

**Opsi C: Jika repository masih kecil - Start Fresh**
```bash
# Backup kode lokal
cd ..
xcopy /E /I frontend-mataangin frontend-mataangin-backup

# Hapus repository di GitHub/GitLab
# Buat repository baru
# Push kode bersih ke repository baru
cd frontend-mataangin
git remote set-url origin <URL_REPOSITORY_BARU>
git push -u origin main
```

### 4. Update File Lokal

File sudah di-update:
- ✅ `.gitignore` - menambahkan `lib/firebase_options.dart`
- ✅ `lib/firebase_options.dart.template` - template tanpa API keys
- ✅ `SETUP_FIREBASE.md` - instruksi setup

### 5. Commit Perubahan (Tanpa API Keys)

```bash
# Add perubahan
git add .gitignore
git add lib/firebase_options.dart.template
git add SETUP_FIREBASE.md
git add URGENT_SECURITY_STEPS.md

# Commit
git commit -m "security: Add firebase_options.dart to .gitignore and create template"

# Push (setelah membersihkan history)
git push origin main
```

### 6. Verifikasi Keamanan

```bash
# Cek apakah file masih ada di Git
git ls-files | findstr firebase_options.dart

# Seharusnya hanya menampilkan:
# lib/firebase_options.dart.template

# Cek .gitignore
type .gitignore | findstr firebase_options
```

### 7. Monitor Firebase Usage

1. Buka Firebase Console
2. Pergi ke **Usage and billing**
3. Monitor untuk aktivitas mencurigakan
4. Set up billing alerts

### 8. Enable Firebase App Check (Extra Security)

1. Buka Firebase Console > App Check
2. Enable untuk semua apps (Web, Android, iOS)
3. Ini akan memverifikasi bahwa requests datang dari app Anda

## Checklist

- [ ] Revoke/Restrict API keys lama di Firebase Console
- [ ] Generate API keys baru dengan restrictions
- [ ] Hapus firebase_options.dart dari Git history
- [ ] Update firebase_options.dart lokal dengan keys baru
- [ ] Commit perubahan .gitignore dan template
- [ ] Verifikasi file tidak ada di Git
- [ ] Monitor Firebase usage
- [ ] Enable App Check
- [ ] Inform team members (jika ada)

## Kontak Darurat

Jika Anda melihat aktivitas mencurigakan:
- Firebase Support: https://firebase.google.com/support
- Google Cloud Support: https://cloud.google.com/support

## Catatan Penting

⚠️ **JANGAN** push ke Git sebelum membersihkan history!
⚠️ **SEGERA** revoke API keys yang bocor!
⚠️ **BACKUP** repository sebelum menjalankan git filter commands!
