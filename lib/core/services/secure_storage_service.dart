import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
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
    
    // Also clear from SharedPreferences for backward compatibility
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('driver_id');
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Store driver profile data (non-sensitive)
  static Future<void> storeDriverProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_name', profile['name'] ?? '');
    await prefs.setString('driver_email', profile['email'] ?? '');
    await prefs.setString('driver_phone', profile['phone'] ?? '');
    await prefs.setString('driver_status', profile['status'] ?? 'offline');
  }

  // Get driver profile data
  static Future<Map<String, String?>> getDriverProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('driver_name'),
      'email': prefs.getString('driver_email'),
      'phone': prefs.getString('driver_phone'),
      'status': prefs.getString('driver_status'),
    };
  }

  // Clear all stored data
  static Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
