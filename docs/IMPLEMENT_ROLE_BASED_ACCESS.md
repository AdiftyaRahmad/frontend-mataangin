# 🔐 Implementasi Role-Based Access Control (RBAC)

## 📋 Overview

Sistem dengan 2 role:
1. **Admin** - Akses penuh
2. **Operator** - Akses terbatas (input data saja)

---

## ✅ Yang Sudah Dibuat:

### 1. Model & Service
- [x] `UserModel` - Ditambahkan field `role`
- [x] `AuthService` - Fetch role dari Firestore
- [x] `TokenManager` - Save/get role dari local storage
- [x] `PermissionHelper` - Helper untuk cek permission
- [x] `AdminOnlyWidget` - Widget untuk hide/show berdasarkan role

### 2. Permission Rules

**Admin bisa:**
- ✅ Lihat dashboard
- ✅ Tambah pemasukan/pengeluaran
- ✅ Edit data lama
- ✅ Hapus data
- ✅ Lihat semua laporan
- ✅ Export PDF
- ✅ Kelola user

**Operator bisa:**
- ✅ Tambah pemasukan/pengeluaran
- ✅ Lihat data hari ini
- ❌ Hapus data
- ❌ Edit data lama
- ❌ Lihat laporan bulanan (opsional)
- ❌ Kelola user

---

## 🔧 Cara Implementasi di UI:

### Contoh 1: Hide Tombol Delete untuk Operator

**SEBELUM:**
```dart
IconButton(
  icon: const Icon(Icons.delete_outline),
  onPressed: () => _confirmDelete(context, item.id!),
)
```

**SESUDAH:**
```dart
import '../core/widgets/admin_only_widget.dart';

AdminOnlyWidget(
  child: IconButton(
    icon: const Icon(Icons.delete_outline),
    onPressed: () => _confirmDelete(context, item.id!),
  ),
)
```

### Contoh 2: Hide Tombol Edit untuk Operator

```dart
AdminOnlyWidget(
  child: IconButton(
    icon: const Icon(Icons.edit_outlined),
    onPressed: () => _showEditDialog(context, item),
  ),
)
```

### Contoh 3: Hide Export PDF Button

```dart
AdminOnlyWidget(
  child: IconButton(
    icon: const Icon(Icons.picture_as_pdf_outlined),
    tooltip: 'Export PDF',
    onPressed: () async {
      final success = await context.read<LaporanViewModel>().exportPdf();
      // ...
    },
  ),
)
```

### Contoh 4: Conditional Logic

```dart
import '../core/utils/permission_helper.dart';

// Di dalam method
final canDelete = await PermissionHelper.canDelete();

if (canDelete) {
  // Tampilkan tombol delete
  IconButton(
    icon: const Icon(Icons.delete_outline),
    onPressed: () => _confirmDelete(context, item.id!),
  )
} else {
  // Tidak tampilkan apa-apa (atau tampilkan widget lain)
  const SizedBox.shrink()
}
```

---

## 📝 File yang Perlu Diupdate:

### 1. Pemasukan View (`lib/view/pemasukan_view.dart`)

Wrap tombol edit dan delete dengan `AdminOnlyWidget`:

```dart
// Di dalam _PemasukanCard, bagian action buttons
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    AdminOnlyWidget(
      child: InkWell(
        onTap: onEdit,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.edit_outlined, size: 16, color: Color(0xFF3B82F6)),
        ),
      ),
    ),
    const SizedBox(width: 4),
    AdminOnlyWidget(
      child: InkWell(
        onTap: onDelete,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
        ),
      ),
    ),
  ],
)
```

### 2. Pengeluaran View (`lib/view/pengeluaran_view.dart`)

```dart
// Di dalam _PengeluaranCard
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    AdminOnlyWidget(
      child: IconButton(
        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3B82F6)),
        onPressed: onEdit,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(4),
      ),
    ),
    AdminOnlyWidget(
      child: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
        onPressed: onDelete,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(4),
      ),
    ),
  ],
)
```

