class AppException implements Exception {
  AppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.code});
}