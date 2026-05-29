class UtangPiutangModel {
  final String? id;
  final String nama;
  final String tipe; // 'utang' atau 'piutang'
  final double totalTagihan;
  final double dp;
  final double sisaPembayaran;
  final String status; // 'belum_lunas' atau 'lunas'
  final String? keterangan;
  final dynamic createdBy;
  final String? createdAt;
  final String? updatedAt;

  UtangPiutangModel({
    this.id,
    required this.nama,
    required this.tipe,
    required this.totalTagihan,
    required this.dp,
    required this.sisaPembayaran,
    this.status = 'belum_lunas',
    this.keterangan,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory UtangPiutangModel.fromJson(Map<String, dynamic> json) {
    String rawTipe = (json['tipe'] ?? json['jenis'] ?? json['type'] ?? 'utang').toString().toLowerCase();
    if (rawTipe == 'supplier') rawTipe = 'utang';
    if (rawTipe == 'customer') rawTipe = 'piutang';

    return UtangPiutangModel(
      id: json['id']?.toString(),
      nama: json['nama'] ?? json['nama_orang'] ?? json['judul'] ?? '',
      tipe: rawTipe,
      totalTagihan: double.tryParse(json['total_tagihan']?.toString() ?? json['totalTagihan']?.toString() ?? json['jumlah']?.toString() ?? '0') ?? 0.0,
      dp: double.tryParse(json['dp']?.toString() ?? '0') ?? 0.0,
      sisaPembayaran: double.tryParse(json['sisa_pembayaran']?.toString() ?? json['sisaPembayaran']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? (json['is_lunas'] == true ? 'lunas' : 'belum_lunas'),
      keterangan: json['keterangan'],
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: json['created_at'] ?? json['createdAt'],
      updatedAt: json['updated_at'] ?? json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'tipe': tipe == 'utang' ? 'supplier' : 'customer',
        'total_tagihan': totalTagihan,
        'dp': dp,
        'sisa_pembayaran': sisaPembayaran,
        'status': status,
        'keterangan': keterangan,
      };

  UtangPiutangModel copyWith({
    String? id,
    String? nama,
    String? tipe,
    double? totalTagihan,
    double? dp,
    double? sisaPembayaran,
    String? status,
    String? keterangan,
    dynamic createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return UtangPiutangModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      totalTagihan: totalTagihan ?? this.totalTagihan,
      dp: dp ?? this.dp,
      sisaPembayaran: sisaPembayaran ?? this.sisaPembayaran,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
