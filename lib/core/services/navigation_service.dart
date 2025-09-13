import 'package:flutter/material.dart';
import 'package:itspass_driver/authentication/login_screen.dart';
import '../services/secure_storage_service.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../../pages/dashboard.dart';
import '../../pages/registration/driver_registration_flow_screen.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get currentContext => navigatorKey.currentContext;

  // Navigate to appropriate screen based on authentication and registration status
  Future<void> navigateBasedOnAuthStatus() async {
    final context = currentContext;
    if (context == null) return;

    try {
      // Check if user is authenticated
      final isAuthenticated = await SecureStorageService.isAuthenticated();
      
      if (!isAuthenticated) {
        // User not authenticated, go to login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        return;
      }

      // User is authenticated, check registration and trip status
      await _navigateBasedOnDriverState();
      
    } catch (e) {
      // Error occurred, go to login for safety
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Navigate based on comprehensive driver state
  Future<void> _navigateBasedOnDriverState() async {
    final context = currentContext;
    if (context == null) return;

    try {
      final authService = AuthService();
      final driverService = DriverService();
      
      // Get driver profile and status
      final profileResponse = await authService.getCurrentDriverProfile();
      final statusResponse = await driverService.getDriverStatus();
      
      // Check if driver profile is complete
      final isProfileComplete = _isDriverProfileComplete(profileResponse);
      
      if (!isProfileComplete) {
        // Profile incomplete, go to registration flow
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DriverRegistrationFlowScreen()),
          (route) => false,
        );
        return;
      }

      // Check if driver has active trip
      if (statusResponse.success && statusResponse.data != null) {
        final driverStatus = statusResponse.data as Map<String, dynamic>;
        final hasActiveTrip = driverStatus['has_active_trip'] == true;
        final activeTripId = driverStatus['active_trip_id'];
        
        if (hasActiveTrip && activeTripId != null) {
          // For now, navigate to dashboard - active trip screen integration pending
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Dashboard()),
            (route) => false,
          );
          return;
        }
      }

      // Default: User authenticated and profile complete, go to dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (route) => false,
      );
      
    } catch (e) {
      // Fallback to dashboard on error
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (route) => false,
      );
    }
  }

  // Check if driver profile is complete
  bool _isDriverProfileComplete(Map<String, String?> profile) {
    final requiredFields = ['name', 'phone', 'email'];
    
    for (final field in requiredFields) {
      final value = profile[field];
      if (value == null || value.isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  // Navigate to login screen
  void navigateToLogin() {
    final context = currentContext;
    if (context == null) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Navigate to dashboard
  void navigateToDashboard() {
    final context = currentContext;
    if (context == null) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Dashboard()),
      (route) => false,
    );
  }

  // Navigate to registration flow
  void navigateToRegistration() {
    final context = currentContext;
    if (context == null) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DriverRegistrationFlowScreen()),
      (route) => false,
    );
  }

  // Handle logout navigation
  Future<void> handleLogout() async {
    await SecureStorageService.clearAuthData();
    navigateToLogin();
  }

  // Show error dialog
  void showErrorDialog(String title, String message) {
    final context = currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show loading dialog
  void showLoadingDialog(String message) {
    final context = currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  // Hide loading dialog
  void hideLoadingDialog() {
    final context = currentContext;
    if (context == null) return;
    
    Navigator.of(context, rootNavigator: true).pop();
  }
}
