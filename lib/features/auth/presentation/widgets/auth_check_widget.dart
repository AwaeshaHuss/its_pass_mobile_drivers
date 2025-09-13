import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../pages/auth/register_screen.dart';
import '../../../../pages/dashboard.dart';
import '../../../../pages/onboarding/select_country_screen.dart';
import '../../../../widgets/blocked_screen.dart';
import '../bloc/auth_bloc.dart';

class AuthCheckWidget extends StatefulWidget {
  const AuthCheckWidget({super.key});

  @override
  State<AuthCheckWidget> createState() => _AuthCheckWidgetState();
}

class _AuthCheckWidgetState extends State<AuthCheckWidget> {
  bool _hasSelectedCountry = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCountrySelection();
  }

  _checkCountrySelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCountry = prefs.getString('selectedCountry');
    bool hasSelectedCountry = savedCountry != null;
    
    // Debug logging
    AppLogger.info('DEBUG: Saved country: $savedCountry');
    AppLogger.info('DEBUG: Has selected country: $hasSelectedCountry');
    
    setState(() {
      _hasSelectedCountry = hasSelectedCountry;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.info('DEBUG: Building AuthCheckWidget - isLoading: $_isLoading, hasSelectedCountry: $_hasSelectedCountry');
    
    if (_isLoading) {
      AppLogger.info('DEBUG: Showing loading screen');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      );
    }

    if (!_hasSelectedCountry) {
      AppLogger.info('DEBUG: Showing SelectCountryScreen');
      return const SelectCountryScreen();
    }

    AppLogger.info('DEBUG: Showing BlocBuilder for auth');
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
          );
        }

        if (state is AuthUnauthenticated) {
          return const RegisterScreen();
        }

        if (state is AuthAuthenticated) {
          if (state.isBlocked) {
            return const BlockedScreen();
          }
          
          if (!state.isProfileComplete) {
            return const RegisterScreen();
          }
          
          return const Dashboard();
        }

        if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthCheckRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Fallback to register screen
        return const RegisterScreen();
      },
    );
  }
}
