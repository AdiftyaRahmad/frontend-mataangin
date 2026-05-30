# ✅ Testing Checklist - Role-Based Access Control

## 🎯 Status Implementasi

### ✅ SELESAI - Semua File Sudah Diupdate!

- [x] `UserModel` - Field role ditambahkan
- [x] `AuthService` - Fetch role dari Firestore
- [x] `TokenManager` - Save/get role
- [x] `PermissionHelper` - Helper untuk cek permission
- [x] `AdminOnlyWidget` - Widget untuk hide/show
- [x] `Pemasukan View` - Tombol edit/delete wrapped
- [x] `Pengeluaran View` - Tombol edit/delete wrapped
- [x] `Utang Piutang View` - Tombol edit/delete wrapped
- [x] `Laporan View` - Export PDF button wrapped
- [x] `Firestore Rules` - Role-based access rules
- [x] Code analysis - No errors!

---

## 🧪 Testing Guide

### Persiapan Testing:

#### 1. Deploy Firestore Rules
```
https://console.firebase.google.com/project/mata-angin-e1f8d/firestore/rules
```
Copy isi `firestore.rules`, paste, klik **Publish**.

#### 2. Buat User di Firestore

**Collection:** `users`

**Admin User:**
```
Document ID: [Firebase Auth UID]
Fields:
  - name: "Admin User"
  - email: "admin@example.com"
  - role: "admin"
```

**Operator User:**
```
Document ID: [Firebase Auth UID]
Fields:
  - name: "Operator User"
  - email: "operator@example.com"
  - role: "operator"
```

**PENTING:** Document ID = Firebase Auth UID user tersebut!

---

### Test Scenario 1: Login sebagai ADMIN

#### Run App:
```bash
flutter run -d chrome
```

#### Test Cases:

**✅ Test 1: Tombol Edit/Delete Muncul**
1. Login dengan akun admin
2. Pergi ke Pemasukan
3. **Expected:** Tombol edit (✏️) dan delete (🗑️) **MUNCUL**
4. Pergi ke Pengeluaran
5. **Expected:** Tombol edit dan delete **MUNCUL**
6. Pergi ke Utang Piutang
7. **Expected:** Tombol edit dan delete **MUNCUL**

**✅ Test 2: Bisa Hapus Data**
1. Di Pemasukan, klik tombol delete
2. **Expected:** Muncul dialog konfirmasi
3. Klik "Hapus"
4. **Expected:** Data terhapus, tidak ada error

**✅ Test 3: Bisa Edit Data**
1. Di Pengeluaran, klik tombol edit
2. **Expected:** Muncul form edit
3. Ubah data, klik "Simpan"
4. **Expected:** Data terupdate, tidak ada error

**✅ Test 4: Bisa Export PDF**
1. Pergi ke Laporan
2. **Expected:** Tombol PDF (📄) **MUNCUL** di AppBar
3. Klik tombol PDF
4. **Expected:** PDF terdownload

---

### Test Scenario 2: Login sebagai OPERATOR

#### Logout dan Login Ulang:
1. Logout dari akun admin
2. Login dengan akun operator

#### Test Cases:

**✅ Test 5: Tombol Edit/Delete TIDAK Muncul**
1. Pergi ke Pemasukan
2. **Expected:** Tombol edit dan delete **TIDAK MUNCUL**
3. **Expected:** Tidak ada pesan error, UI bersih
4. Pergi ke Pengeluaran
5. **Expected:** Tombol edit dan delete **TIDAK MUNCUL**
6. Pergi ke Utang Piutang
7. **Expected:** Tombol edit dan delete **TIDAK MUNCUL**

**✅ Test 6: Bisa Tambah Data**
1. Di Pemasukan, klik tombol "+" (tambah)
2. **Expected:** Form tambah muncul
3. Isi data, klik "Simpan"
4. **Expected:** Data tersimpan, tidak ada error

**✅ Test 7: Bisa Lihat Data**
1. Di Dashboard
2. **Expected:** Bisa lihat semua data
3. Di Laporan
4. **Expected:** Bisa lihat laporan hari ini

**✅ Test 8: Export PDF TIDAK Muncul**
1. Pergi ke Laporan
2. **Expected:** Tombol PDF **TIDAK MUNCUL** di AppBar
3. **Expected:** Tidak ada pesan error

**✅ Test 9: Tidak Bisa Hapus via Firestore**
1. Buka Browser Console (F12)
2. Coba hapus data manual via Firestore API
3. **Expected:** Error "permission-denied"

---

## 📊 Expected Results Summary

### Admin:
| Fitur | Status |
|-------|--------|
| Lihat data | ✅ Bisa |
| Tambah data | ✅ Bisa |
| Edit data | ✅ Bisa |
| Hapus data | ✅ Bisa |
| Export PDF | ✅ Bisa |
| Tombol edit/delete | ✅ Muncul |

### Operator:
| Fitur | Status |
|-------|--------|
| Lihat data | ✅ Bisa |
| Tambah data | ✅ Bisa |
| Edit data | ❌ Tidak bisa (tombol tidak muncul) |
| Hapus data | ❌ Tidak bisa (tombol tidak muncul) |
| Export PDF | ❌ Tidak bisa (tombol tidak muncul) |
| Tombol edit/delete | ❌ Tidak muncul |

---

## 🐛 Troubleshooting

### Tombol masih muncul untuk operator:
**Solusi:**
1. Cek role di Firestore: `users/[uid]/role` harus "operator"
2. Logout dan login ulang
3. Clear browser cache (Ctrl+Shift+Delete)
4. Restart app

### Error "permission-denied" saat tambah data:
**Solusi:**
1. Cek Firestore Rules sudah di-deploy
2. Cek user document ada di collection `users`
3. Cek field `role` ada di user document
4. Tunggu 1-2 menit untuk propagation

### Tombol tidak muncul untuk admin:
**Solusi:**
1. Cek role di Firestore: `users/[uid]/role` harus "admin"
2. Logout dan login ulang
3. Cek `TokenManager.getUserRole()` return "admin"

### Error saat compile:
**Solusi:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ Final Checklist

- [ ] Firestore Rules deployed
- [ ] Admin user created di Firestore
- [ ] Operator user created di Firestore
- [ ] Test login sebagai admin - tombol muncul
- [ ] Test hapus data sebagai admin - berhasil
- [ ] Test edit data sebagai admin - berhasil
- [ ] Test export PDF sebagai admin - berhasil
- [ ] Test login sebagai operator - tombol tidak muncul
- [ ] Test tambah data sebagai operator - berhasil
- [ ] Test tidak ada error message untuk operator
- [ ] Verifikasi UI bersih tanpa pesan error

---

## 🎉 Selesai!

Jika semua test case passed, sistem role-based access sudah berfungsi dengan sempurna!

**Operator tidak akan melihat:**
- ❌ Tombol edit
- ❌ Tombol delete
- ❌ Tombol export PDF
- ❌ Pesan error "Anda tidak punya akses"

**UI akan bersih dan profesional untuk operator!**
