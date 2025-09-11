import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uber_drivers_app/pages/auth/register_screen.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';
import 'package:uber_drivers_app/providers/dashboard_provider.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';
import 'package:uber_drivers_app/providers/trips_provider.dart';
import 'package:uber_drivers_app/injection/injection_container.dart' as di;
import 'package:uber_drivers_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uber_drivers_app/features/auth/presentation/widgets/auth_check_widget.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.configureDependencies();
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });
  await Permission.notification.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.notification.request();
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        // Keep existing providers for gradual migration
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthenticationProvider(
            dio: di.sl<Dio>(),
            sharedPreferences: di.sl<SharedPreferences>(),
            baseUrl: 'https://your-api-base-url.com/api',
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistrationProvider(
            dio: di.sl<Dio>(),
            sharedPreferences: di.sl<SharedPreferences>(),
            baseUrl: 'https://your-api-base-url.com/api',
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TripProvider(
            dio: di.sl<Dio>(),
            sharedPreferences: di.sl<SharedPreferences>(),
            baseUrl: 'https://your-api-base-url.com/api',
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Uber Drivers App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthCheckWidget(),
      ),
    );
  }
}

// Legacy AuthCheck widget - replaced by AuthCheckWidget with BLoC
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget is now deprecated - using AuthCheckWidget with BLoC instead
    return const RegisterScreen();
  }
}
