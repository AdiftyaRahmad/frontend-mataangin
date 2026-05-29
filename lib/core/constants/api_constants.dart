class ApiConstants {
  static const String baseUrl =
      'https://backend-mata-angin-finance-production.up.railway.app/api';

  // Auth
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout = '$baseUrl/logout';

  // Dashboard
  static const String dashboard = '$baseUrl/dashboard';

  // Pemasukan (Income)
  static const String pemasukan = '$baseUrl/pemasukan';
  static String pemasukanById(int id) => '$baseUrl/pemasukan/$id';

  // Pengeluaran (Expense)
  static const String pengeluaran = '$baseUrl/pengeluaran';
  static String pengeluaranById(int id) => '$baseUrl/pengeluaran/$id';

  // Laporan (Reports)
  static const String laporanHarian = '$baseUrl/laporan/harian';
  static const String laporanBulanan = '$baseUrl/laporan/bulanan';
  static const String laporanExportPdf = '$baseUrl/laporan/export-pdf';

  // Utang Piutang (Debts/Receivables)
  static const String utangPiutang = '$baseUrl/utang-piutang';
  static String utangPiutangById(int id) => '$baseUrl/utang-piutang/$id';
}
