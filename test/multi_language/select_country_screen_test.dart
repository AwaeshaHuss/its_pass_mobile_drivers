import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itspass_driver/pages/onboarding/select_country_screen.dart';
import 'package:itspass_driver/l10n/app_localizations.dart';

void main() {
  group('SelectCountryScreen Multi-Language Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('displays English text by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SelectCountryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify English text is displayed (allow multiple instances)
      expect(find.text('Select Country & Language'), findsWidgets);
      expect(find.text('Jordan'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Save & Continue'), findsOneWidget);
    });

    testWidgets('displays Arabic text when Arabic locale is set', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'selectedCountryCode': 'JO',
        'selectedLanguageCode': 'ar',
      });
      
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ar'),
          home: SelectCountryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Arabic text is displayed (allow multiple instances)
      expect(find.text('اختر البلد واللغة'), findsWidgets);
      expect(find.text('الأردن'), findsOneWidget);
      expect(find.text('حفظ ومتابعة'), findsOneWidget);
    });

    testWidgets('country selection card exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SelectCountryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify country selection card exists
      expect(find.byType(InkWell), findsWidgets);
      expect(find.text('Jordan'), findsOneWidget);
    });

    testWidgets('language selection card exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SelectCountryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify language selection card exists
      expect(find.byType(InkWell), findsWidgets);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('displays country names in English locale', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SelectCountryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify English country name is displayed
      expect(find.text('Jordan'), findsOneWidget);
    });

    testWidgets('displays language names in correct language', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SelectCountryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify default language display shows English
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('save button displays correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SelectCountryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify save button text
      expect(find.text('Save & Continue'), findsOneWidget);
    });
  });
}
