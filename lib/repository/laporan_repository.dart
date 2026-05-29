import '../model/laporan_model.dart';
import '../service/laporan_service.dart';

abstract class ILaporanRepository {
  Future<LaporanModel> getHarian(String tanggal);
  Future<LaporanModel> getBulanan(String bulan, String tahun);
  Future<List<int>> exportPdfBytes();
}

class LaporanRepository implements ILaporanRepository {
  final LaporanService _service;

  LaporanRepository({LaporanService? service})
      : _service = service ?? LaporanService();

  @override
  Future<LaporanModel> getHarian(String tanggal) => _service.getHarian(tanggal);

  @override
  Future<LaporanModel> getBulanan(String bulan, String tahun) =>
      _service.getBulanan(bulan, tahun);

  @override
  Future<List<int>> exportPdfBytes() => _service.exportPdfBytes();
}
