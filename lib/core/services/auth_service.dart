import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';
import 'secure_storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = Dio();
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add interceptor for automatic token attachment
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, clear auth data
          await logout();
        }
        handler.next(error);
      },
    ));
    
    _isInitialized = true;
  }

  // Login method
  Future<ApiResponse<AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        
        // Store tokens securely
        await SecureStorageService.storeAuthToken(authResponse.token);
        await SecureStorageService.storeUserId(authResponse.driver?.id.toString() ?? '');
        
        // Store user/driver info
        if (authResponse.driver?.id != null) {
          await SecureStorageService.storeDriverId(authResponse.driver!.id.toString());
        }
        
        // Store driver profile data
        if (authResponse.driver != null) {
          await SecureStorageService.storeDriverProfile({
            'name': authResponse.driver!.name,
            'email': authResponse.driver!.email,
            'phone': authResponse.driver!.phoneNumber,
            'status': authResponse.driver!.status,
          });
        }
        
        return ApiResponse.success(authResponse);
      } else {
        return ApiResponse.error('Login failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Login failed: ${e.message}');
      }
      return ApiResponse.error('Login failed: $e');
    }
  }

  // Get current user profile
  Future<ApiResponse<DriverProfile>> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        final profile = DriverProfile.fromJson(response.data);
        
        // Update stored profile data
        await SecureStorageService.storeDriverProfile({
          'name': profile.name,
          'email': profile.email,
          'phone': profile.phoneNumber,
          'status': profile.status,
        });
        
        return ApiResponse.success(profile);
      } else {
        return ApiResponse.error('Failed to get profile: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to get profile: ${e.message}');
      }
      return ApiResponse.error('Failed to get profile: $e');
    }
  }

  // Logout method
  Future<ApiResponse<void>> logout() async {
    try {
      // Try to call logout endpoint
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      // Continue with local logout even if API call fails
      print('Logout API call failed: $e');
    }
    
    // Clear all stored authentication data
    await SecureStorageService.clearAuthData();
    
    return ApiResponse.success(null);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await SecureStorageService.isAuthenticated();
  }

  // Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Password change failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Password change failed: ${e.message}');
      }
      return ApiResponse.error('Password change failed: $e');
    }
  }

  // Get current driver profile from storage
  Future<Map<String, String?>> getCurrentDriverProfile() async {
    return await SecureStorageService.getDriverProfile();
  }
}
