# 🔐 Role Permission System - Final Implementation

## 📋 Role & Permission Matrix

### 👨‍💼 ADMIN (Full Access)

| Fitur | Lihat | Tambah | Edit | Hapus | Kelola User | Export PDF |
|-------|-------|--------|------|-------|-------------|------------|
| Dashboard | ✅ | - | - | - | - | - |
| Pemasukan | ✅ | ✅ | ✅ | ✅ | - | - |
| Pengeluaran | ✅ | ✅ | ✅ | ✅ | - | - |
| Utang Piutang | ✅ | ✅ | ✅ | ✅ | - | - |
| Laporan | ✅ | - | - | - | - | ✅ |
| User Management | ✅ | ✅ | ✅ | ✅ | ✅ | - |
| Pengaturan | ✅ | - | ✅ | - | - | - |

**Admin bisa:**
- ✅ Lihat dashboard
- ✅ Tambah, edit, hapus pemasukan
- ✅ Tambah, edit, hapus pengeluaran
- ✅ Tambah, edit, hapus utang piutang
- ✅ Ubah status utang piutang (Lunas/Belum Lunas)
- ✅ Tambah pembayaran cicilan
- ✅ Lihat laporan
- ✅ Export PDF
- ✅ Kelola user
- ✅ Akses pengaturan

---

### 👤 OPERATOR (Limited Access)

| Fitur | Lihat | Tambah | Edit | Hapus | Kelola User | Export PDF |
|-------|-------|--------|------|-------|-------------|------------|
| Dashboard | ✅ | - | - | - | - | - |
| Pemasukan | ✅ | ✅ | ✅ | ❌ | - | - |
| Pengeluaran | ✅ | ✅ | ✅ | ❌ | - | - |
| Utang Piutang | ✅ | ✅ | ✅ | ❌ | - | - |
| Laporan | ✅ | - | - | - | - | ❌ |
| User Management | ❌ | ❌ | ❌ | ❌ | ❌ | - |
| Pengaturan | ❌ | - | ❌ | - | - | - |

**Operator bisa:**
- ✅ Lihat dashboard
- ✅ Tambah pemasukan
- ✅ Edit pemasukan
- ✅ Tambah pengeluaran
- ✅ Edit pengeluaran
- ✅ Tambah utang piutang
- ✅ Edit utang piutang
- ✅ Ubah status utang piutang (Lunas/Belum Lunas)
- ✅ Tambah pembayaran cicilan
- ✅ Lihat laporan

**Operator TIDAK bisa:**
- ❌ Hapus pemasukan
- ❌ Hapus pengeluaran
- ❌ Hapus utang piutang
- ❌ Export PDF
- ❌ Kelola user
- ❌ Akses pengaturan

---

## 🎯 Implementasi Detail

### 1. **Firestore Structure**

**Collection: `users`**
```json
{
  "id": "firebase_auth_uid",
  "name": "User Name",
  "email": "user@example.com",
  "role": "admin" // atau "operator"
}
```

### 2. **Permission Helper**

File: `lib/core/utils/permission_helper.dart`

**Methods:**
- `canDelete()` - Hanya admin
- `canEditPemasukan()` - Admin & Operator
- `canEditPengeluaran()` - Admin & Operator
- `canEditUtangPiutang()` - Admin & Operator
- `canChangeStatusLunas()` - Admin & Operator
- `canAddPembayaran()` - Admin & Operator
- `canManageUsers()` - Hanya admin
- `canAccessSettings()` - Hanya admin

### 3. **UI Widgets**

**DeleteOnlyWidget** - Hanya tampilkan untuk admin
```dart
DeleteOnlyWidget(
  child: IconButton(
    icon: const Icon(Icons.delete_outline),
    onPressed: () => _confirmDelete(context, item.id!),
  ),
)
```

**Tombol Edit** - Tampilkan untuk semua (admin & operator)
```dart
IconButton(
  icon: const Icon(Icons.edit_outlined),
  onPressed: () => _showEditDialog(context, item: item),
)
```

### 4. **Firestore Security Rules**

**Pemasukan, Pengeluaran, Utang Piutang:**
```javascript
allow read: if isStaffOrAdmin();
allow create: if isStaffOrAdmin();
allow update: if isStaffOrAdmin(); // Admin & Operator bisa edit
allow delete: if getUserData().role == 'admin'; // Hanya Admin
```

---

## 🚀 Setup & Deployment

### Step 1: Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

Atau manual via Firebase Console:
https://console.firebase.google.com/project/mata-angin-e1f8d/firestore/rules

### Step 2: Buat User dengan Role

**Admin User:**
```
Collection: users
Document ID: [Firebase Auth UID]
Fields:
  - name: "Admin User"
  - email: "admin@example.com"
  - role: "admin"
```

**Operator User:**
```
Collection: users
Document ID: [Firebase Auth UID]
Fields:
  - name: "Operator User"
  - email: "operator@example.com"
  - role: "operator"
```

### Step 3: Test Aplikasi

```bash
flutter run -d chrome
```

---

## 🧪 Testing Scenarios

### Test sebagai ADMIN:

