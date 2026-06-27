/// Base exception for all application-level errors.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class BackupException extends AppException {
  const BackupException(super.message);
}
