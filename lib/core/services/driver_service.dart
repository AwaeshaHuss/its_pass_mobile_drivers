import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/trip_models.dart';
import '../models/transaction_models.dart';
import 'secure_storage_service.dart';

class DriverService {
  static final DriverService _instance = DriverService._internal();
  factory DriverService() => _instance;
  DriverService._internal();

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
    ));
    
    _isInitialized = true;
  }

  // Driver Registration
  Future<ApiResponse<void>> registerDriver(Map<String, dynamic> driverData) async {
    try {
      final response = await _dio.post(
        ApiConstants.registerDriver,
        data: driverData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Registration failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Registration failed: ${e.message}');
      }
      return ApiResponse.error('Registration failed: $e');
    }
  }

  // Check Registration Status
  Future<ApiResponse<Map<String, dynamic>>> checkRegistrationStatus(String phoneNumber) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkStatus,
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(Map<String, dynamic>.from(response.data));
      } else {
        return ApiResponse.error('Status check failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Status check failed: ${e.message}');
      }
      return ApiResponse.error('Status check failed: $e');
    }
  }

  // Get Driver Status
  Future<ApiResponse<Map<String, dynamic>>> getDriverStatus() async {
    try {
      initialize(); // Ensure service is initialized
      
      final response = await _dio.get(ApiConstants.getDriverStatus);

      if (response.statusCode == 200) {
        return ApiResponse.success(Map<String, dynamic>.from(response.data));
      } else {
        return ApiResponse.error('Failed to get driver status: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to get driver status: ${e.message}');
      }
      return ApiResponse.error('Failed to get driver status: $e');
    }
  }

  // Update Driver Status
  Future<ApiResponse<void>> updateDriverStatus(String status) async {
    try {
      initialize(); // Ensure service is initialized
      
      final response = await _dio.put(
        ApiConstants.updateStatus,
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to update driver status: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to update driver status: ${e.message}');
      }
      return ApiResponse.error('Failed to update driver status: $e');
    }
  }

  // Update Driver Profile
  Future<ApiResponse<void>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.post(
        ApiConstants.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Profile update failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Profile update failed: ${e.message}');
      }
      return ApiResponse.error('Profile update failed: $e');
    }
  }

  // Update Driver Status (online/offline)
  Future<ApiResponse<void>> updateStatus(String status) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateStatus,
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        // Update local storage
        final profile = await SecureStorageService.getDriverProfile();
        profile['status'] = status;
        await SecureStorageService.storeDriverProfile(profile);
        
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Status update failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Status update failed: ${e.message}');
      }
      return ApiResponse.error('Status update failed: $e');
    }
  }

  // Update Driver Location
  Future<ApiResponse<void>> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (address != null) 'address': address,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Location update failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Location update failed: ${e.message}');
      }
      return ApiResponse.error('Location update failed: $e');
    }
  }

  // Get Available Trips
  Future<ApiResponse<List<Trip>>> getAvailableTrips({int radius = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.availableTrips}?radius=$radius',
      );

      if (response.statusCode == 200) {
        final List<dynamic> tripsData = response.data['trips'] ?? [];
        final trips = tripsData.map((trip) => Trip.fromJson(trip)).toList();
        return ApiResponse.success(trips);
      } else {
        return ApiResponse.error('Failed to get available trips: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to get available trips: ${e.message}');
      }
      return ApiResponse.error('Failed to get available trips: $e');
    }
  }

  // Accept Trip
  Future<ApiResponse<void>> acceptTrip(String tripId) async {
    try {
      final response = await _dio.post(
        ApiConstants.acceptTrip,
        data: {'trip_id': tripId},
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to accept trip: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to accept trip: ${e.message}');
      }
      return ApiResponse.error('Failed to accept trip: $e');
    }
  }

  // Complete Trip
  Future<ApiResponse<void>> completeTrip(String tripId) async {
    try {
      final response = await _dio.post(
        ApiConstants.completeTrip,
        data: {'trip_id': tripId},
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to complete trip: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to complete trip: ${e.message}');
      }
      return ApiResponse.error('Failed to complete trip: $e');
    }
  }

  // Update Trip Status
  Future<ApiResponse<void>> updateTripStatus(String tripId, String status) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateTripStatus,
        data: {
          'trip_id': tripId,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to update trip status: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to update trip status: ${e.message}');
      }
      return ApiResponse.error('Failed to update trip status: $e');
    }
  }

  // Rate Customer
  Future<ApiResponse<void>> rateCustomer(String tripId, int rating, String? comment) async {
    try {
      final response = await _dio.post(
        ApiConstants.rateCustomer,
        data: {
          'trip_id': tripId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to rate customer: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to rate customer: ${e.message}');
      }
      return ApiResponse.error('Failed to rate customer: $e');
    }
  }

  // Get Trip History
  Future<ApiResponse<List<Trip>>> getTripHistory() async {
    try {
      final response = await _dio.get(ApiConstants.tripHistory);

      if (response.statusCode == 200) {
        final List<dynamic> tripsData = response.data['trips'] ?? [];
        final trips = tripsData.map((trip) => Trip.fromJson(trip)).toList();
        return ApiResponse.success(trips);
      } else {
        return ApiResponse.error('Failed to get trip history: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to get trip history: ${e.message}');
      }
      return ApiResponse.error('Failed to get trip history: $e');
    }
  }

  // Get Wallet Information
  Future<ApiResponse<Map<String, dynamic>>> getWallet() async {
    try {
      final response = await _dio.get(ApiConstants.wallet);

      if (response.statusCode == 200) {
        return ApiResponse.success(Map<String, dynamic>.from(response.data));
      } else {
        return ApiResponse.error('Failed to get wallet info: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to get wallet info: ${e.message}');
      }
      return ApiResponse.error('Failed to get wallet info: $e');
    }
  }

  // Get Earnings
  Future<ApiResponse<Map<String, dynamic>>> getEarnings() async {
    try {
      final response = await _dio.get(ApiConstants.earnings);

      if (response.statusCode == 200) {
        return ApiResponse.success(Map<String, dynamic>.from(response.data));
      } else {
        return ApiResponse.error('Failed to get earnings: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to get earnings: ${e.message}');
      }
      return ApiResponse.error('Failed to get earnings: $e');
    }
  }

  // Get Balance
  Future<ApiResponse<Map<String, dynamic>>> getBalance() async {
    try {
      final response = await _dio.get(ApiConstants.balance);

      if (response.statusCode == 200) {
        return ApiResponse.success(Map<String, dynamic>.from(response.data));
      } else {
        return ApiResponse.error('Failed to get balance: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to get balance: ${e.message}');
      }
      return ApiResponse.error('Failed to get balance: $e');
    }
  }

  // Get Transaction History
  Future<ApiResponse<List<Transaction>>> getTransactionHistory() async {
    try {
      final response = await _dio.get(ApiConstants.transactionHistory);

      if (response.statusCode == 200) {
        final List<dynamic> transactionsJson = response.data['transactions'] ?? [];
        final transactions = transactionsJson
            .map((json) => Transaction.fromJson(json))
            .toList();
        return ApiResponse.success(transactions);
      } else {
        return ApiResponse.error('Failed to get transaction history: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to get transaction history: ${e.message}');
      }
      return ApiResponse.error('Failed to get transaction history: $e');
    }
  }

  // Request Withdrawal
  Future<ApiResponse<void>> requestWithdrawal(double amount) async {
    try {
      final response = await _dio.post(
        ApiConstants.requestWithdrawal,
        data: {'amount': amount},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to request withdrawal: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to request withdrawal: ${e.message}');
      }
      return ApiResponse.error('Failed to request withdrawal: $e');
    }
  }

  // Get Withdrawal History
  Future<ApiResponse<List<WithdrawalRequest>>> getWithdrawalHistory() async {
    try {
      final response = await _dio.get(ApiConstants.withdrawalHistory);

      if (response.statusCode == 200) {
        final List<dynamic> withdrawalsJson = response.data['withdrawals'] ?? [];
        final withdrawals = withdrawalsJson
            .map((json) => WithdrawalRequest.fromJson(json))
            .toList();
        return ApiResponse.success(withdrawals);
      } else {
        return ApiResponse.error('Failed to get withdrawal history: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Failed to get withdrawal history: ${e.message}');
      }
      return ApiResponse.error('Failed to get withdrawal history: $e');
    }
  }
}
