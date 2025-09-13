import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itspass_driver/pages/driverRegistration/basic_info_screen.dart';
import 'package:itspass_driver/providers/registration_provider.dart';

void main() {
  group('DriverRegistration Widget Tests', () {
    late RegistrationProvider mockRegistrationProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final dio = Dio();
      
      mockRegistrationProvider = RegistrationProvider(
        dio: dio,
        sharedPreferences: sharedPreferences,
        baseUrl: 'https://test-api.com',
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<RegistrationProvider>(
          create: (_) => mockRegistrationProvider,
          child: const BasicInfoScreen(),
        ),
      );
    }

    testWidgets('should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should render without errors
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle basic interactions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should not cause errors during basic interactions
      expect(tester.takeException(), isNull);
    });
  });
}
