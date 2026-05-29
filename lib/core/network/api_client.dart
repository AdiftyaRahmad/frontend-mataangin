import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_exception.dart';
import '../utils/token_manager.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // ─── Headers ──────────────────────────────────────────────────────────────

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ─── Response Handler ─────────────────────────────────────────────────────

  dynamic _handleResponse(http.Response response) {
    final body = _tryDecodeJson(response.body);
    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        throw UnauthorizedException(
          message: body?['message'] ?? 'Sesi habis, silakan login kembali.',
        );
      case 404:
        throw AppException(
          message: body?['message'] ?? 'Data tidak ditemukan.',
          statusCode: 404,
        );
      case 422:
        final errors = body?['errors'];
        String msg = 'Validasi gagal.';
        if (errors != null && errors is Map && errors.isNotEmpty) {
          final firstList = errors.values.first;
          if (firstList is List && firstList.isNotEmpty) {
            msg = firstList.first.toString();
          }
        } else if (body?['message'] != null) {
          msg = body!['message'].toString();
        }
        throw AppException(message: msg, statusCode: 422);
      case 500:
        throw ServerException(message: body?['message'] ?? 'Terjadi kesalahan pada server.');
      default:
        throw AppException(
          message: body?['message'] ?? 'Terjadi kesalahan (${response.statusCode}).',
          statusCode: response.statusCode,
        );
    }
  }

  dynamic _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  // ─── HTTP Methods ─────────────────────────────────────────────────────────

  Future<dynamic> get(String url, {bool auth = true}) async {
    try {
      final headers = auth ? await _authHeaders() : _publicHeaders;
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Koneksi gagal. Periksa koneksi internet Anda.');
    }
  }

  Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final headers = auth ? await _authHeaders() : _publicHeaders;
      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Koneksi gagal. Periksa koneksi internet Anda.');
    }
  }

  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    try {
      final headers = await _authHeaders();
      final response = await _client
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Koneksi gagal. Periksa koneksi internet Anda.');
    }
  }

  Future<dynamic> delete(String url) async {
    try {
      final headers = await _authHeaders();
      final response = await _client
          .delete(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Koneksi gagal. Periksa koneksi internet Anda.');
    }
  }
}
