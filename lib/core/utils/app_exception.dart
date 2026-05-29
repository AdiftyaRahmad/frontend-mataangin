class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}

class UnauthorizedException extends AppException {
  UnauthorizedException({super.message = 'Sesi habis, silakan login kembali.'})
      : super(statusCode: 401);
}

class ServerException extends AppException {
  ServerException({super.message = 'Terjadi kesalahan pada server.'})
      : super(statusCode: 500);
}

class NetworkException extends AppException {
  NetworkException({super.message = 'Tidak ada koneksi internet.'});
}
