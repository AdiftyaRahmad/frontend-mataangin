import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../model/pemasukan_model.dart';

class PemasukanService {
  final ApiClient _client;

  PemasukanService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/pemasukan
  Future<List<PemasukanModel>> getAll() async {
    final response = await _client.get(ApiConstants.pemasukan);
    final List data = response['data'] ?? response ?? [];
    return data.map((e) => PemasukanModel.fromJson(e)).toList();
  }

  /// GET /api/pemasukan/:id
  Future<PemasukanModel> getById(int id) async {
    final response = await _client.get(ApiConstants.pemasukanById(id));
    final data = response['data'] ?? response;
    return PemasukanModel.fromJson(data);
  }

  /// POST /api/pemasukan
  Future<PemasukanModel> create(PemasukanModel pemasukan) async {
    final response = await _client.post(
      ApiConstants.pemasukan,
      pemasukan.toJson(),
      auth: true,
    );
    final data = response['data'] ?? response;
    return PemasukanModel.fromJson(data);
  }

  /// PUT /api/pemasukan/:id
  Future<PemasukanModel> update(int id, PemasukanModel pemasukan) async {
    final response = await _client.put(
      ApiConstants.pemasukanById(id),
      pemasukan.toJson(),
    );
    final data = response['data'] ?? response;
    return PemasukanModel.fromJson(data);
  }

  /// DELETE /api/pemasukan/:id
  Future<void> delete(int id) async {
    await _client.delete(ApiConstants.pemasukanById(id));
  }
}
