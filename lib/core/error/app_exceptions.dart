sealed class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: [$code] $message';
}

class NetworkException extends AppException {
  NetworkException([String message = 'Check your internet connection'])
      : super(message, 'network-error');
}

class AuthException extends AppException {
  AuthException(String message, [String? code])
      : super(message, code ?? 'auth-error');
}

class DatabaseException extends AppException {
  DatabaseException(String message, [String? code])
      : super(message, code ?? 'db-error');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, 'validation-error');
}
