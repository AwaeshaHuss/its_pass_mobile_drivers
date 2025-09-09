class ServerException implements Exception {}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);
}
