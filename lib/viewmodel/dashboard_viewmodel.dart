import 'package:flutter/material.dart';
import '../core/constants/app_enums.dart';
import '../model/dashboard_model.dart';
import '../repository/dashboard_repository.dart';

export '../core/constants/app_enums.dart' show ViewState;

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository;

  ViewState _state = ViewState.idle;
  DashboardModel _dashboard = DashboardModel.empty();
  String? _errorMessage;

  DashboardViewModel({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository();

  ViewState get state => _state;
  DashboardModel get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;

  Future<void> loadDashboard() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _dashboard = await _repository.getDashboard();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('AppException: ', '');
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
