import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../model/utang_piutang_model.dart';

class UtangPiutangService {
  final ApiClient _client;

  UtangPiutangService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/utang-piutang
  Future<List<UtangPiutangModel>> getAll() async {
    final response = await _client.get(ApiConstants.utangPiutang);
    final List data = response['data'] ?? response ?? [];
    return data.map((e) => UtangPiutangModel.fromJson(e)).toList();
  }

  /// GET /api/utang-piutang/:id
  Future<UtangPiutangModel> getById(int id) async {
    final response = await _client.get(ApiConstants.utangPiutangById(id));
    final data = response['data'] ?? response;
    return UtangPiutangModel.fromJson(data);
  }

  /// POST /api/utang-piutang
  Future<UtangPiutangModel> create(UtangPiutangModel utangPiutang) async {
    final response = await _client.post(
      ApiConstants.utangPiutang,
      utangPiutang.toJson(),
      auth: true,
    );
    final data = response['data'] ?? response;
    return UtangPiutangModel.fromJson(data);
  }

  /// PUT /api/utang-piutang/:id
  Future<UtangPiutangModel> update(int id, UtangPiutangModel utangPiutang) async {
    final response = await _client.put(
      ApiConstants.utangPiutangById(id),
      utangPiutang.toJson(),
    );
    final data = response['data'] ?? response;
    return UtangPiutangModel.fromJson(data);
  }

  /// DELETE /api/utang-piutang/:id
  Future<void> delete(int id) async {
    await _client.delete(ApiConstants.utangPiutangById(id));
  }
}