### 3. Utang Piutang View (`lib/view/utang_piutang_view.dart`)

```dart
// Di dalam _buildUtangPiutangCard
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    AdminOnlyWidget(
      child: IconButton(
        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3B82F6)),
        onPressed: () => _showFormDialog(context, vm, item: item),
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(4),
      ),
    ),
    AdminOnlyWidget(
      child: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
        onPressed: () => _confirmDelete(context, vm, item.id!),
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(4),
      ),
    ),
  ],
)
```

### 4. Laporan View (`lib/view/laporan_view.dart`)

```dart
// Di AppBar actions
actions: [
  AdminOnlyWidget(
    child: IconButton(
      icon: vm.isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Icon(Icons.picture_as_pdf_outlined, color: Colors.white70),
      tooltip: 'Export PDF',
      onPressed: vm.isExporting ? null : () async {
        // ... export logic
      },
    ),
  ),
],
```

---

## 🔥 Setup Firestore untuk Role

### 1. Buat User di Firestore

Di Firebase Console > Firestore Database, buat collection `users`:

**Admin User:**
```json
{
  "id": "user_firebase_uid",
  "name": "Admin User",
  "email": "admin@example.com",
  "role": "admin"
}
```

**Operator User:**
```json
{
  "id": "user_firebase_uid",
  "name": "Operator User",
  "email": "operator@example.com",
  "role": "operator"
}
```

### 2. Update Firestore Rules

File `firestore.rules` sudah diupdate dengan role-based access.

Deploy rules:
```bash
firebase deploy --only firestore:rules
```

Atau copy-paste manual ke Firebase Console:
https://console.firebase.google.com/project/mata-angin-e1f8d/firestore/rules

---

## 🧪 Testing

### Test sebagai Admin:
1. Login dengan akun admin
2. Cek tombol edit/delete **MUNCUL**
3. Coba hapus data → **BERHASIL**
4. Coba edit data → **BERHASIL**
5. Coba export PDF → **BERHASIL**

### Test sebagai Operator:
1. Login dengan akun operator
2. Cek tombol edit/delete **TIDAK MUNCUL**
3. Coba tambah pemasukan → **BERHASIL**
4. Coba tambah pengeluaran → **BERHASIL**
5. Lihat data hari ini → **BERHASIL**
6. Export PDF button **TIDAK MUNCUL**

---

## 📱 Display Role di UI (Opsional)

Tampilkan role user di dashboard atau profile:

```dart
import '../core/utils/permission_helper.dart';

FutureBuilder<String>(
  future: PermissionHelper.getRoleName(),
  builder: (context, snapshot) {
    final role = snapshot.data ?? '';
    return Text(
      'Role: $role',
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  },
)
```

---

## ✅ Checklist Implementasi:

- [x] Update UserModel dengan field role
- [x] Update AuthService untuk fetch role
- [x] Update TokenManager untuk save/get role
- [x] Buat PermissionHelper
- [x] Buat AdminOnlyWidget
- [ ] Update Pemasukan View (wrap tombol dengan AdminOnlyWidget)
- [ ] Update Pengeluaran View (wrap tombol dengan AdminOnlyWidget)
- [ ] Update Utang Piutang View (wrap tombol dengan AdminOnlyWidget)
- [ ] Update Laporan View (hide export PDF untuk operator)
- [ ] Buat user di Firestore dengan role
- [ ] Test sebagai admin
- [ ] Test sebagai operator

---

## 🆘 Troubleshooting

**Tombol masih muncul untuk operator:**
- Cek role di Firestore sudah benar
- Cek TokenManager.getUserRole() return value yang benar
- Clear app data dan login ulang

**Error saat login:**
- Pastikan user document ada di Firestore collection `users`
- Pastikan field `role` ada di document

**Permission denied di Firestore:**
- Deploy firestore.rules yang baru
- Tunggu 1-2 menit untuk propagation
