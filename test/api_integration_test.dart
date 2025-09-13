import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itspass_driver/core/services/api_service.dart';
import 'package:itspass_driver/core/services/auth_api_service.dart';
import 'package:itspass_driver/core/services/file_upload_service.dart';
import 'package:itspass_driver/core/constants/api_constants.dart';

void main() {
  group('API Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferences.getInstance();
    });

    test('API constants should be properly defined', () {
      expect(ApiConstants.baseUrl, isNotEmpty);
      expect(ApiConstants.login, isNotEmpty);
      expect(ApiConstants.logout, isNotEmpty);
      expect(ApiConstants.profile, isNotEmpty);
      expect(ApiConstants.registerDriver, isNotEmpty);
      expect(ApiConstants.uploadIdFront, isNotEmpty);
      expect(ApiConstants.uploadLicenseFront, isNotEmpty);
      expect(ApiConstants.uploadSelfieWithId, isNotEmpty);
    });

    test('ApiService singleton should initialize', () {
      final apiService = ApiService();
      expect(apiService, isNotNull);
    });

    test('AuthApiService singleton should initialize', () {
      final authApiService = AuthApiService();
      expect(authApiService, isNotNull);
      expect(authApiService.isAuthenticated, isFalse);
    });

    test('FileUploadService singleton should initialize', () {
      final fileUploadService = FileUploadService();
      expect(fileUploadService, isNotNull);
    });

    test('API service singletons should return same instance', () {
      final apiService1 = ApiService();
      final apiService2 = ApiService();
      expect(apiService1, equals(apiService2));

      final authService1 = AuthApiService();
      final authService2 = AuthApiService();
      expect(authService1, equals(authService2));

      final fileService1 = FileUploadService();
      final fileService2 = FileUploadService();
      expect(fileService1, equals(fileService2));
    });

    test('Authentication state should be properly managed', () async {
      final authApiService = AuthApiService();
      
      // Initially not authenticated
      expect(authApiService.isAuthenticated, isFalse);
      
      // Test logout (should not throw)
      await authApiService.logout();
      expect(authApiService.isAuthenticated, isFalse);
    });
  });
}
