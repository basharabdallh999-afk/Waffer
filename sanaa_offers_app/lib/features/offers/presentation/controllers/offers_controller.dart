import 'package:flutter/material.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/offer_entity.dart';
import '../../domain/usecases/get_offers_usecase.dart';

class OffersController extends ChangeNotifier {
  OffersController({required this.getOffersUseCase}) {
    // استعادة المفضلة المحفوظة محلياً
    _favoriteOfferIds = LocalStorageService.loadFavorites();
  }

  final GetOffersUseCase getOffersUseCase;

  // ─── State ────────────────────────────────────────────────────────────────

  List<OfferEntity> _offers = [];
  List<OfferEntity> get offers => _offers;

  List<OfferEntity> _bannerOffers = [];
  List<OfferEntity> get bannerOffers => _bannerOffers;

  late Set<int> _favoriteOfferIds;
  Set<int> get favoriteOfferIds => _favoriteOfferIds;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'الكل';
  String get selectedCategory => _selectedCategory;

  String _selectedStoreFilter = 'الكل';
  String get selectedStoreFilter => _selectedStoreFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ─── Pagination ───────────────────────────────────────────────────────────

  static const int _pageSize = 10;
  int _currentPage = 1;

  /// جلب الصفحة الأولى (يُعيد ضبط كل شيء)
  Future<void> loadOffers() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      final fetched = await getOffersUseCase(GetOffersParams(
        category: _selectedCategory,
        storeFilter: _selectedStoreFilter,
        searchQuery: _searchQuery,
        page: 1,
        limit: _pageSize,
      ));

      _offers = fetched;
      _hasMore = fetched.length >= _pageSize;

      _refreshBanners();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } on Failure catch (f) {
      AppLogger.w('Failed to load offers: ${f.message}');
      _errorMessage = f.message;
      _isLoading = false;
      notifyListeners();
    } catch (e, st) {
      AppLogger.e('Unexpected error loading offers', e, st);
      _errorMessage = 'حدث خطأ في الاتصال، يرجى المحاولة مجدداً';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب الصفحة التالية (Infinite Scroll)
  Future<void> loadMoreOffers() async {
    if (_isFetchingMore || !_hasMore || _isLoading) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final fetched = await getOffersUseCase(GetOffersParams(
        category: _selectedCategory,
        storeFilter: _selectedStoreFilter,
        searchQuery: _searchQuery,
        page: nextPage,
        limit: _pageSize,
      ));

      if (fetched.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        _offers = [..._offers, ...fetched];
        _hasMore = fetched.length >= _pageSize;
        _refreshBanners();
      }
    } catch (e) {
      AppLogger.w('Error loading more offers: $e');
      // لا نُظهر خطأ — نكتفي بإيقاف التحميل
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  void _refreshBanners() {
    _bannerOffers = _offers.where((o) => o.isFeaturedBanner).toList();
    if (_bannerOffers.isEmpty && _offers.isNotEmpty) {
      _bannerOffers = _offers.take(3).toList();
    }
  }

  // ─── Filters ──────────────────────────────────────────────────────────────

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    loadOffers();
  }

  void setStoreFilter(String storeFilter) {
    if (_selectedStoreFilter == storeFilter) return;
    _selectedStoreFilter = storeFilter;
    loadOffers();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    loadOffers();
  }

  // ─── Favorites (مع حفظ محلي) ─────────────────────────────────────────────

  void toggleFavorite(OfferEntity offer) {
    if (_favoriteOfferIds.contains(offer.id)) {
      _favoriteOfferIds.remove(offer.id);
    } else {
      _favoriteOfferIds.add(offer.id);
    }
    // حفظ فوري في SharedPreferences
    LocalStorageService.saveFavorites(_favoriteOfferIds);
    notifyListeners();
  }

  bool isFavorite(int offerId) => _favoriteOfferIds.contains(offerId);

  List<OfferEntity> get favoriteOffers =>
      _offers.where((o) => _favoriteOfferIds.contains(o.id)).toList();
}
