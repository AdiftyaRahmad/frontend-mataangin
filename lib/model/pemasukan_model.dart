class PemasukanModel {
  final int? id;
  final String tanggal;
  final String hari;
  final double cash;
  final double transfer;
  final double qris;
  final double denda;
  final double kerusakan;
  final double dp;
  final double totalPemasukan;
  final dynamic createdBy;
  final String? createdAt;
  final String? updatedAt;

  PemasukanModel({
    this.id,
    required this.tanggal,
    required this.hari,
    required this.cash,
    required this.transfer,
    required this.qris,
    required this.denda,
    required this.kerusakan,
    required this.dp,
    required this.totalPemasukan,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory PemasukanModel.fromJson(Map<String, dynamic> json) {
    return PemasukanModel(
      id: json['id'],
      tanggal: json['tanggal'] ?? '',
      hari: json['hari'] ?? '',
      cash: double.tryParse(json['cash']?.toString() ?? '0') ?? 0.0,
      transfer: double.tryParse(json['transfer']?.toString() ?? '0') ?? 0.0,
      qris: double.tryParse(json['qris']?.toString() ?? '0') ?? 0.0,
      denda: double.tryParse(json['denda']?.toString() ?? '0') ?? 0.0,
      kerusakan: double.tryParse(json['kerusakan']?.toString() ?? '0') ?? 0.0,
      dp: double.tryParse(json['dp']?.toString() ?? '0') ?? 0.0,
      totalPemasukan: double.tryParse(json['total_pemasukan']?.toString() ?? json['totalPemasukan']?.toString() ?? '0') ?? 0.0,
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: json['created_at'] ?? json['createdAt'],
      updatedAt: json['updated_at'] ?? json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tanggal': tanggal,
        'hari': hari,
        'cash': cash,
        'transfer': transfer,
        'qris': qris,
        'denda': denda,
        'kerusakan': kerusakan,
        'dp': dp,
        'total_pemasukan': totalPemasukan,
      };

  PemasukanModel copyWith({
    int? id,
    String? tanggal,
    String? hari,
    double? cash,
    double? transfer,
    double? qris,
    double? denda,
    double? kerusakan,
    double? dp,
    double? totalPemasukan,
    dynamic createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return PemasukanModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      hari: hari ?? this.hari,
      cash: cash ?? this.cash,
      transfer: transfer ?? this.transfer,
      qris: qris ?? this.qris,
      denda: denda ?? this.denda,
      kerusakan: kerusakan ?? this.kerusakan,
      dp: dp ?? this.dp,
      totalPemasukan: totalPemasukan ?? this.totalPemasukan,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
