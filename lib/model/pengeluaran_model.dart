class PengeluaranModel {
  final String? id;
  final String namaBarang;
  final double nominal;
  final String? keterangan;
  final String tanggal;
  final String? kategori;
  final dynamic createdBy;
  final String? createdAt;
  final String? updatedAt;

  PengeluaranModel({
    this.id,
    required this.namaBarang,
    required this.nominal,
    this.keterangan,
    required this.tanggal,
    this.kategori,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory PengeluaranModel.fromJson(Map<String, dynamic> json) {
    return PengeluaranModel(
      id: json['id']?.toString(),
      namaBarang: json['nama_barang'] ?? json['namaBarang'] ?? json['judul'] ?? json['nama'] ?? '',
      nominal: double.tryParse(json['nominal']?.toString() ?? json['jumlah']?.toString() ?? '0') ?? 0.0,
      keterangan: json['keterangan'],
      tanggal: json['tanggal'] ?? json['created_at'] ?? '',
      kategori: json['kategori']?.toString() ?? json['category']?.toString(),
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: json['created_at'] ?? json['createdAt'],
      updatedAt: json['updated_at'] ?? json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_barang': namaBarang,
        'nominal': nominal,
        'keterangan': keterangan,
        'tanggal': tanggal,
        'kategori': kategori,
      };

  PengeluaranModel copyWith({
    String? id,
    String? namaBarang,
    double? nominal,
    String? keterangan,
    String? tanggal,
    String? kategori,
    dynamic createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return PengeluaranModel(
      id: id ?? this.id,
      namaBarang: namaBarang ?? this.namaBarang,
      nominal: nominal ?? this.nominal,
      keterangan: keterangan ?? this.keterangan,
      tanggal: tanggal ?? this.tanggal,
      kategori: kategori ?? this.kategori,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
