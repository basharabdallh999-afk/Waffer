import '../entities/offer_entity.dart';

abstract class OffersRepository {
  Future<List<OfferEntity>> getOffers({
    String? category,
    String? storeFilter,
    String? searchQuery,
    int page,
    int limit,
  });
  Future<List<OfferEntity>> getBannerOffers();
}
