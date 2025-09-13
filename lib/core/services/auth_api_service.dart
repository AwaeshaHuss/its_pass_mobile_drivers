import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';
import 'api_service.dart';

class AuthApiService {
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;
  AuthApiService._internal();

  final ApiService _apiService = ApiService();
  DriverProfile? _currentDriver;
  bool _isAuthenticated = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  DriverProfile? get currentDriver => _currentDriver;

  // Initialize the service
  Future<void> initialize() async {
    _apiService.initialize();
    await _loadAuthState();
  }

  // Login method
  Future<ApiResponse<AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(
        username: username,
        password: password,
      );

      if (response.isSuccess && response.data != null) {
        _currentDriver = response.data!.driver;
        _isAuthenticated = true;
        await _saveAuthState();
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return ApiResponse.error('Login failed: $e');
    }
  }

  // Logout method
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiService.logout();
      
      // Clear local state regardless of API response
      await _clearAuthState();
      
      return response;
    } catch (e) {
      // Clear local state even if API call fails
      await _clearAuthState();
      return ApiResponse.error('Logout failed: $e');
    }
  }

  // Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return await _apiService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  // Get current profile
  Future<ApiResponse<DriverProfile>> getProfile() async {
    if (!_isAuthenticated) {
      return ApiResponse.error('Not authenticated');
    }

    final response = await _apiService.getProfile();
    
    if (response.isSuccess && response.data != null) {
      _currentDriver = response.data;
      await _saveAuthState();
    }
    
    return response;
  }

  // Update profile
  Future<ApiResponse<void>> updateProfile({
    required DriverProfileUpdate data,
  }) async {
    if (!_isAuthenticated) {
      return ApiResponse.error('Not authenticated');
    }

    final response = await _apiService.updateProfile(data: data);
    
    if (response.isSuccess) {
      // Refresh profile after successful update
      await getProfile();
    }
    
    return response;
  }

  // Update driver status (online/offline)
  Future<ApiResponse<void>> updateStatus({
    required String status,
  }) async {
    if (!_isAuthenticated) {
      return ApiResponse.error('Not authenticated');
    }

    final response = await _apiService.updateStatus(status: status);
    
    if (response.isSuccess && _currentDriver != null) {
      // Update local driver status
      _currentDriver = DriverProfile(
        id: _currentDriver!.id,
        name: _currentDriver!.name,
        email: _currentDriver!.email,
        phoneNumber: _currentDriver!.phoneNumber,
        profilePhoto: _currentDriver!.profilePhoto,
        status: status,
        vehicleType: _currentDriver!.vehicleType,
        carName: _currentDriver!.carName,
        carModel: _currentDriver!.carModel,
        carNumber: _currentDriver!.carNumber,
        carColor: _currentDriver!.carColor,
        rating: _currentDriver!.rating,
        totalTrips: _currentDriver!.totalTrips,
        totalEarnings: _currentDriver!.totalEarnings,
        createdAt: _currentDriver!.createdAt,
        updatedAt: DateTime.now(),
      );
      await _saveAuthState();
    }
    
    return response;
  }

  // Update location
  Future<ApiResponse<void>> updateLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    if (!_isAuthenticated) {
      return ApiResponse.error('Not authenticated');
    }

    return await _apiService.updateLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  // Private methods for state management
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _apiService.loadAuthToken();
      
      final driverJson = prefs.getString('current_driver');
      if (driverJson != null) {
        // Parse driver profile from JSON
        // This would require implementing fromJsonString method
        _isAuthenticated = _apiService.isAuthenticated;
      } else {
        _isAuthenticated = false;
        _currentDriver = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentDriver = null;
    }
  }

  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentDriver != null) {
        // Save driver profile as JSON string
        // This would require implementing toJsonString method
        await prefs.setString('current_driver', _currentDriver!.toJson().toString());
      }
      
      await prefs.setBool('is_authenticated', _isAuthenticated);
    } catch (e) {
      // Handle save error
    }
  }

  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_driver');
      await prefs.remove('is_authenticated');
      
      _currentDriver = null;
      _isAuthenticated = false;
    } catch (e) {
      // Handle clear error
      _currentDriver = null;
      _isAuthenticated = false;
    }
  }

  // Check if user needs to complete registration
  bool get needsRegistration {
    if (!_isAuthenticated || _currentDriver == null) return true;
    
    // Check if essential profile fields are missing
    return _currentDriver!.carName == null || 
           _currentDriver!.carModel == null || 
           _currentDriver!.carNumber == null;
  }

  // Get driver status
  String get driverStatus {
    return _currentDriver?.status ?? 'offline';
  }

  // Check if driver is online
  bool get isOnline {
    return driverStatus == 'online';
  }
}
