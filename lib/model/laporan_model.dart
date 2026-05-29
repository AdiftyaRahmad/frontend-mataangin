class LaporanItem {
  final String judul;
  final double jumlah;
  final String jenis; // 'pemasukan' atau 'pengeluaran'
  final String tanggal;
  final String? keterangan;

  LaporanItem({
    required this.judul,
    required this.jumlah,
    required this.jenis,
    required this.tanggal,
    this.keterangan,
  });

  factory LaporanItem.fromJson(Map<String, dynamic> json) {
    return LaporanItem(
      judul: json['judul'] ?? json['nama'] ?? json['title'] ?? '',
      jumlah: double.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
      jenis: json['jenis'] ?? json['type'] ?? 'pemasukan',
      tanggal: json['tanggal'] ?? json['created_at'] ?? '',
      keterangan: json['keterangan'] ?? json['description'],
    );
  }
}

class LaporanModel {
  final double totalPemasukan;
  final double totalPengeluaran;
  final double saldo;
  final List<LaporanItem> transaksi;

  LaporanModel({
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.saldo,
    required this.transaksi,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final List listRaw = data['transaksi'] ?? data['data'] ?? [];
    
    final totalPem = double.tryParse(
            data['total_pemasukan']?.toString() ??
                data['pemasukan']?.toString() ??
                '0') ??
        0.0;
    final totalPeng = double.tryParse(
            data['total_pengeluaran']?.toString() ??
                data['pengeluaran']?.toString() ??
                '0') ??
        0.0;
    
    final calcSaldo = totalPem - totalPeng;
    final rawSaldo = double.tryParse(
        data['saldo']?.toString() ?? data['selisih']?.toString() ?? '');
    
    final saldoVal = (rawSaldo == null || (rawSaldo == 0.0 && calcSaldo != 0.0))
        ? calcSaldo
        : rawSaldo;

    return LaporanModel(
      totalPemasukan: totalPem,
      totalPengeluaran: totalPeng,
      saldo: saldoVal,
      transaksi: listRaw.map((e) => LaporanItem.fromJson(e)).toList(),
    );
  }

  factory LaporanModel.empty() => LaporanModel(
        totalPemasukan: 0,
        totalPengeluaran: 0,
        saldo: 0,
        transaksi: [],
      );
}