**✅ Pemasukan:**
1. Tambah pemasukan → Berhasil
2. Edit pemasukan → Berhasil
3. Hapus pemasukan → Berhasil
4. Tombol delete **MUNCUL**

**✅ Pengeluaran:**
1. Tambah pengeluaran → Berhasil
2. Edit pengeluaran → Berhasil
3. Hapus pengeluaran → Berhasil
4. Tombol delete **MUNCUL**

**✅ Utang Piutang:**
1. Tambah utang → Berhasil
2. Edit utang → Berhasil
3. Ubah status ke "Lunas" → Berhasil
4. Tambah pembayaran → Berhasil
5. Hapus utang → Berhasil
6. Tombol delete **MUNCUL**

**✅ Laporan:**
1. Lihat laporan → Berhasil
2. Export PDF → Berhasil
3. Tombol PDF **MUNCUL**

---

### Test sebagai OPERATOR:

**✅ Pemasukan:**
1. Tambah pemasukan → Berhasil
2. Edit pemasukan → Berhasil
3. Tombol edit **MUNCUL**
4. Tombol delete **TIDAK MUNCUL**

**✅ Pengeluaran:**
1. Tambah pengeluaran → Berhasil
2. Edit pengeluaran → Berhasil
3. Tombol edit **MUNCUL**
4. Tombol delete **TIDAK MUNCUL**

**✅ Utang Piutang:**
1. Tambah utang → Berhasil
2. Edit utang → Berhasil
3. Ubah status ke "Lunas" → Berhasil
4. Tambah pembayaran → Berhasil
5. Tombol edit **MUNCUL**
6. Tombol delete **TIDAK MUNCUL**

**✅ Laporan:**
1. Lihat laporan → Berhasil
2. Tombol PDF **TIDAK MUNCUL**

**❌ Coba Hapus via Console:**
1. Buka Browser Console (F12)
2. Coba hapus data manual
3. **Expected:** Error "permission-denied"

---

## 📊 UI Behavior

### Untuk ADMIN:
```
[Dashboard] [Pemasukan] [Pengeluaran] [Utang Piutang] [Laporan]
                                                         [📄 PDF]

Pemasukan Item:
  [Nama] [Jumlah] [✏️ Edit] [🗑️ Delete]
```

### Untuk OPERATOR:
```
[Dashboard] [Pemasukan] [Pengeluaran] [Utang Piutang] [Laporan]

Pemasukan Item:
  [Nama] [Jumlah] [✏️ Edit]
  
(Tombol delete tidak muncul, tidak ada error message)
```

---

## 🔒 Security Layers

### Layer 1: UI (Frontend)
- Tombol delete disembunyikan untuk operator
- Menggunakan `DeleteOnlyWidget`
- Tidak ada error message, UI bersih

### Layer 2: Firestore Rules (Backend)
- Validasi role di database
- Operator tidak bisa delete meskipun bypass UI
- Admin bisa semua operasi

### Layer 3: Permission Helper
- Centralized permission logic
- Easy to maintain
- Consistent across app

---

## 📝 Code Examples

### Contoh 1: Pemasukan View

```dart
// Tombol Edit - Semua user bisa
IconButton(
  icon: const Icon(Icons.edit_outlined),
  onPressed: () => _showEditDialog(context, item: item),
)

// Tombol Delete - Hanya admin
DeleteOnlyWidget(
  child: IconButton(
    icon: const Icon(Icons.delete_outline),
    onPressed: () => _confirmDelete(context, item.id!),
  ),
)
```

### Contoh 2: Utang Piutang - Ubah Status

```dart
// Admin & Operator bisa ubah status
DropdownButton<String>(
  value: item.status,
  items: ['Belum Lunas', 'Lunas'].map((status) {
    return DropdownMenuItem(value: status, child: Text(status));
  }).toList(),
  onChanged: (newStatus) async {
    // Update status - Admin & Operator bisa
    await vm.updateStatus(item.id!, newStatus!);
  },
)
```

### Contoh 3: Check Permission

```dart
final canDelete = await PermissionHelper.canDelete();

if (canDelete) {
  // Tampilkan tombol delete
} else {
  // Tidak tampilkan apa-apa
}
```

---

## ✅ Checklist Final

- [x] UserModel dengan field role
- [x] AuthService fetch role dari Firestore
- [x] TokenManager save/get role
- [x] PermissionHelper dengan rules lengkap
- [x] DeleteOnlyWidget untuk tombol delete
- [x] Pemasukan View - Operator bisa edit, tidak bisa hapus
- [x] Pengeluaran View - Operator bisa edit, tidak bisa hapus
- [x] Utang Piutang View - Operator bisa edit & ubah status, tidak bisa hapus
- [x] Laporan View - Operator tidak bisa export PDF
- [x] Firestore Rules - Operator bisa update, tidak bisa delete
- [x] Code analysis - No errors

---

## 🎉 Selesai!

Sistem role permission sudah lengkap dengan:
- ✅ Admin: Full access
- ✅ Operator: Bisa tambah & edit, tidak bisa hapus
- ✅ UI bersih tanpa error message
- ✅ Security di frontend & backend
- ✅ Easy to maintain

**Deploy Firestore Rules dan test aplikasi!**
