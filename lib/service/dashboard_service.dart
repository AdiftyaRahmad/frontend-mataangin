import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/dashboard_model.dart';

class DashboardService {
  final FirebaseFirestore _firestore;

  DashboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// GET dashboard data computed from Cloud Firestore collections
  Future<DashboardModel> getDashboard() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));

    final pemasukanSnap = await _firestore
        .collection('pemasukan')
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final pengeluaranSnap = await _firestore
        .collection('pengeluaran')
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();
    
    double totalPemasukan = 0.0;
    for (var doc in pemasukanSnap.docs) {
      totalPemasukan += (doc.data()['total_pemasukan'] as num?)?.toDouble() ?? 0.0;
    }
    
    double totalPengeluaran = 0.0;
    for (var doc in pengeluaranSnap.docs) {
      totalPengeluaran += (doc.data()['nominal'] as num?)?.toDouble() ?? 0.0;
    }
    
    return DashboardModel(
      totalPemasukan: totalPemasukan,
      totalPengeluaran: totalPengeluaran,
      saldo: totalPemasukan - totalPengeluaran,
      jumlahPemasukan: pemasukanSnap.docs.length,
      jumlahPengeluaran: pengeluaranSnap.docs.length,
    );
  }
}
