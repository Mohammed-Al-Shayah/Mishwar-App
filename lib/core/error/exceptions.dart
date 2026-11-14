final class ServerException implements Exception {
  const ServerException(this.message, {this.code});

  final String message;
  final String? code;
}

final class NetworkException implements Exception {
  const NetworkException(this.message, {this.code});

  final String message;
  final String? code;
}

final class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;
}

final class CacheException implements Exception {
  const CacheException(this.message, {this.code});

  final String message;
  final String? code;
}
