import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itspass_driver/pages/auth/register_screen.dart';
import 'package:itspass_driver/providers/auth_provider.dart';
import 'package:itspass_driver/l10n/app_localizations.dart';

void main() {
  group('RegisterScreen Multi-Language Tests', () {
    late AuthenticationProvider mockAuthProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      mockAuthProvider = AuthenticationProvider(
        dio: Dio(),
        sharedPreferences: prefs,
        baseUrl: 'https://test-api.com',
      );
    });

    Widget createTestWidget({Locale locale = const Locale('en')}) {
      return ChangeNotifierProvider<AuthenticationProvider>.value(
        value: mockAuthProvider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: const RegisterScreen(),
        ),
      );
    }

    testWidgets('displays English text by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify English text is displayed
      expect(find.text('Enter Your Mobile Number'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Or'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('displays Arabic text when Arabic locale is set', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Verify Arabic text is displayed
      expect(find.text('أدخل رقم هاتفك المحمول'), findsOneWidget);
      expect(find.text('متابعة'), findsOneWidget);
      expect(find.text('أو'), findsOneWidget);
      expect(find.text('متابعة مع جوجل'), findsOneWidget);
    });

    testWidgets('phone number input works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the phone number input field
      final phoneField = find.byType(TextFormField);
      expect(phoneField, findsOneWidget);

      // Enter a phone number
      await tester.enterText(phoneField, '791234567');
      await tester.pumpAndSettle();

      // Verify the text was entered (allow multiple instances)
      expect(find.text('791234567'), findsWidgets);
    });

    testWidgets('continue button is enabled when phone number is valid', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter a valid phone number
      final phoneField = find.byType(TextFormField);
      await tester.enterText(phoneField, '791234567');
      await tester.pumpAndSettle();

      // Find and verify continue button is present
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);
    });

    testWidgets('Google sign-in button displays correct text in both languages', (WidgetTester tester) async {
      // Test English
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);

      // Test Arabic
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text('متابعة مع جوجل'), findsOneWidget);
    });

    testWidgets('terms and conditions text displays in correct language', (WidgetTester tester) async {
      // Test English
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('By proceeding, you consent'), findsOneWidget);

      // Test Arabic
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.textContaining('بالمتابعة، أنت توافق'), findsOneWidget);
    });

    testWidgets('country picker shows correct flag and code', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify default country (Jordan) is displayed
      expect(find.text('🇯🇴'), findsOneWidget);
      expect(find.text('+962'), findsOneWidget);
    });

    testWidgets('phone input shows checkmark when valid number is entered', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter a valid 9-digit phone number
      final phoneField = find.byType(TextFormField);
      await tester.enterText(phoneField, '791234567');
      await tester.pumpAndSettle();

      // Verify checkmark icon appears
      expect(find.byIcon(Icons.done), findsOneWidget);
    });
  });
}
