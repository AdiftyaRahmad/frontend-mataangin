import '../model/dashboard_model.dart';
import '../service/dashboard_service.dart';

abstract class IDashboardRepository {
  Future<DashboardModel> getDashboard();
}

class DashboardRepository implements IDashboardRepository {
  final DashboardService _service;

  DashboardRepository({DashboardService? service})
      : _service = service ?? DashboardService();

  @override
  Future<DashboardModel> getDashboard() => _service.getDashboard();
}
