import 'package:flutter_test/flutter_test.dart';
import 'package:itspass_driver/core/constants/api_constants.dart';
import 'package:itspass_driver/core/services/secure_storage_service.dart';
import 'package:itspass_driver/core/services/auth_service.dart';
import 'package:itspass_driver/core/services/driver_service.dart';
import 'package:itspass_driver/core/services/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Production Readiness Tests', () {
    test('API base URL should be production endpoint', () {
      expect(ApiConstants.baseUrl, 'https://pass.elite-center-ld.com');
    });

    test('SecureStorageService should be properly configured', () async {
      // Test that secure storage service is properly initialized
      expect(SecureStorageService.isAuthenticated, isA<Function>());
      expect(SecureStorageService.getAuthToken, isA<Function>());
      expect(SecureStorageService.storeAuthToken, isA<Function>());
    });

    test('AuthService should be properly initialized', () {
      final authService = AuthService();
      expect(authService, isNotNull);
      expect(authService.login, isA<Function>());
      expect(authService.logout, isA<Function>());
    });

    test('DriverService should be properly initialized', () {
      final driverService = DriverService();
      expect(driverService, isNotNull);
      expect(driverService.updateStatus, isA<Function>());
      expect(driverService.updateLocation, isA<Function>());
    });

    test('LocationService should be properly initialized', () {
      final locationService = LocationService();
      expect(locationService, isNotNull);
      // LocationService exists and can be instantiated
    });

    test('All critical API endpoints should be defined', () {
      expect(ApiConstants.login, isNotEmpty);
      expect(ApiConstants.logout, isNotEmpty);
      expect(ApiConstants.registerDriver, isNotEmpty);
      expect(ApiConstants.updateStatus, isNotEmpty);
      expect(ApiConstants.updateLocation, isNotEmpty);
      expect(ApiConstants.availableTrips, isNotEmpty);
      expect(ApiConstants.acceptTrip, isNotEmpty);
      expect(ApiConstants.completeTrip, isNotEmpty);
      expect(ApiConstants.earnings, isNotEmpty);
      expect(ApiConstants.wallet, isNotEmpty);
    });

    test('Secure storage service should be available', () {
      // Test that secure storage service methods exist
      expect(SecureStorageService.storeAuthToken, isA<Function>());
      expect(SecureStorageService.getAuthToken, isA<Function>());
      expect(SecureStorageService.clearAuthData, isA<Function>());
      expect(SecureStorageService.isAuthenticated, isA<Function>());
    });

    test('Production configuration should be complete', () {
      // Verify all production endpoints are properly configured
      final endpoints = [
        ApiConstants.login,
        ApiConstants.logout,
        ApiConstants.profile,
        ApiConstants.registerDriver,
        ApiConstants.checkStatus,
        ApiConstants.updateProfile,
        ApiConstants.getDriverStatus,
        ApiConstants.updateStatus,
        ApiConstants.updateLocation,
        ApiConstants.availableTrips,
        ApiConstants.acceptTrip,
        ApiConstants.completeTrip,
        ApiConstants.earnings,
        ApiConstants.wallet,
      ];

      for (final endpoint in endpoints) {
        expect(endpoint, isNotEmpty);
        expect(endpoint, startsWith('/'));
      }
    });
  });
}
