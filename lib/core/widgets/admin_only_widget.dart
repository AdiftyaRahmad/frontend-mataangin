import 'package:flutter/material.dart';
import '../utils/permission_helper.dart';

/// Widget yang hanya muncul untuk Admin
/// Untuk Operator, widget ini tidak akan ditampilkan (tidak ada pesan error)
class AdminOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback; // Widget alternatif jika bukan admin (opsional)

  const AdminOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PermissionHelper.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Tidak tampilkan apa-apa saat loading
        }

        final isAdmin = snapshot.data ?? false;
        
        if (isAdmin) {
          return child; // Tampilkan widget untuk admin
        } else {
          return fallback ?? const SizedBox.shrink(); // Tidak tampilkan apa-apa untuk operator
        }
      },
    );
  }
}

/// Widget khusus untuk tombol DELETE (hanya admin yang bisa hapus)
class DeleteOnlyWidget extends StatelessWidget {
  final Widget child;

  const DeleteOnlyWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PermissionHelper.canDelete(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final canDelete = snapshot.data ?? false;
        
        if (!canDelete) {
          return const SizedBox.shrink(); // Tidak tampilkan tombol delete untuk operator
        }

        return child;
      },
    );
  }
}

/// Widget untuk tombol yang butuh permission
class PermissionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Future<bool> Function() checkPermission;

  const PermissionButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.checkPermission,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final hasPermission = snapshot.data ?? false;
        
        if (!hasPermission) {
          return const SizedBox.shrink(); // Tidak tampilkan tombol
        }

        return GestureDetector(
          onTap: onPressed,
          child: child,
        );
      },
    );
  }
}
