import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../model/pengeluaran_model.dart';

class PengeluaranService {
  final ApiClient _client;

  PengeluaranService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/pengeluaran
  Future<List<PengeluaranModel>> getAll() async {
    final response = await _client.get(ApiConstants.pengeluaran);
    final List data = response['data'] ?? response ?? [];
    return data.map((e) => PengeluaranModel.fromJson(e)).toList();
  }

  /// GET /api/pengeluaran/:id
  Future<PengeluaranModel> getById(int id) async {
    final response = await _client.get(ApiConstants.pengeluaranById(id));
    final data = response['data'] ?? response;
    return PengeluaranModel.fromJson(data);
  }

  /// POST /api/pengeluaran
  Future<PengeluaranModel> create(PengeluaranModel pengeluaran) async {
    final response = await _client.post(
      ApiConstants.pengeluaran,
      pengeluaran.toJson(),
      auth: true,
    );
    final data = response['data'] ?? response;
    return PengeluaranModel.fromJson(data);
  }

  /// PUT /api/pengeluaran/:id
  Future<PengeluaranModel> update(int id, PengeluaranModel pengeluaran) async {
    final response = await _client.put(
      ApiConstants.pengeluaranById(id),
      pengeluaran.toJson(),
    );
    final data = response['data'] ?? response;
    return PengeluaranModel.fromJson(data);
  }

  /// DELETE /api/pengeluaran/:id
  Future<void> delete(int id) async {
    await _client.delete(ApiConstants.pengeluaranById(id));
  }
}
