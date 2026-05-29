import 'package:flutter/material.dart';
import '../core/constants/app_enums.dart';
import '../model/user_model.dart';
import '../repository/auth_repository.dart';
import '../core/utils/token_manager.dart';

export '../core/constants/app_enums.dart' show AuthState;

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = AuthState.idle;
  UserModel? _user;
  String? _errorMessage;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  Future<void> checkAuthStatus() async {
    final loggedIn = await TokenManager.isLoggedIn();
    _state = loggedIn ? AuthState.authenticated : AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _repository.login(email, password);
      _state = AuthState.authenticated;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('AppException: ', '');
      _state = AuthState.error;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      await _repository.logout();
    } catch (_) {}
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
