import 'token_manager.dart';

class PermissionHelper {
  // ========================================
  // ADMIN PERMISSIONS (Full Access)
  // ========================================
  
  /// Admin bisa hapus semua data
  static Future<bool> canDelete() async {
    return await TokenManager.isAdmin();
  }

  /// Admin bisa kelola user
  static Future<bool> canManageUsers() async {
    return await TokenManager.isAdmin();
  }

  /// Admin bisa akses pengaturan
  static Future<bool> canAccessSettings() async {
    return await TokenManager.isAdmin();
  }

  // ========================================
  // SHARED PERMISSIONS (Admin & Operator)
  // ========================================
  
  /// Admin dan Operator bisa lihat dashboard
  static Future<bool> canViewDashboard() async {
    return true; // Semua user yang login bisa lihat
  }

  /// Admin dan Operator bisa tambah pemasukan
  static Future<bool> canAddPemasukan() async {
    return true;
  }

  /// Admin dan Operator bisa edit pemasukan
  static Future<bool> canEditPemasukan() async {
    return true;
  }

  /// Admin dan Operator bisa tambah pengeluaran
  static Future<bool> canAddPengeluaran() async {
    return true;
  }

  /// Admin dan Operator bisa edit pengeluaran
  static Future<bool> canEditPengeluaran() async {
    return true;
  }

  /// Admin dan Operator bisa tambah utang piutang
  static Future<bool> canAddUtangPiutang() async {
    return true;
  }

  /// Admin dan Operator bisa edit utang piutang
  static Future<bool> canEditUtangPiutang() async {
    return true;
  }

  /// Admin dan Operator bisa ubah status lunas
  static Future<bool> canChangeStatusLunas() async {
    return true;
  }

  /// Admin dan Operator bisa tambah pembayaran cicilan
  static Future<bool> canAddPembayaran() async {
    return true;
  }

  /// Admin dan Operator bisa lihat laporan
  static Future<bool> canViewLaporan() async {
    return true;
  }

  // ========================================
  // OPERATOR RESTRICTIONS
  // ========================================
  
  /// Hanya Admin yang bisa hapus pemasukan
  static Future<bool> canDeletePemasukan() async {
    return await TokenManager.isAdmin();
  }

  /// Hanya Admin yang bisa hapus pengeluaran
  static Future<bool> canDeletePengeluaran() async {
    return await TokenManager.isAdmin();
  }

  /// Hanya Admin yang bisa hapus utang piutang
  static Future<bool> canDeleteUtangPiutang() async {
    return await TokenManager.isAdmin();
  }

  // ========================================
  // HELPER METHODS
  // ========================================
  
  /// Cek apakah user adalah admin
  static Future<bool> isAdmin() async {
    return await TokenManager.isAdmin();
  }

  /// Cek apakah user adalah operator
  static Future<bool> isOperator() async {
    return await TokenManager.isOperator();
  }

  /// Get role name untuk display
  static Future<String> getRoleName() async {
    final isAdminUser = await isAdmin();
    return isAdminUser ? 'Admin' : 'Operator';
  }
}
