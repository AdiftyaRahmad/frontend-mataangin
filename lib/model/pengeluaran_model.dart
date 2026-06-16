class PengeluaranModel {
  final String? id;
  final String namaBarang;
  final double nominal;
  final double cash;
  final double transfer;
  final double qris;
  final String? keterangan;
  final String tanggal;
  final String? kategori;
  final int shift;
  final dynamic createdBy;
  final String? createdAt;
  final String? updatedAt;

  PengeluaranModel({
    this.id,
    required this.namaBarang,
    required this.nominal,
    this.cash = 0.0,
    this.transfer = 0.0,
    this.qris = 0.0,
    this.keterangan,
    required this.tanggal,
    this.kategori,
    this.shift = 1,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory PengeluaranModel.fromJson(Map<String, dynamic> json) {
    final double cash = double.tryParse(json['cash']?.toString() ?? '0') ?? 0.0;
    final double transfer = double.tryParse(json['transfer']?.toString() ?? '0') ?? 0.0;
    final double qris = double.tryParse(json['qris']?.toString() ?? '0') ?? 0.0;
    final double parsedNominal = double.tryParse(json['nominal']?.toString() ?? json['jumlah']?.toString() ?? '0') ?? 0.0;

    final double finalCash = (cash == 0 && transfer == 0 && qris == 0 && parsedNominal > 0) ? parsedNominal : cash;
    final double finalNominal = parsedNominal > 0 ? parsedNominal : (finalCash + transfer + qris);

    return PengeluaranModel(
      id: json['id']?.toString(),
      namaBarang: json['nama_barang'] ?? json['namaBarang'] ?? json['judul'] ?? json['nama'] ?? '',
      nominal: finalNominal,
      cash: finalCash,
      transfer: transfer,
      qris: qris,
      keterangan: json['keterangan'],
      tanggal: json['tanggal'] ?? json['created_at'] ?? '',
      kategori: json['kategori']?.toString() ?? json['category']?.toString(),
      shift: int.tryParse(json['shift']?.toString() ?? '1') ?? 1,
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: json['created_at'] ?? json['createdAt'],
      updatedAt: json['updated_at'] ?? json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_barang': namaBarang,
        'nominal': nominal.toInt(),
        'cash': cash.toInt(),
        'transfer': transfer.toInt(),
        'qris': qris.toInt(),
        'keterangan': keterangan ?? '',
        'tanggal': tanggal,
        'kategori': kategori,
        'shift': shift,
      };

  PengeluaranModel copyWith({
    String? id,
    String? namaBarang,
    double? nominal,
    double? cash,
    double? transfer,
    double? qris,
    String? keterangan,
    String? tanggal,
    String? kategori,
    int? shift,
    dynamic createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return PengeluaranModel(
      id: id ?? this.id,
      namaBarang: namaBarang ?? this.namaBarang,
      nominal: nominal ?? this.nominal,
      cash: cash ?? this.cash,
      transfer: transfer ?? this.transfer,
      qris: qris ?? this.qris,
      keterangan: keterangan ?? this.keterangan,
      tanggal: tanggal ?? this.tanggal,
      kategori: kategori ?? this.kategori,
      shift: shift ?? this.shift,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

