import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/token_manager.dart';
import '../model/user_model.dart';

class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Login — POST /api/login
  Future<UserModel> login(String email, String password) async {
    final response = await _client.post(
      ApiConstants.login,
      {'email': email, 'password': password},
      auth: false,
    );
    // Laravel Sanctum response: { token: "...", user: {...} }
    // Fallback: { data: { token: "...", user: {...} } }
    final data = response['data'] ?? response;
    final token = data['token']?.toString() ?? '';
    final userJson = data['user'] ?? data;

    final user = UserModel.fromJson({...userJson, 'token': token});
    await TokenManager.saveToken(token);
    return user;
  }

  /// Logout — POST /api/logout
  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout, {}, auth: true);
    } finally {
      await TokenManager.clearAll();
    }
  }
}
