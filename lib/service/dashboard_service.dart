import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../model/dashboard_model.dart';

class DashboardService {
  final ApiClient _client;

  DashboardService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/dashboard
  Future<DashboardModel> getDashboard() async {
    final response = await _client.get(ApiConstants.dashboard);
    return DashboardModel.fromJson(response);
  }
}
