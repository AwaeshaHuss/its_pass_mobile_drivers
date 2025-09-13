import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itspass_driver/models/driver.dart';
import '../methods/common_method.dart';
import '../pages/auth/otp_screen.dart';
import '../core/services/auth_service.dart';
import '../core/services/secure_storage_service.dart';
import '../core/utils/app_logger.dart';

class AuthenticationProvider extends ChangeNotifier {
  final Dio dio;
  final SharedPreferences sharedPreferences;
  final String baseUrl;
  
  CommonMethods commonMethods = CommonMethods();
  bool _isLoading = false;
  bool _isSuccessful = false;
  bool _isGoogleSignedIn = false;
  bool _isGoogleSignInLoading = false;
  bool _isLoggedIn = false;
  String? _uid;
  String? _phoneNumber;
  String? _verificationId;
  String _driverAvailabilityStatus = "Offline";

  Driver? _driverModel;
  
  // Google Sign-In instance
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Driver info variables
  String driverName = "";
  String driverPhone = "";
  String driverEmail = "";
  String driverPhoto = "";
  String carModel = "";
  String carColor = "";
  String carNumber = "";

  AuthenticationProvider({
    required this.dio,
    required this.sharedPreferences,
    required this.baseUrl,
  }) {
    _initializeProvider();
  }

  Driver get driverModel => _driverModel!;

  String? get uid => _uid;
  String get phoneNumber => _phoneNumber ?? '';
  bool get isLoggedIn => _isLoggedIn;
  String get driverAvailabilityStatus => _driverAvailabilityStatus;
  bool get isSuccessful => _isSuccessful;
  bool get isLoading => _isLoading;
  bool get isGoogleSignedIn => _isGoogleSignedIn;
  bool get isGoogleSigInLoading => _isGoogleSignInLoading;

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void startGoogleLoading() {
    _isGoogleSignInLoading = true;
    notifyListeners();
  }

  void stopGoogleLoading() {
    _isGoogleSignInLoading = false;
    notifyListeners();
  }

