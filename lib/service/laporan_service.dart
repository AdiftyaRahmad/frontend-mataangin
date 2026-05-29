import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/token_manager.dart';
import '../model/laporan_model.dart';

class LaporanService {
  final ApiClient _client;
  final http.Client _rawClient;

  LaporanService({ApiClient? client, http.Client? rawClient})
      : _client = client ?? ApiClient(),
        _rawClient = rawClient ?? http.Client();

  /// GET /api/laporan/harian?tanggal=YYYY-MM-DD
  Future<LaporanModel> getHarian(String tanggal) async {
    final url = '${ApiConstants.laporanHarian}?tanggal=$tanggal';
    final response = await _client.get(url);
    return LaporanModel.fromJson(response);
  }

  /// GET /api/laporan/bulanan?bulan=MM&tahun=YYYY
  Future<LaporanModel> getBulanan(String bulan, String tahun) async {
    final url = '${ApiConstants.laporanBulanan}?bulan=$bulan&tahun=$tahun';
    final response = await _client.get(url);
    return LaporanModel.fromJson(response);
  }

  /// GET /api/laporan/export-pdf
  /// Returns raw bytes of the PDF file
  Future<List<int>> exportPdfBytes() async {
    final token = await TokenManager.getToken();
    final headers = {
      'Accept': 'application/pdf',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await _rawClient.get(
      Uri.parse(ApiConstants.laporanExportPdf),
      headers: headers,
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Gagal mengunduh PDF (${response.statusCode})');
    }
  }
}
