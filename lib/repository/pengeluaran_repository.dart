import '../model/pengeluaran_model.dart';
import '../service/pengeluaran_service.dart';

abstract class IPengeluaranRepository {
  Future<List<PengeluaranModel>> getAll();
  Future<PengeluaranModel> getById(int id);
  Future<PengeluaranModel> create(PengeluaranModel pengeluaran);
  Future<PengeluaranModel> update(int id, PengeluaranModel pengeluaran);
  Future<void> delete(int id);
}

class PengeluaranRepository implements IPengeluaranRepository {
  final PengeluaranService _service;

  PengeluaranRepository({PengeluaranService? service})
      : _service = service ?? PengeluaranService();

  @override
  Future<List<PengeluaranModel>> getAll() => _service.getAll();

  @override
  Future<PengeluaranModel> getById(int id) => _service.getById(id);

  @override
  Future<PengeluaranModel> create(PengeluaranModel pengeluaran) =>
      _service.create(pengeluaran);

  @override
  Future<PengeluaranModel> update(int id, PengeluaranModel pengeluaran) =>
      _service.update(id, pengeluaran);

  @override
  Future<void> delete(int id) => _service.delete(id);
}
