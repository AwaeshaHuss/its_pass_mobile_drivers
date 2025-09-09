import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../pages/auth/register_screen.dart';
import '../../../../pages/dashboard.dart';
import '../../../../widgets/blocked_screen.dart';
import '../bloc/auth_bloc.dart';

class AuthCheckWidget extends StatelessWidget {
  const AuthCheckWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
