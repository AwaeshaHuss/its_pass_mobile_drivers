import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itspass_driver/pages/auth/register_screen.dart';
import 'package:itspass_driver/providers/auth_provider.dart';
import 'package:itspass_driver/providers/dashboard_provider.dart';
import 'package:itspass_driver/providers/registration_provider.dart';
import 'package:itspass_driver/providers/trips_provider.dart';
import 'package:itspass_driver/injection/injection_container.dart' as di;
import 'package:itspass_driver/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:itspass_driver/features/auth/presentation/widgets/auth_check_widget.dart';
import 'package:itspass_driver/l10n/app_localizations.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.restartApp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguageCode');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void restartApp() {
    setState(() {
      _locale = null;
    });
    _loadLocale();
  }

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
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone 11 Pro design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'itspass_driver',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: _locale,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const AuthCheckWidget(),
            routes: {
              '/register': (context) => const RegisterScreen(),
            },
          );
        },
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
