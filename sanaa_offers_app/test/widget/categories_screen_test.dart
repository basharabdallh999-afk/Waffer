import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanaa_offers_app/core/services/local_storage_service.dart';
import 'package:sanaa_offers_app/features/offers/data/datasources/offers_remote_datasource.dart';
import 'package:sanaa_offers_app/features/offers/data/repositories/offers_repository_impl.dart';
import 'package:sanaa_offers_app/features/offers/domain/usecases/get_offers_usecase.dart';
import 'package:sanaa_offers_app/features/offers/presentation/controllers/offers_controller.dart';
import 'package:sanaa_offers_app/features/offers/presentation/screens/categories_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  testWidgets('CategoriesScreen displays Supermarket and Store chips', (tester) async {
    final repo = OffersRepositoryImpl(OffersRemoteDataSourceImpl());
    final controller = OffersController(getOffersUseCase: GetOffersUseCase(repo));

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CategoriesScreen(offersController: controller),
        ),
      ),
    );

    await tester.pump(); // Render UI

    expect(find.text('الأقسام والعروض'), findsOneWidget);
    expect(find.text('سوبر ماركت'), findsOneWidget);
    expect(find.text('متاجر'), findsOneWidget);
  });
}
