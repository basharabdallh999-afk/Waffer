import '../../../../core/usecases/usecase.dart';
import '../entities/offer_entity.dart';
import '../repositories/offers_repository.dart';

class GetOffersParams {
  const GetOffersParams({
    this.category,
    this.storeFilter,
    this.searchQuery,
    this.page = 1,
    this.limit = 10,
  });

  final String? category;
  final String? storeFilter;
  final String? searchQuery;
  final int page;
  final int limit;
}

class GetOffersUseCase implements UseCase<List<OfferEntity>, GetOffersParams> {
  const GetOffersUseCase(this.repository);
  final OffersRepository repository;

  @override
  Future<List<OfferEntity>> call(GetOffersParams params) {
    return repository.getOffers(
      category: params.category,
      storeFilter: params.storeFilter,
      searchQuery: params.searchQuery,
      page: params.page,
      limit: params.limit,
    );
  }
}
