class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message: message);
}

class AuthenticationException extends ApiException {
  AuthenticationException({required String message}) 
      : super(message: message, statusCode: 401);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;
  
  ValidationException(String message, this.errors) : super(message: message);
}

class ServerException extends ApiException {
  ServerException(String message, [int? statusCode]) 
      : super(message: message, statusCode: statusCode ?? 500);
}

class TimeoutException extends ApiException {
  TimeoutException({required String message}) 
      : super(message: message);
}
