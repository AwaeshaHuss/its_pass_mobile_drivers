import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/driver_model.dart';

abstract class AuthRemoteDataSource {
  Future<DriverModel> signInWithPhone(String phoneNumber);
  Future<DriverModel> verifyOtp(String verificationId, String otp);
  Future<DriverModel> signInWithGoogle();
  Future<void> signOut();
  Future<DriverModel?> getCurrentDriver();
  Future<bool> isDriverBlocked(String driverId);
  Future<bool> isDriverProfileComplete(String driverId);
  Future<DriverModel> updateDriverProfile(DriverModel driver);
  Future<String> uploadProfileImage(String imagePath);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final GoogleSignIn googleSignIn;
  final SharedPreferences sharedPreferences;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.googleSignIn,
    required this.sharedPreferences,
    required this.baseUrl,
  });

  @override
  Future<DriverModel> signInWithPhone(String phoneNumber) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/send-otp',
        data: {'phoneNumber': phoneNumber},
      );

      if (response.statusCode == 200) {
        // Return a temporary driver model with verification ID
        return DriverModel(
          id: response.data['verificationId'],
          name: '',
          email: '',
          phone: phoneNumber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        throw AuthException('Failed to send OTP');
      }
    } catch (e) {
      throw AuthException('Failed to sign in with phone: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel> verifyOtp(String verificationId, String otp) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/verify-otp',
        data: {
          'verificationId': verificationId,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final driver = DriverModel.fromJson(data['driver']);
        
        // Store authentication token
        await sharedPreferences.setString('auth_token', data['token']);
        await sharedPreferences.setString('driver_id', driver.id);
        
        return driver;
      } else {
        throw AuthException('Invalid OTP');
      }
    } catch (e) {
      throw AuthException('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final response = await dio.post(
        '$baseUrl/auth/google-signin',
        data: {
          'accessToken': googleAuth.accessToken,
          'idToken': googleAuth.idToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final driver = DriverModel.fromJson(data['driver']);
        
        // Store authentication token
        await sharedPreferences.setString('auth_token', data['token']);
        await sharedPreferences.setString('driver_id', driver.id);
        
        return driver;
      } else {
        throw AuthException('Google authentication failed');
      }
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final token = sharedPreferences.getString('auth_token');
      if (token != null) {
        await dio.post(
          '$baseUrl/auth/signout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
      
      await Future.wait([
        sharedPreferences.remove('auth_token'),
        sharedPreferences.remove('driver_id'),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel?> getCurrentDriver() async {
    try {
      final token = sharedPreferences.getString('auth_token');
      final driverId = sharedPreferences.getString('driver_id');
      
      if (token == null || driverId == null) return null;

      final response = await dio.get(
        '$baseUrl/drivers/$driverId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return DriverModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw AuthException('Failed to get current driver: ${e.toString()}');
    }
  }

  @override
  Future<bool> isDriverBlocked(String driverId) async {
    try {
      final token = sharedPreferences.getString('auth_token');
      if (token == null) return false;

      final response = await dio.get(
        '$baseUrl/drivers/$driverId/status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['isBlocked'] ?? false;
      }
      return false;
    } catch (e) {
      throw AuthException('Failed to check driver status: ${e.toString()}');
    }
  }

  @override
  Future<bool> isDriverProfileComplete(String driverId) async {
    try {
      final token = sharedPreferences.getString('auth_token');
      if (token == null) return false;

      final response = await dio.get(
        '$baseUrl/drivers/$driverId/profile-status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['isComplete'] ?? false;
      }
      return false;
    } catch (e) {
      throw AuthException('Failed to check profile completeness: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel> updateDriverProfile(DriverModel driver) async {
    try {
      final token = sharedPreferences.getString('auth_token');
      if (token == null) {
        throw AuthException('User not authenticated');
      }

      final response = await dio.put(
        '$baseUrl/drivers/${driver.id}',
        data: driver.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return DriverModel.fromJson(response.data);
      } else {
        throw AuthException('Failed to update profile');
      }
    } catch (e) {
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      final token = sharedPreferences.getString('auth_token');
      if (token == null) {
        throw AuthException('User not authenticated');
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: 'profile.jpg'),
      });

      final response = await dio.post(
        '$baseUrl/upload/profile-image',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['imageUrl'];
      } else {
        throw AuthException('Failed to upload image');
      }
    } catch (e) {
      throw AuthException('Failed to upload image: ${e.toString()}');
    }
  }
}
