import '../model/pemasukan_model.dart';
import '../service/pemasukan_service.dart';

abstract class IPemasukanRepository {
  Future<List<PemasukanModel>> getAll();
  Future<PemasukanModel> getById(String id);
  Future<PemasukanModel> create(PemasukanModel pemasukan);
  Future<PemasukanModel> update(String id, PemasukanModel pemasukan);
  Future<void> delete(String id);
}

class PemasukanRepository implements IPemasukanRepository {
  final PemasukanService _service;

  PemasukanRepository({PemasukanService? service})
      : _service = service ?? PemasukanService();

  @override
  Future<List<PemasukanModel>> getAll() => _service.getAll();

  @override
  Future<PemasukanModel> getById(String id) => _service.getById(id);

  @override
  Future<PemasukanModel> create(PemasukanModel pemasukan) =>
      _service.create(pemasukan);

  @override
  Future<PemasukanModel> update(String id, PemasukanModel pemasukan) =>
      _service.update(id, pemasukan);

  @override
  Future<void> delete(String id) => _service.delete(id);
}
