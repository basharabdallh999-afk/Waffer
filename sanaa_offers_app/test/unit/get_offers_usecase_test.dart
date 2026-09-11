import 'package:flutter_test/flutter_test.dart';
import 'package:sanaa_offers_app/features/offers/data/datasources/offers_remote_datasource.dart';
import 'package:sanaa_offers_app/features/offers/data/repositories/offers_repository_impl.dart';
import 'package:sanaa_offers_app/features/offers/domain/usecases/get_offers_usecase.dart';

void main() {
  group('GetOffersUseCase Tests', () {
    late GetOffersUseCase useCase;
    late OffersRepositoryImpl repository;

    setUp(() {
      repository = OffersRepositoryImpl(OffersRemoteDataSourceImpl());
      useCase = GetOffersUseCase(repository);
    });

    test('fetches offers successfully with supermarket category filter', () async {
      final result = await useCase(const GetOffersParams(storeFilter: 'سوبر ماركت'));
      expect(result, isNotEmpty);
      expect(result.every((o) => o.storeType == 'سوبر ماركت'), isTrue);
    });

    test('fetches offers successfully with store category filter', () async {
      final result = await useCase(const GetOffersParams(storeFilter: 'متاجر'));
      expect(result, isNotEmpty);
      expect(result.every((o) => o.storeType == 'متاجر'), isTrue);
    });
  });
}
