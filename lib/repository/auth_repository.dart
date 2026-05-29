import '../model/user_model.dart';
import '../service/auth_service.dart';

abstract class IAuthRepository {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
}

class AuthRepository implements IAuthRepository {
  final AuthService _service;

  AuthRepository({AuthService? service}) : _service = service ?? AuthService();

  @override
  Future<UserModel> login(String email, String password) {
    return _service.login(email, password);
  }

  @override
  Future<void> logout() {
    return _service.logout();
  }
}
