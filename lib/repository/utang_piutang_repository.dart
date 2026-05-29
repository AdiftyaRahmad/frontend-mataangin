import '../model/utang_piutang_model.dart';
import '../service/utang_piutang_service.dart';

abstract class IUtangPiutangRepository {
  Future<List<UtangPiutangModel>> getAll();
  Future<UtangPiutangModel> getById(int id);
  Future<UtangPiutangModel> create(UtangPiutangModel utangPiutang);
  Future<UtangPiutangModel> update(int id, UtangPiutangModel utangPiutang);
  Future<void> delete(int id);
}

class UtangPiutangRepository implements IUtangPiutangRepository {
  final UtangPiutangService _service;

  UtangPiutangRepository({UtangPiutangService? service})
      : _service = service ?? UtangPiutangService();

  @override
  Future<List<UtangPiutangModel>> getAll() => _service.getAll();

  @override
  Future<UtangPiutangModel> getById(int id) => _service.getById(id);

  @override
  Future<UtangPiutangModel> create(UtangPiutangModel utangPiutang) =>
      _service.create(utangPiutang);

  @override
  Future<UtangPiutangModel> update(int id, UtangPiutangModel utangPiutang) =>
      _service.update(id, utangPiutang);

  @override
  Future<void> delete(int id) => _service.delete(id);
}
