import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for secure storage
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _driverIdKey = 'driver_id';

  // Store authentication token securely
  static Future<void> storeAuthToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  // Get authentication token
  static Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  // Store refresh token securely
  static Future<void> storeRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Store user ID
  static Future<void> storeUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  // Store driver ID
  static Future<void> storeDriverId(String driverId) async {
    await _secureStorage.write(key: _driverIdKey, value: driverId);
  }

  // Get driver ID
  static Future<String?> getDriverId() async {
    return await _secureStorage.read(key: _driverIdKey);
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _driverIdKey);
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Store driver profile data in secure storage
  static Future<void> storeDriverProfile(Map<String, dynamic> profile) async {
    await _secureStorage.write(key: 'driver_name', value: profile['name'] ?? '');
    await _secureStorage.write(key: 'driver_email', value: profile['email'] ?? '');
    await _secureStorage.write(key: 'driver_phone', value: profile['phone'] ?? '');
    await _secureStorage.write(key: 'driver_status', value: profile['status'] ?? 'offline');
  }

  // Get driver profile data
  static Future<Map<String, String?>> getDriverProfile() async {
    return {
      'name': await _secureStorage.read(key: 'driver_name'),
      'email': await _secureStorage.read(key: 'driver_email'),
      'phone': await _secureStorage.read(key: 'driver_phone'),
      'status': await _secureStorage.read(key: 'driver_status'),
    };
  }

  // Clear all stored data
  static Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
  }
}
