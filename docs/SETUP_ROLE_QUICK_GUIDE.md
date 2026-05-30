# ⚡ Quick Guide: Setup Role-Based Access

## 🎯 Ringkasan

Sistem sudah siap dengan 2 role:
- **Admin**: Akses penuh (bisa edit/hapus)
- **Operator**: Hanya bisa tambah data (tidak bisa edit/hapus)

---

## ✅ Yang Sudah Siap:

1. ✅ **Firestore Rules** - Sudah support role-based access
2. ✅ **User Model** - Sudah ada field `role`
3. ✅ **Auth Service** - Sudah fetch role dari Firestore
4. ✅ **Permission Helper** - Sudah ada helper untuk cek permission
5. ✅ **Admin Only Widget** - Sudah ada widget untuk hide/show tombol

---

## 🚀 Langkah Setup (3 Langkah):

### 1. Deploy Firestore Rules

**Opsi A: Via Firebase Console (Paling Mudah)**

1. Buka: https://console.firebase.google.com/project/mata-angin-e1f8d/firestore/rules
2. Copy isi file `firestore.rules` dari project
3. Paste ke Firebase Console
4. Klik **Publish**

**Opsi B: Via Firebase CLI**

```bash
firebase deploy --only firestore:rules
```

### 2. Buat User di Firestore dengan Role

Buka: https://console.firebase.google.com/project/mata-angin-e1f8d/firestore/data

**Buat Collection `users`** (jika belum ada)

**Tambahkan Document untuk setiap user:**

**Admin User:**
```
Document ID: [Firebase Auth UID user]

Fields:
- name: "Admin User" (string)
- email: "admin@example.com" (string)
- role: "admin" (string)
- created_by: [Firebase Auth UID] (string)
```

**Operator User:**
```
Document ID: [Firebase Auth UID user]

Fields:
- name: "Operator User" (string)
- email: "operator@example.com" (string)
- role: "operator" (string)
- created_by: [Firebase Auth UID] (string)
```

**PENTING:** Document ID harus sama dengan Firebase Auth UID user tersebut!

### 3. Update UI untuk Hide Tombol Edit/Delete

Import widget di setiap view:

```dart
import '../core/widgets/admin_only_widget.dart';
```

Wrap tombol edit/delete dengan `AdminOnlyWidget`:

**Contoh di Pemasukan View:**

```dart
// SEBELUM
IconButton(
  icon: const Icon(Icons.delete_outline),
  onPressed: () => _confirmDelete(context, item.id!),
)

// SESUDAH
AdminOnlyWidget(
  child: IconButton(
    icon: const Icon(Icons.delete_outline),
    onPressed: () => _confirmDelete(context, item.id!),
  ),
)
```

**File yang perlu diupdate:**
- `lib/view/pemasukan_view.dart` - Wrap tombol edit & delete
- `lib/view/pengeluaran_view.dart` - Wrap tombol edit & delete
- `lib/view/utang_piutang_view.dart` - Wrap tombol edit & delete
- `lib/view/laporan_view.dart` - Wrap tombol export PDF

---

## 🧪 Testing

### Test sebagai Admin:
1. Login dengan akun admin
2. ✅ Tombol edit/delete **MUNCUL**
3. ✅ Bisa hapus data
4. ✅ Bisa edit data
5. ✅ Bisa export PDF

### Test sebagai Operator:
1. Login dengan akun operator
2. ✅ Tombol edit/delete **TIDAK MUNCUL**
3. ✅ Bisa tambah pemasukan/pengeluaran
4. ❌ Tidak bisa hapus data (tombol tidak ada)
5. ❌ Tidak bisa edit data (tombol tidak ada)
6. ❌ Tidak bisa export PDF (tombol tidak ada)

---

## 📋 Cara Cepat Cek Role User

Di Firebase Console > Authentication, lihat UID user.

Lalu cek di Firestore > users > [UID tersebut] > field `role`

---

## 🔧 Cara Ubah Role User

1. Buka Firestore Console
2. Pergi ke collection `users`
3. Klik document user yang mau diubah
4. Edit field `role`:
   - `admin` - untuk akses penuh
   - `operator` - untuk akses terbatas
5. Save

User harus **logout dan login lagi** agar role baru ter-apply.

---

## ⚠️ Catatan Penting:

1. **Operator tidak akan lihat error message** saat mencoba hapus/edit
   - Tombol edit/delete tidak akan muncul sama sekali
   - Tidak ada alert "Anda tidak punya akses"
   - UI bersih tanpa pesan error

2. **Firestore Rules sudah enforce permission**
   - Meskipun ada bug di UI, Firestore akan block request dari operator
   - Keamanan dijaga di level database

3. **Role disimpan di local storage**
   - Setelah login, role disimpan di device
   - Logout akan clear role
   - Login lagi akan fetch role terbaru dari Firestore

---

## 📚 Dokumentasi Lengkap:

- `IMPLEMENT_ROLE_BASED_ACCESS.md` - Panduan implementasi detail
- `firestore.rules` - Firestore security rules
- `lib/core/utils/permission_helper.dart` - Helper untuk cek permission
- `lib/core/widgets/admin_only_widget.dart` - Widget untuk hide/show

---

## ✅ Checklist:

- [ ] Deploy Firestore Rules
- [ ] Buat user di Firestore dengan role
- [ ] Update UI (wrap tombol dengan AdminOnlyWidget)
- [ ] Test sebagai admin
- [ ] Test sebagai operator
- [ ] Verifikasi operator tidak lihat tombol edit/delete
- [ ] Verifikasi operator tidak bisa hapus via Firestore

---

**Selesai! 🎉**

Sistem role-based access sudah siap digunakan!
