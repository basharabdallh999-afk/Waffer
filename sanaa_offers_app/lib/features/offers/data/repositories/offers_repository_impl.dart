import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/repositories/offers_repository.dart';
import '../datasources/offers_remote_datasource.dart';

class OffersRepositoryImpl implements OffersRepository {
  const OffersRepositoryImpl(this.remoteDataSource);
  final OffersRemoteDataSource remoteDataSource;

  @override
  Future<List<OfferEntity>> getOffers({
    String? category,
    String? storeFilter,
    String? searchQuery,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await remoteDataSource.getOffers(
        category: category,
        storeFilter: storeFilter,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
      );
    } on ServerException catch (e) {
      AppLogger.e('ServerException in getOffers', e);
      throw ServerFailure(e.message);
    } catch (e, st) {
      AppLogger.e('Unexpected exception in getOffers', e, st);
      throw const NetworkFailure('حدث خطأ أثناء جلب العروض، يرجى إعادة المحاولة');
    }
  }

  @override
  Future<List<OfferEntity>> getBannerOffers() async {
    try {
      return await remoteDataSource.getBannerOffers();
    } catch (e, st) {
      AppLogger.e('Unexpected exception in getBannerOffers', e, st);
      throw const NetworkFailure();
    }
  }
}
