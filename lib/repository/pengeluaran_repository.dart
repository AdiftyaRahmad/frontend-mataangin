import 'dart:typed_data';
import '../model/pengeluaran_model.dart';
import '../service/pengeluaran_service.dart';

abstract class IPengeluaranRepository {
  Future<List<PengeluaranModel>> getAll();
  Future<PengeluaranModel> getById(String id);
  Future<PengeluaranModel> create(PengeluaranModel pengeluaran);
  Future<PengeluaranModel> update(String id, PengeluaranModel pengeluaran);
  Future<void> delete(String id);
  Future<String> uploadBukti(Uint8List fileBytes, String fileName);
  Future<void> deleteBukti(String downloadUrl);
}

class PengeluaranRepository implements IPengeluaranRepository {
  final PengeluaranService _service;

  PengeluaranRepository({PengeluaranService? service})
      : _service = service ?? PengeluaranService();

  @override
  Future<List<PengeluaranModel>> getAll() => _service.getAll();

  @override
  Future<PengeluaranModel> getById(String id) => _service.getById(id);

  @override
  Future<PengeluaranModel> create(PengeluaranModel pengeluaran) =>
      _service.create(pengeluaran);

  @override
  Future<PengeluaranModel> update(String id, PengeluaranModel pengeluaran) =>
      _service.update(id, pengeluaran);

  @override
  Future<void> delete(String id) => _service.delete(id);

  @override
  Future<String> uploadBukti(Uint8List fileBytes, String fileName) =>
      _service.uploadBukti(fileBytes, fileName);

  @override
  Future<void> deleteBukti(String downloadUrl) => _service.deleteBukti(downloadUrl);
}
