import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanaa_offers_app/core/services/local_storage_service.dart';
import 'package:sanaa_offers_app/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  testWidgets('shows the Waffer welcome screen with 3 tabs and guest access', (tester) async {
    await tester.pumpWidget(const WafferApp());
    await tester.pumpAndSettle();

    expect(find.text('Waffer'), findsOneWidget);
    expect(find.text('وفر'), findsOneWidget);
    expect(find.text('أفضل العروض في صنعاء'), findsOneWidget);

    // 3 Tabs
    expect(find.text('تسجيل دخول'), findsOneWidget);
    expect(find.text('حساب شخصي'), findsOneWidget);
    expect(find.text('حساب تاجر'), findsOneWidget);

    // Login Form Elements
    expect(find.text('دخول'), findsOneWidget);
    expect(find.text('الدخول كزائر'), findsOneWidget);
  });
}
