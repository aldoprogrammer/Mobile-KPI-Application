class AppException implements Exception {
  AppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class NetworkException extends AppException {
  NetworkException(String message, {int? code}) : super(message, code: code);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message, {int? code}) : super(message, code: code);
}