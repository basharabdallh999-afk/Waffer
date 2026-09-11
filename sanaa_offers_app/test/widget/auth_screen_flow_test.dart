import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanaa_offers_app/core/services/local_storage_service.dart';
import 'package:sanaa_offers_app/features/auth/presentation/screens/auth_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  Widget createAuthWidget({int initialTab = 0}) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: AuthScreen(initialTabIndex: initialTab),
      ),
    );
  }

  group('AuthScreen 3-Tab Tests', () {
    testWidgets('renders Tab 0 (تسجيل دخول) by default', (tester) async {
      await tester.pumpWidget(createAuthWidget(initialTab: 0));
      await tester.pumpAndSettle();

      expect(find.text('Waffer'), findsOneWidget);
      expect(find.text('وفر'), findsOneWidget);
      expect(find.text('أفضل العروض في صنعاء'), findsOneWidget);

      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('دخول'), findsOneWidget);
      expect(find.text('الدخول كزائر'), findsOneWidget);
    });

    testWidgets('switches to Tab 1 (حساب شخصي) on tap', (tester) async {
      await tester.pumpWidget(createAuthWidget(initialTab: 0));
      await tester.pumpAndSettle();

      // Tap on حساب شخصي tab
      await tester.tap(find.text('حساب شخصي'));
      await tester.pumpAndSettle();

      expect(find.text('الاسم الكامل'), findsOneWidget);
      expect(find.text('إنشاء حساب شخصي'), findsOneWidget);
    });

    testWidgets('switches to Tab 2 (حساب تاجر) on tap', (tester) async {
      await tester.pumpWidget(createAuthWidget(initialTab: 0));
      await tester.pumpAndSettle();

      // Tap on حساب تاجر tab
      await tester.tap(find.text('حساب تاجر'));
      await tester.pumpAndSettle();

      expect(find.text('اسم المتجر'), findsOneWidget);
      expect(find.text('البريد الإلكتروني للمتجر'), findsOneWidget);
      expect(find.text('إنشاء حساب تاجر'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(createAuthWidget(initialTab: 0));
      await tester.pumpAndSettle();

      final toggleButton = find.byType(IconButton);
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