  // Sign in user with phone
  void signInWithPhone({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    startLoading();

    try {
      // TODO: Replace with API call to send OTP
      final response = await dio.post(
        '$baseUrl/auth/send-otp',
        data: {'phoneNumber': phoneNumber},
      );
      
      if (response.statusCode == 200) {
        _phoneNumber = phoneNumber;
        _verificationId = response.data['verificationId'] ?? 'temp-verification-id';
        stopLoading();
        notifyListeners();
        
        // Navigate to the OTP screen
        Future.delayed(const Duration(seconds: 1)).whenComplete(() {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: _verificationId ?? '',
                ),
              ),
            );
          }
        });
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      stopLoading();
      if (context.mounted) {
        commonMethods.displaySnackBar(e.toString(), context);
      }
    }
  }

  Future<void> verifyOTP({
    required String otp,
    required BuildContext context,
  }) async {
    startLoading();
    try {
      final response = await dio.post(
        '$baseUrl/auth/verify-otp',
        data: {
          'verificationId': _verificationId,
          'otp': otp,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        await sharedPreferences.setString('auth_token', data['token']);
        await sharedPreferences.setString('driver_id', data['driver']['id']);
        await sharedPreferences.setString('driver_phone', _phoneNumber ?? '');
        _isLoggedIn = true;
        _uid = data['driver']['id'];
      } else {
        throw Exception('OTP verification failed');
      }
      
      stopLoading();
      notifyListeners();
    } catch (e) {
      stopLoading();
      AppLogger.error("Error during OTP verification", e);
      throw Exception(e.toString());
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    startLoading();
    try {
      final authService = AuthService();
      final response = await authService.login(
        username: email, // Using email as username
        password: password,
      );
      
      if (response.isSuccess) {
        _isLoggedIn = true;
        
        // Get stored user info from secure storage
        final userId = await SecureStorageService.getUserId();
        _uid = userId;
        driverEmail = email;
        
        // Load driver data
        await retrieveCurrentDriverInfo();
      } else {
        throw Exception(response.error ?? 'Login failed');
      }
      
      stopLoading();
      notifyListeners();
    } catch (e) {
      stopLoading();
      AppLogger.error("Error during login", e);
      throw Exception(e.toString());
    }
  }

  Future<void> checkIfUserIsLoggedIn() async {
    try {
      final token = await SecureStorageService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        _isLoggedIn = true;
        _phoneNumber = await SecureStorageService.getDriverProfile().then((profile) => profile['phone'] ?? '');
        _uid = await SecureStorageService.getUserId();
        notifyListeners();
      } else {
        _isLoggedIn = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<void> checkDriverAvailabilityStatus() async {
    try {
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId != null) {
        final token = sharedPreferences.getString('auth_token');
        final response = await dio.get(
          '$baseUrl/drivers/$driverId/status',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
        
        if (response.statusCode == 200) {
          final data = response.data;
          _driverAvailabilityStatus = data['isOnline'] ? "Online" : "Offline";
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger.error("Error checking driver availability", e);
    }
  }

  Future<void> updateDriverAvailabilityStatus(String status) async {
    try {
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId != null) {
        final token = sharedPreferences.getString('auth_token');
        final response = await dio.put(
          '$baseUrl/drivers/$driverId/status',
          data: {'status': status, 'isOnline': status == 'waiting'},
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
        
        if (response.statusCode == 200) {
          _driverAvailabilityStatus = status == "waiting" ? "Online" : "Offline";
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger.error("Error updating driver availability", e);
    }
  }

  Future<void> retrieveCurrentDriverInfo() async {
    try {
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId != null) {
        final token = sharedPreferences.getString('auth_token');
        final response = await dio.get(
          '$baseUrl/drivers/$driverId',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
        
        if (response.statusCode == 200) {
          final data = response.data;
          final nameParts = (data['name'] ?? '').split(' ');
          driverName = nameParts.isNotEmpty ? nameParts[0] : '';
          driverPhone = data['phone'] ?? '';
          driverEmail = data['email'] ?? '';
          driverPhoto = data['profileImageUrl'] ?? '';
          carModel = data['vehicle']?['make'] ?? '';
          carColor = data['vehicle']?['color'] ?? '';
          carNumber = data['vehicle']?['licensePlate'] ?? '';
          
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger.error("Error retrieving driver info", e);
    }
  }

  // Google Sign-In method
  Future<void> signInWithGoogle(
      BuildContext context, VoidCallback onSuccess) async {
    startGoogleLoading();
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        stopGoogleLoading();
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // TODO: Send Google credentials to API for authentication
      final response = await dio.post(
        '$baseUrl/auth/google-signin',
        data: {
          'idToken': googleAuth.idToken,
          'accessToken': googleAuth.accessToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await sharedPreferences.setString('auth_token', data['token']);
        await sharedPreferences.setString('driver_id', data['driver']['id']);
        await sharedPreferences.setString('driver_email', googleUser.email);
        
        _isGoogleSignedIn = true;
        _isLoggedIn = true;
        _uid = data['driver']['id'];
        driverEmail = googleUser.email;
        driverName = googleUser.displayName ?? '';
        driverPhoto = googleUser.photoUrl ?? '';
        
        notifyListeners();
        onSuccess();
      }

      stopGoogleLoading();
    } catch (e) {
      stopGoogleLoading();
      commonMethods.displaySnackBar(
          "Failed to sign in with Google: ${e.toString()}", context);
    }
  }

  Future<void> signOut() async {
    try {
      final authService = AuthService();
      await authService.logout();
      
      _isLoggedIn = false;
      _isGoogleSignedIn = false;
      _phoneNumber = '';
      _verificationId = null;
      _uid = null;
      notifyListeners();
    } catch (e) {
      AppLogger.error("Error signing out: $e");
    }
  }

  // Sign out method with navigation
  Future<void> signOutWithNavigation(BuildContext context) async {
    startLoading();
    try {
      await signOut();
      await googleSignIn.signOut();

      if (context.mounted) {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, "/dashboard", (route) => false);
        }
      }

      stopLoading();
    } catch (e) {
      stopLoading();
      if (context.mounted) {
        commonMethods.displaySnackBar("Signup successful! Please verify your phone number.", context);
      }
    }
  }

  Future<bool> checkIfDriverIsBlocked() async {
    try {
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId != null) {
        final token = sharedPreferences.getString('auth_token');
        final response = await dio.get(
          '$baseUrl/drivers/$driverId/status',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
        
        if (response.statusCode == 200) {
          return response.data['exists'] ?? false;
        }
      }
      return false;
    } catch (e) {
      AppLogger.error("Error checking driver block status", e);
      return false;
    }
  }

  Future<bool> checkIfDriverFieldsAreComplete() async {
    try {
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId != null) {
        final token = sharedPreferences.getString('auth_token');
        final response = await dio.get(
          '$baseUrl/drivers/$driverId',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
        
        if (response.statusCode == 200) {
          final data = response.data;
          // Check if all required fields are present and not empty
          return data['name'] != null && 
                 data['phone'] != null && 
                 data['email'] != null &&
                 data['vehicle'] != null &&
                 data['vehicle']['make'] != null &&
                 data['vehicle']['licensePlate'] != null;
        }
      }
      return false;
    } catch (e) {
      AppLogger.error("Error checking driver completeness", e);
      return false;
    }
  }

  // Legacy method names for compatibility with existing UI screens
  Future<bool> checkUserExistById() async {
    return await checkIfDriverFieldsAreComplete();
  }

  Future<bool> checkUserExistByEmail(String email) async {
    try {
      final response = await dio.get(
        '$baseUrl/drivers/check-email',
        queryParameters: {'email': email},
        options: Options(
          headers: {'Authorization': 'Bearer ${sharedPreferences.getString('auth_token')}'},
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data['exists'] ?? false;
      }
      return false;
    } catch (e) {
      AppLogger.error("Error checking user by email: $e");
      return false;
    }
  }

  Future<void> getUserDataFromFirebaseDatabase() async {
    await retrieveCurrentDriverInfo();
  }

  Future<bool> checkDriverFieldsFilled() async {
    return await checkIfDriverFieldsAreComplete();
  }

  Future<void> _initializeProvider() async {
    await checkIfUserIsLoggedIn();
  }
}
