import '../model/utang_piutang_model.dart';
import '../service/utang_piutang_service.dart';

abstract class IUtangPiutangRepository {
  Future<List<UtangPiutangModel>> getAll();
  Future<UtangPiutangModel> getById(String id);
  Future<UtangPiutangModel> create(UtangPiutangModel utangPiutang);
  Future<UtangPiutangModel> update(String id, UtangPiutangModel utangPiutang);
  Future<void> delete(String id);
}

class UtangPiutangRepository implements IUtangPiutangRepository {
  final UtangPiutangService _service;

  UtangPiutangRepository({UtangPiutangService? service})
      : _service = service ?? UtangPiutangService();

  @override
  Future<List<UtangPiutangModel>> getAll() => _service.getAll();

  @override
  Future<UtangPiutangModel> getById(String id) => _service.getById(id);

  @override
  Future<UtangPiutangModel> create(UtangPiutangModel utangPiutang) =>
      _service.create(utangPiutang);

  @override
  Future<UtangPiutangModel> update(String id, UtangPiutangModel utangPiutang) =>
      _service.update(id, utangPiutang);

  @override
  Future<void> delete(String id) => _service.delete(id);
}
