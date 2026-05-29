class DashboardModel {
  final double totalPemasukan;
  final double totalPengeluaran;
  final double saldo;
  final int? jumlahPemasukan;
  final int? jumlahPengeluaran;

  DashboardModel({
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.saldo,
    this.jumlahPemasukan,
    this.jumlahPengeluaran,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    // Support multiple response structures from the backend
    final data = json['data'] ?? json;
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
        data['saldo']?.toString() ?? data['balance']?.toString() ?? '');
    
    final saldoVal = (rawSaldo == null || (rawSaldo == 0.0 && calcSaldo != 0.0))
        ? calcSaldo
        : rawSaldo;

    return DashboardModel(
      totalPemasukan: totalPem,
      totalPengeluaran: totalPeng,
      saldo: saldoVal,
      jumlahPemasukan: data['jumlah_pemasukan'],
      jumlahPengeluaran: data['jumlah_pengeluaran'],
    );
  }

  factory DashboardModel.empty() => DashboardModel(
        totalPemasukan: 0,
        totalPengeluaran: 0,
        saldo: 0,
      );
}
