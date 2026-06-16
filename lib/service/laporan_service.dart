import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/laporan_model.dart';
import '../core/utils/pdf_generator.dart';

class LaporanService {
  final FirebaseFirestore _firestore;

  LaporanService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// GET daily report for tanggal (YYYY-MM-DD)
  Future<LaporanModel> getHarian(String tanggalStr) async {
    final date = DateTime.parse(tanggalStr);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final pemasukanSnap = await _firestore
        .collection('pemasukan')
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    final pengeluaranSnap = await _firestore
        .collection('pengeluaran')
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    final List<LaporanItem> transaksi = [];
    double totalPemasukan = 0.0;
    double totalPengeluaran = 0.0;

    for (var doc in pemasukanSnap.docs) {
      final data = doc.data();
      final amount = (data['total_pemasukan'] as num?)?.toDouble() ?? 0.0;
      totalPemasukan += amount;
      final cashVal = data['cash'] ?? 0;
      final tfVal = data['transfer_bca'] ?? 0;
      final qrisVal = data['qris_dana'] ?? 0;
      String ket = 'Cash: $cashVal, Transfer: $tfVal, QRIS: $qrisVal';
      if (data['setoran_aktual'] != null) {
        ket += ', Setoran: ${data['setoran_aktual']}, Selisih: ${data['selisih'] ?? 0}';
      }
      final shiftVal = data['shift'] ?? 1;
      transaksi.add(LaporanItem(
        judul: 'Pemasukan - ${data['hari'] ?? ''} (Shift $shiftVal)',
        jumlah: amount,
        jenis: 'pemasukan',
        tanggal: tanggalStr,
        keterangan: ket,
      ));
    }

    for (var doc in pengeluaranSnap.docs) {
      final data = doc.data();
      final amount = (data['nominal'] as num?)?.toDouble() ?? 0.0;
      totalPengeluaran += amount;
      final kat = data['kategori'] ?? 'Lainnya';
      final ket = data['keterangan'] ?? '';
      final desc = ket.toString().isNotEmpty ? '[$kat] $ket' : '[$kat]';
      final pShiftVal = data['shift'] ?? 1;
      transaksi.add(LaporanItem(
        judul: '${data['nama_barang'] ?? ''} (Shift $pShiftVal)',
        jumlah: amount,
        jenis: 'pengeluaran',
        tanggal: tanggalStr,
        keterangan: desc,
      ));
    }

    return LaporanModel(
      totalPemasukan: totalPemasukan,
      totalPengeluaran: totalPengeluaran,
      saldo: totalPemasukan - totalPengeluaran,
      transaksi: transaksi,
    );
  }

  /// GET monthly report for bulan (MM) and tahun (YYYY)
  Future<LaporanModel> getBulanan(String bulan, String tahun) async {
    final m = int.parse(bulan);
    final y = int.parse(tahun);
    final startOfMonth = DateTime(y, m, 1);
    final endOfMonth = DateTime(y, m + 1, 1).subtract(const Duration(milliseconds: 1));

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

    final List<LaporanItem> transaksi = [];
    double totalPemasukan = 0.0;
    double totalPengeluaran = 0.0;

    for (var doc in pemasukanSnap.docs) {
      final data = doc.data();
      final amount = (data['total_pemasukan'] as num?)?.toDouble() ?? 0.0;
      totalPemasukan += amount;
      final dateTimestamp = data['tanggal'] as Timestamp?;
      final dateStr = dateTimestamp != null
          ? dateTimestamp.toDate().toIso8601String().split('T')[0]
          : '';

      final cashVal = data['cash'] ?? 0;
      final tfVal = data['transfer_bca'] ?? 0;
      final qrisVal = data['qris_dana'] ?? 0;
      String ket = 'Cash: $cashVal, Transfer: $tfVal, QRIS: $qrisVal';
      if (data['setoran_aktual'] != null) {
        ket += ', Setoran: ${data['setoran_aktual']}, Selisih: ${data['selisih'] ?? 0}';
      }

      final shiftVal = data['shift'] ?? 1;
      transaksi.add(LaporanItem(
        judul: 'Pemasukan - ${data['hari'] ?? ''} (Shift $shiftVal)',
        jumlah: amount,
        jenis: 'pemasukan',
        tanggal: dateStr,
        keterangan: ket,
      ));
    }

    for (var doc in pengeluaranSnap.docs) {
      final data = doc.data();
      final amount = (data['nominal'] as num?)?.toDouble() ?? 0.0;
      totalPengeluaran += amount;
      final dateTimestamp = data['tanggal'] as Timestamp?;
      final dateStr = dateTimestamp != null
          ? dateTimestamp.toDate().toIso8601String().split('T')[0]
          : '';

      final kat = data['kategori'] ?? 'Lainnya';
      final ket = data['keterangan'] ?? '';
      final desc = ket.toString().isNotEmpty ? '[$kat] $ket' : '[$kat]';
      final pShiftVal = data['shift'] ?? 1;
      transaksi.add(LaporanItem(
        judul: '${data['nama_barang'] ?? ''} (Shift $pShiftVal)',
        jumlah: amount,
        jenis: 'pengeluaran',
        tanggal: dateStr,
        keterangan: desc,
      ));
    }

    return LaporanModel(
      totalPemasukan: totalPemasukan,
      totalPengeluaran: totalPengeluaran,
      saldo: totalPemasukan - totalPengeluaran,
      transaksi: transaksi,
    );
  }

  /// GET PDF bytes - Generate proper PDF from laporan data
  Future<List<int>> exportPdfBytes(LaporanModel laporan, {String? periode}) async {
    return await PdfGenerator.generateLaporanPdf(laporan, periode: periode);
  }
}
