import 'package:logger/logger.dart';

/// Centralized logging service for the application
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Log debug messages
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info messages
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning messages
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error messages
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal/critical messages
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log API requests
  static void apiRequest(String method, String url, [Map<String, dynamic>? data]) {
    _logger.i('API Request: $method $url', error: data);
  }

  /// Log API responses
  static void apiResponse(String method, String url, int statusCode, [dynamic data]) {
    _logger.i('API Response: $method $url - Status: $statusCode', error: data);
  }

  /// Log location updates
  static void location(String message, [dynamic data]) {
    _logger.d('Location: $message', error: data);
  }

  /// Log push notification events
  static void notification(String message, [dynamic data]) {
    _logger.i('Notification: $message', error: data);
  }

  /// Log trip events
  static void trip(String message, [dynamic data]) {
    _logger.i('Trip: $message', error: data);
  }

  /// Log authentication events
  static void auth(String message, [dynamic data]) {
    _logger.i('Auth: $message', error: data);
  }
}
