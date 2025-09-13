import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';
import '../models/driver_models.dart';
import '../models/trip_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle common errors
        if (error.response?.statusCode == 401) {
          // Token expired, clear auth
          _clearAuthToken();
        }
        handler.next(error);
      },
    ));
  }

  // Authentication Methods
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
        _authToken = authResponse.token;
        await _saveAuthToken(authResponse.token);
        return ApiResponse.success(authResponse);
      } else {
        return ApiResponse.error('Login failed');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

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
        return ApiResponse.error('Failed to reset password');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dio.post(ApiConstants.logout);

      if (response.statusCode == 200) {
        await _clearAuthToken();
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Logout failed');
      }
    } on DioException catch (e) {
      await _clearAuthToken(); // Clear token even if logout fails
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      await _clearAuthToken();
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Driver Registration Methods
  Future<ApiResponse<void>> registerDriver({
    required DriverRegistrationData data,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.registerDriver,
        data: data.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Registration failed');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<RegistrationStatus>> checkRegistrationStatus({
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkStatus,
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200) {
        final status = RegistrationStatus.fromJson(response.data);
        return ApiResponse.success(status);
      } else {
        return ApiResponse.error('Failed to check status');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // File Upload Methods
  Future<ApiResponse<void>> uploadDocument({
    required String endpoint,
    required File file,
    required String phoneNumber,
    String? fieldName,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fieldName ?? 'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'phone_number': phoneNumber,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('File upload failed');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Profile Methods
  Future<ApiResponse<DriverProfile>> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        final profile = DriverProfile.fromJson(response.data);
        return ApiResponse.success(profile);
      } else {
        return ApiResponse.error('Failed to get profile');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> updateProfile({
    required DriverProfileUpdate data,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.profile,
        data: data.toJson(),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to update profile');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> updateStatus({
    required String status,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateStatus,
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to update status');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to update location');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Trip Methods
  Future<ApiResponse<List<Trip>>> getAvailableTrips({
    int radius = 10,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.availableTrips}?radius=$radius',
      );

      if (response.statusCode == 200) {
        final List<dynamic> tripsJson = response.data['trips'] ?? [];
        final trips = tripsJson.map((json) => Trip.fromJson(json)).toList();
        return ApiResponse.success(trips);
      } else {
        return ApiResponse.error('Failed to get available trips');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> acceptTrip({
    required int tripId,
    required int estimatedArrivalTime,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.acceptTrip,
        data: {
          'trip_id': tripId,
          'estimated_arrival_time': estimatedArrivalTime,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to accept trip');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<void>> completeTrip({
    required int tripId,
    required double finalAmount,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.completeTrip,
        data: {
          'trip_id': tripId,
          'final_amount': finalAmount,
          'payment_method': paymentMethod,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to complete trip');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<Trip>>> getTripHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.tripHistory}?page=$page&per_page=$perPage',
      );

      if (response.statusCode == 200) {
        final List<dynamic> tripsJson = response.data['trips'] ?? [];
        final trips = tripsJson.map((json) => Trip.fromJson(json)).toList();
        return ApiResponse.success(trips);
      } else {
        return ApiResponse.error('Failed to get trip history');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Wallet Methods
  Future<ApiResponse<WalletInfo>> getWallet() async {
    try {
      final response = await _dio.get(ApiConstants.wallet);

      if (response.statusCode == 200) {
        final wallet = WalletInfo.fromJson(response.data);
        return ApiResponse.success(wallet);
      } else {
        return ApiResponse.error('Failed to get wallet info');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<EarningsInfo>> getEarnings({
    String period = 'week',
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.earnings}?period=$period',
      );

      if (response.statusCode == 200) {
        final earnings = EarningsInfo.fromJson(response.data);
        return ApiResponse.success(earnings);
      } else {
        return ApiResponse.error('Failed to get earnings');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Utility Methods
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _dio.get(ApiConstants.health);

      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error('Health check failed');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // Private Methods
  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _authToken = token;
  }

  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _authToken = null;
  }

  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  bool get isAuthenticated => _authToken != null;

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Unknown error';
        return 'Server error ($statusCode): $message';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'Network error: ${error.message}';
    }
  }
}
