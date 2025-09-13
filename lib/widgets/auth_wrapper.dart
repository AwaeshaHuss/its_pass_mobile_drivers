import 'package:flutter/material.dart';
import 'package:itspass_driver/authentication/login_screen.dart';
import '../core/services/secure_storage_service.dart';
import '../core/services/auth_service.dart';
import '../pages/auth/register_screen.dart';
import '../pages/dashboard.dart';
import '../widgets/loading_widget.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  Widget _targetScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    _determineInitialScreen();
  }

  Future<void> _determineInitialScreen() async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await SecureStorageService.isAuthenticated();
      
      if (!isAuthenticated) {
        // User not authenticated, show login
        setState(() {
          _targetScreen = const LoginScreen();
          _isLoading = false;
        });
        return;
      }

      // User is authenticated, check registration status
      final authService = AuthService();
      final profileResponse = await authService.getCurrentDriverProfile();
      
      // Check if driver profile is complete
      final isProfileComplete = _isDriverProfileComplete(profileResponse);
      
      if (!isProfileComplete) {
        // Profile incomplete, show registration flow
        setState(() {
          _targetScreen = const RegisterScreen();
          _isLoading = false;
        });
        return;
      }

      // User authenticated and profile complete, show dashboard
      setState(() {
        _targetScreen = const Dashboard();
        _isLoading = false;
      });
      
    } catch (e) {
      // Error occurred, show login for safety
      setState(() {
        _targetScreen = const LoginScreen();
        _isLoading = false;
      });
    }
  }

  // Check if driver profile is complete
  bool _isDriverProfileComplete(Map<String, String?> profile) {
    final requiredFields = ['name', 'phone'];
    
    for (final field in requiredFields) {
      final value = profile[field];
      if (value == null || value.isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: CustomLoadingWidget(
          message: 'Loading...',
        ),
      );
    }

    return _targetScreen;
  }
}
