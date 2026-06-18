# 🔒 Security Guide - Mata Angin

## File Sensitif yang Sudah Diamankan

### ✅ File yang di-ignore dari Git:
- `lib/firebase_options.dart` - Firebase API keys
- `.env` dan `.env.*` - Environment variables
- `*.key`, `*.pem` - Private keys
- `google-services.json` - Android Firebase config
- `GoogleService-Info.plist` - iOS Firebase config
- `firebase_app_id_file.json` - Firebase app ID

### ✅ Template Files (Aman untuk di-commit):
- `lib/firebase_options.dart.template` - Template tanpa API keys

## Cara Setup untuk Developer Baru

1. **Clone repository:**
   ```bash
   git clone <repository-url>
   cd frontend-mataangin
   ```

2. **Setup Firebase credentials:**
   ```bash
   # Copy template
   copy lib\firebase_options.dart.template lib\firebase_options.dart
   
   # Edit lib/firebase_options.dart dan isi dengan credentials yang benar
   # Minta credentials dari team lead atau dapatkan dari Firebase Console
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run app:**
   ```bash
   flutter run -d chrome
   ```

## Security Best Practices

### ✅ DO:
- Selalu check `.gitignore` sebelum commit
- Gunakan environment variables untuk secrets
- Set API restrictions di Firebase Console
- Enable Firebase App Check
- Monitor Firebase usage regularly
- Use strong authentication rules
- Keep dependencies updated
- Review code untuk hardcoded secrets

### ❌ DON'T:
- Commit API keys atau credentials
- Share credentials via chat/email
- Use production keys untuk development
- Disable security rules
- Ignore security warnings
- Push secrets ke public repositories

## Firebase Security Checklist

### API Key Restrictions

**Web API Key:**
```
Application restrictions: HTTP referrers
Allowed referrers:
  - https://mata-angin-e1f8d.web.app/*
  - https://mata-angin-e1f8d.firebaseapp.com/*
  - http://localhost:*/* (development only)
```

**Android API Key:**
```
Application restrictions: Android apps
Package name: com.example.frontendMataangin
SHA-1: <your-sha1-fingerprint>
```

**iOS API Key:**
```
Application restrictions: iOS apps
Bundle ID: com.example.frontendMataangin
```

### Firestore Security Rules

Pastikan Firestore rules sudah di-set dengan benar:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Require authentication for all reads/writes
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // More specific rules per collection
    match /pemasukan/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     request.auth.token.email_verified == true;
    }
    
    match /pengeluaran/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     request.auth.token.email_verified == true;
    }
    
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Firebase Authentication Settings

1. **Enable Email/Password authentication**
2. **Set password requirements:**
   - Minimum 6 characters (sudah di-implement di app)
   - Consider adding: uppercase, lowercase, numbers, special chars
3. **Enable email verification**
4. **Set up password reset**
5. **Configure authorized domains**

## Monitoring & Alerts

### Firebase Console Monitoring:
1. **Usage & Billing** - Monitor untuk unusual spikes
2. **Authentication** - Check login patterns
3. **Firestore** - Monitor read/write operations
4. **Crashlytics** - Track app crashes

### Set Up Alerts:
- Billing alerts untuk unexpected costs
- Authentication alerts untuk suspicious activity
- Performance alerts untuk slow queries

## Incident Response

### Jika API Key Bocor:

1. **Immediate Actions:**
   - [ ] Revoke compromised API key di Firebase Console
   - [ ] Generate new API key dengan restrictions
   - [ ] Update app dengan key baru
   - [ ] Monitor Firebase usage untuk suspicious activity

2. **Investigation:**
   - [ ] Check Firebase logs untuk unauthorized access
   - [ ] Review recent commits untuk source of leak
   - [ ] Check if data was accessed/modified

3. **Prevention:**
   - [ ] Update .gitignore
   - [ ] Clean Git history
   - [ ] Educate team tentang security practices
   - [ ] Implement pre-commit hooks

### Jika Data Breach:

1. **Immediate Actions:**
   - [ ] Disable affected services
   - [ ] Change all credentials
   - [ ] Notify affected users
   - [ ] Document the incident

2. **Recovery:**
   - [ ] Restore from backup if needed
   - [ ] Implement additional security measures
   - [ ] Update security rules
   - [ ] Conduct security audit

## Tools & Resources

### Security Scanning:
- `git-secrets` - Prevent committing secrets
- `trufflehog` - Find secrets in Git history
- `gitleaks` - Detect hardcoded secrets

### Firebase Tools:
- Firebase Console: https://console.firebase.google.com/
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

### Documentation:
- Firebase Security: https://firebase.google.com/docs/rules
- Flutter Security: https://flutter.dev/docs/deployment/security
- OWASP Mobile: https://owasp.org/www-project-mobile-top-10/

## Contact

Untuk security concerns atau questions:
- Team Lead: [contact info]
- Security Team: [contact info]
- Firebase Support: https://firebase.google.com/support

## Version History

- 2026-05-29: Initial security setup
  - Added .gitignore rules
  - Created firebase_options.dart.template
  - Documented security practices
