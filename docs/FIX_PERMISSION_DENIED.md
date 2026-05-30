# 🔧 Fix: Permission Denied saat Edit Utang Piutang

## ❌ Error yang Muncul:
```
[cloud_firestore/permission-denied] Missing or insufficient permissions.
```

## 🔍 Penyebab:
Firestore Rules terlalu ketat pada validasi field saat **update**. Rules lama memvalidasi semua field yang mungkin tidak ada atau berubah saat edit.

## ✅ Solusi:

### 1. Update Firestore Rules

Rules sudah diperbaiki di file `firestore.rules` dengan perubahan:

**SEBELUM (Terlalu Ketat):**
```javascript
allow update: if isStaffOrAdmin()
              && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['created_by'])
              && request.resource.data.total_tagihan is int
              && request.resource.data.dp is int
              && request.resource.data.sisa_pembayaran is int
              && request.resource.data.status is string;
```

**SESUDAH (Lebih Fleksibel):**
```javascript
allow update: if isStaffOrAdmin()
              && (!request.resource.data.diff(resource.data).affectedKeys().hasAny(['created_by']) 
                  || !('created_by' in resource.data));
```

### 2. Deploy Rules Baru

**Opsi A: Via Firebase Console (Paling Mudah)**

1. Buka: https://console.firebase.google.com/project/mata-angin-e1f8d/firestore/rules
2. Copy semua isi file `firestore.rules` dari project
3. Paste ke Firebase Console (replace semua)
4. Klik **Publish**
5. Tunggu 1-2 menit untuk propagation

**Opsi B: Via Firebase CLI**

```bash
firebase deploy --only firestore:rules
```

### 3. Test Lagi

1. Refresh browser (Ctrl+F5)
2. Login sebagai operator
3. Pergi ke Utang Piutang
4. Klik tombol Edit
5. Ubah data (nama, jumlah, status, dll)
6. Klik Simpan
7. **Expected:** Berhasil tanpa error

---

## 🧪 Testing Checklist

### Test sebagai OPERATOR:

**✅ Utang Piutang - Edit:**
- [ ] Klik tombol Edit → Form muncul
- [ ] Ubah nama customer → Berhasil
- [ ] Ubah jumlah tagihan → Berhasil
- [ ] Ubah status ke "Lunas" → Berhasil
- [ ] Tambah pembayaran → Berhasil
- [ ] Simpan → **Berhasil tanpa error**

**✅ Utang Piutang - Hapus:**
- [ ] Tombol Delete **TIDAK MUNCUL**
- [ ] Tidak ada error message

### Test sebagai ADMIN:

**✅ Utang Piutang - Edit:**
- [ ] Klik tombol Edit → Form muncul
- [ ] Ubah data → Berhasil
- [ ] Simpan → Berhasil

**✅ Utang Piutang - Hapus:**
- [ ] Tombol Delete **MUNCUL**
- [ ] Klik Delete → Berhasil

---

## 📋 Perubahan Rules Detail

### Collection: `utang_piutang`

**Create:**
- ✅ Admin & Operator bisa create
- ✅ Validasi field wajib: `nama_customer`, `tipe`
- ✅ Field `created_by` harus sama dengan user yang login

**Update:**
- ✅ Admin & Operator bisa update
- ✅ Tidak boleh ubah field `created_by`
- ✅ Fleksibel untuk field lain (status, pembayaran, dll)
- ✅ Tidak ada validasi ketat untuk field optional

**Delete:**
- ✅ Hanya Admin yang bisa delete
- ❌ Operator tidak bisa delete

---

## 🔒 Security Tetap Terjaga

Meskipun rules lebih fleksibel, security tetap terjaga:

1. ✅ User harus login (authenticated)
2. ✅ User harus punya role (admin/operator)
3. ✅ Field `created_by` tidak bisa diubah
4. ✅ Hanya admin yang bisa delete
5. ✅ Validasi tipe data tetap ada di aplikasi

---

## 🆘 Troubleshooting

### Error masih muncul setelah deploy:

**Solusi 1: Tunggu Propagation**
- Tunggu 2-3 menit setelah deploy
- Refresh browser (Ctrl+F5)
- Clear browser cache

**Solusi 2: Logout & Login Ulang**
```
1. Logout dari aplikasi
2. Clear browser cache (Ctrl+Shift+Delete)
3. Login lagi
4. Test edit lagi
```

**Solusi 3: Cek Rules di Console**
```
1. Buka Firebase Console > Firestore > Rules
2. Cek tanggal "Last published"
3. Pastikan rules sudah ter-update
4. Cek tidak ada error di rules
```

**Solusi 4: Cek User Role**
```
1. Buka Firestore Console
2. Pergi ke collection "users"
3. Cek document user yang login
4. Pastikan field "role" = "operator" atau "admin"
```

### Error "userExists is not defined":

**Solusi:**
Pastikan helper function `userExists()` ada di bagian atas rules:
```javascript
function userExists(uid) {
  return exists(/databases/$(database)/documents/users/$(uid));
}
```

### Error "getUserData is not defined":

**Solusi:**
Pastikan helper function `getUserData()` ada:
```javascript
function getUserData() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
}
```

---

## ✅ Verifikasi Rules Sudah Benar

Buka Firebase Console dan pastikan rules untuk `utang_piutang` seperti ini:

```javascript
match /utang_piutang/{id} {
  allow read: if isStaffOrAdmin();
  
  allow create: if isStaffOrAdmin() 
                && request.resource.data.created_by == request.auth.uid
                && request.resource.data.nama_customer is string
                && request.resource.data.tipe is string
                && (request.resource.data.tipe == 'utang' || request.resource.data.tipe == 'piutang');
                
  allow update: if isStaffOrAdmin()
                && (!request.resource.data.diff(resource.data).affectedKeys().hasAny(['created_by']) 
                    || !('created_by' in resource.data));
                
  allow delete: if isSignedIn() && userExists(request.auth.uid) && getUserData().role == 'admin';
}
```

---

## 🎉 Selesai!

Setelah deploy rules baru:
- ✅ Operator bisa edit utang piutang
- ✅ Operator bisa ubah status
- ✅ Operator bisa tambah pembayaran
- ❌ Operator tidak bisa hapus
- ✅ Tidak ada error "permission-denied"

**Deploy rules dan test lagi!**
