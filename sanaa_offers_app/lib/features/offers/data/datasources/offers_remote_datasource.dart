import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/offer_entity.dart';

abstract class OffersRemoteDataSource {
  Future<List<OfferEntity>> getOffers({
    String? category,
    String? storeFilter,
    String? searchQuery,
    int page,
    int limit,
  });
  Future<List<OfferEntity>> getBannerOffers();
}

class OffersRemoteDataSourceImpl implements OffersRemoteDataSource {
  /// قائمة Mock Data الكاملة — مصدر بيانات الـ Fallback
  static final List<OfferEntity> _allMockOffers = _buildMockOffers();

  @override
  Future<List<OfferEntity>> getOffers({
    String? category,
    String? storeFilter,
    String? searchQuery,
    int page = 1,
    int limit = 10,
  }) async {
    AppLogger.d('Fetching offers: page=$page limit=$limit cat=$category store=$storeFilter q=$searchQuery');

    List<OfferEntity> list = [];

    // ─── محاولة الـ API الحقيقي ────────────────────────────────────────────
    try {
      final queryParams = {
        'page': '$page',
        'limit': '$limit',
        if (category != null && category != 'الكل') 'category': category,
        if (storeFilter != null && storeFilter != 'الكل') 'storeType': storeFilter,
        if (searchQuery != null && searchQuery.trim().isNotEmpty) 'search': searchQuery.trim(),
      };

      final uri = Uri.parse(ApiConstants.offersUrl).replace(queryParameters: queryParams);
      final res = await http.get(uri).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        // يدعم JSON مباشراً: [] أو { data: [], total: N }
        final rawList = decoded is List ? decoded : (decoded['data'] ?? decoded['offers'] ?? []) as List;

        if (rawList.isNotEmpty) {
          list = rawList.map((item) => _parseOffer(item)).toList();
          if (category != null && category != 'الكل') {
            if (category == 'سوبر ماركت' || category == 'متاجر') {
              list = list.where((o) => o.storeType == category).toList();
            } else {
              list = list.where((o) => o.category == category).toList();
            }
          }
          if (storeFilter != null && storeFilter != 'الكل') {
            list = list.where((o) => o.storeType == storeFilter).toList();
          }
          if (searchQuery != null && searchQuery.trim().isNotEmpty) {
            final q = searchQuery.trim().toLowerCase();
            list = list.where((o) =>
                o.title.toLowerCase().contains(q) ||
                o.storeName.toLowerCase().contains(q) ||
                o.description.toLowerCase().contains(q) ||
                o.category.toLowerCase().contains(q)).toList();
          }
          AppLogger.d('API returned ${list.length} filtered offers (page $page)');
          return list;
        }
      }
    } catch (e) {
      AppLogger.w('API unavailable, falling back to mock data: $e');
    }

    // ─── Fallback: Mock Data مع Pagination محلية ──────────────────────────
    list = List<OfferEntity>.from(_allMockOffers);

    // تطبيق الفلاتر على Mock Data
    if (category != null && category != 'الكل') {
      if (category == 'سوبر ماركت') {
        list = list.where((o) => o.storeType == 'سوبر ماركت').toList();
      } else if (category == 'متاجر') {
        list = list.where((o) => o.storeType == 'متاجر').toList();
      } else {
        list = list.where((o) => o.category == category).toList();
      }
    }

    if (storeFilter != null && storeFilter != 'الكل') {
      list = list.where((o) => o.storeType == storeFilter).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((o) =>
          o.title.toLowerCase().contains(q) ||
          o.storeName.toLowerCase().contains(q) ||
          o.description.toLowerCase().contains(q) ||
          o.category.toLowerCase().contains(q)).toList();
    }

    // تطبيق Pagination على Mock Data
    final start = (page - 1) * limit;
    if (start >= list.length) return [];
    return list.skip(start).take(limit).toList();
  }

  @override
  Future<List<OfferEntity>> getBannerOffers() async {
    final all = await getOffers(page: 1, limit: 20);
    final banners = all.where((o) => o.isFeaturedBanner).toList();
    return banners.isNotEmpty ? banners : all.take(3).toList();
  }

  // ─── Parser ───────────────────────────────────────────────────────────────

  OfferEntity _parseOffer(Map<String, dynamic> item) {
    final id = int.tryParse('${item['id'] ?? 0}') ?? 0;
    final title = '${item['title'] ?? 'عرض مميز'}';

    String storeName = 'متجر صنعاء';
    if (item['merchant'] != null && item['merchant']['storeName'] != null) {
      storeName = '${item['merchant']['storeName']}';
    } else if (item['storeName'] != null) {
      storeName = '${item['storeName']}';
    }

    String categoryName = 'عام';
    if (item['category'] != null && item['category']['name'] != null) {
      categoryName = '${item['category']['name']}';
    } else if (item['categoryName'] != null) {
      categoryName = '${item['categoryName']}';
    }

    final description = '${item['description'] ?? ''}';

    String rawImg = '${item['imageUrl'] ?? ''}'.trim();
    String imageUrl = '';
    if (rawImg.isNotEmpty) {
      if (rawImg.startsWith('http://') || rawImg.startsWith('https://')) {
        imageUrl = rawImg;
      } else {
        imageUrl = '${ApiConstants.baseUrl}/${rawImg.replaceAll(RegExp(r'^/+'), '')}';
      }
    }

    final double oldPrice = double.tryParse('${item['originalPrice'] ?? item['oldPrice'] ?? 0}') ?? 0;
    final double newPrice = double.tryParse('${item['discountedPrice'] ?? item['newPrice'] ?? 0}') ?? 0;
    final validUntil = DateTime.tryParse('${item['endDate'] ?? item['validUntil'] ?? ''}');
    final isFeaturedBanner = item['isFlashSale'] == true || item['isFeaturedBanner'] == true;
    final storeType = storeName.contains('سوبر') || storeName.contains('هايبر') ? 'سوبر ماركت' : 'متاجر';

    return OfferEntity(
      id: id,
      title: title,
      storeName: storeName,
      category: categoryName,
      description: description,
      imageUrl: imageUrl,
      oldPrice: oldPrice > 0 ? oldPrice : newPrice * 1.25,
      newPrice: newPrice,
      validUntil: validUntil,
      isFeaturedBanner: isFeaturedBanner,
      storeType: storeType,
    );
  }

  // ─── Mock Data ────────────────────────────────────────────────────────────

  static List<OfferEntity> _buildMockOffers() {
    final now = DateTime.now();
    return [
      OfferEntity(
        id: 101,
        title: 'عروض الجندول الأسبوعية - خصم يصل 40%',
        storeName: 'سوبر ماركت الجندول',
        category: 'مواد غذائية',
        description: 'أقوى تخفيضات الأسبوع على التمور، الأرز البسمتي، والزيوت النباتية في صنعاء.',
        imageUrl: 'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?w=900',
        oldPrice: 25000,
        newPrice: 14900,
        validUntil: now.add(const Duration(days: 7)),
        isFeaturedBanner: true,
        storeType: 'سوبر ماركت',
      ),
      OfferEntity(
        id: 102,
        title: 'مهرجان التوفير من هايبر صنعاء',
        storeName: 'هايبر صنعاء',
        category: 'ألبان',
        description: 'عروض حصرية على جميع منتجات الألبان والأجبان والعصائر الطبيعية.',
        imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=900',
        oldPrice: 12000,
        newPrice: 8500,
        validUntil: now.add(const Duration(days: 5)),
        isFeaturedBanner: true,
        storeType: 'سوبر ماركت',
      ),
      OfferEntity(
        id: 103,
        title: 'عروض التخفيض الكبرى - سوبر ماركت الوفاء',
        storeName: 'سوبر ماركت الوفاء',
        category: 'مواد غذائية',
        description: 'خصومات مميزة على السكر، الدقيق، الشاي، والمواد التموينية الأساسية.',
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=900',
        oldPrice: 18500,
        newPrice: 13900,
        validUntil: now.add(const Duration(days: 12)),
        isFeaturedBanner: true,
        storeType: 'سوبر ماركت',
      ),
      OfferEntity(
        id: 1,
        title: 'زيت دوار الشمس (2 لتر)',
        storeName: 'سوبر ماركت صنعاء',
        category: 'زيوت',
        description: 'زيت نباتي عالي الجودة وصحي للطهي والقلي اليومي.',
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=900',
        oldPrice: 3200,
        newPrice: 2500,
        validUntil: now.add(const Duration(days: 10)),
        isFeaturedBanner: false,
        storeType: 'سوبر ماركت',
      ),
      OfferEntity(
        id: 2,
        title: 'تشكيلة أجبان وألبان متكاملة',
        storeName: 'هايبر صنعاء',
        category: 'ألبان',
        description: 'عرض عائلي ممتاز للشركات والأسر وبأسعار تنافسية.',
        imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=900',
        oldPrice: 6000,
        newPrice: 4500,
        validUntil: now.add(const Duration(days: 4)),
        isFeaturedBanner: false,
        storeType: 'سوبر ماركت',
      ),
      OfferEntity(
        id: 3,
        title: 'حزمة العصائر الطازجة الطبيعية',
        storeName: 'محل البركة للمواد الغذائية',
        category: 'مشروبات',
        description: 'عصائر طازجة مشكلة 100% بدون إضافات حافظة.',
        imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=900',
        oldPrice: 4000,
        newPrice: 2900,
        validUntil: now.add(const Duration(days: 6)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
      OfferEntity(
        id: 4,
        title: 'سلة الخضار والفواكه الطازجة',
        storeName: 'مزرعة الخير',
        category: 'خضار وفواكه',
        description: 'تشكيلة متنوعة من تفاح، موز، طماطم، وخيار طازج يومياً.',
        imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=900',
        oldPrice: 8000,
        newPrice: 5800,
        validUntil: now.add(const Duration(days: 3)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
      OfferEntity(
        id: 5,
        title: 'عرض الشاشات الذكية HD',
        storeName: 'متجر الإلكترونيات الحديثة',
        category: 'إلكترونيات',
        description: 'شاشة 50 بوصة سمارت بدقة عالية مع ضمان سنتين.',
        imageUrl: 'https://images.unsplash.com/photo-1593784991095-a205069470b6?w=900',
        oldPrice: 150000,
        newPrice: 119000,
        validUntil: now.add(const Duration(days: 15)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
      OfferEntity(
        id: 6,
        title: 'عطر فاخر - تخفيض 30%',
        storeName: 'بيوتي سنتر',
        category: 'صحة وجمال',
        description: 'مجموعة منتخبة من أجود العطور العربية والأجنبية بخصم 30%.',
        imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683702?w=900',
        oldPrice: 8500,
        newPrice: 5950,
        validUntil: now.add(const Duration(days: 14)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
      OfferEntity(
        id: 7,
        title: 'وجبة عائلية كاملة بسعر خيالي',
        storeName: 'مطعم صنعاء الأصيل',
        category: 'مطاعم وكافيهات',
        description: 'استمتع بوجبة يمنية أصيلة لعائلة من 4 أفراد تشمل الكبسة والسلطات.',
        imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=900',
        oldPrice: 12000,
        newPrice: 7800,
        validUntil: now.add(const Duration(days: 3)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
      OfferEntity(
        id: 8,
        title: 'ملابس رياضية أديداس - خصم 25%',
        storeName: 'متجر الرياضة العصرية',
        category: 'ملابس وأزياء',
        description: 'تشكيلة واسعة من الملابس الرياضية لجميع الأعمار.',
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900',
        oldPrice: 22000,
        newPrice: 16500,
        validUntil: now.add(const Duration(days: 20)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
      OfferEntity(
        id: 9,
        title: 'طقم أثاث غرفة النوم الكامل',
        storeName: 'معرض الأثاث الراقي',
        category: 'أثاث ومفروشات',
        description: 'طقم غرفة نوم فاخر من خشب المدفن يشمل السرير والخزانة والتسريحة.',
        imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=900',
        oldPrice: 450000,
        newPrice: 350000,
        validUntil: now.add(const Duration(days: 30)),
        isFeaturedBanner: true,
        storeType: 'متاجر',
      ),
      OfferEntity(
        id: 10,
        title: 'أجهزة مطبخ متكاملة',
        storeName: 'متجر الكهربائيات',
        category: 'أجهزة كهربائية',
        description: 'طقم أجهزة مطبخ يشمل الخلاط والمحضرة والمكيفة بخصم 20%.',
        imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=900',
        oldPrice: 85000,
        newPrice: 68000,
        validUntil: now.add(const Duration(days: 8)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
      OfferEntity(
        id: 11,
        title: 'أرز بسمتي ممتاز (10 كيلو)',
        storeName: 'سوبر ماركت الجندول',
        category: 'مواد غذائية',
        description: 'أرز بسمتي طويل الحبة من أفضل المستوردات الهندية.',
        imageUrl: 'https://images.unsplash.com/photo-1536304993881-ff86e0c9b849?w=900',
        oldPrice: 9500,
        newPrice: 7200,
        validUntil: now.add(const Duration(days: 5)),
        isFeaturedBanner: false,
        storeType: 'سوبر ماركت',
      ),
      OfferEntity(
        id: 12,
        title: 'خدمة تنظيف المنازل المحترفة',
        storeName: 'شركة نظافة صنعاء',
        category: 'خدمات',
        description: 'تنظيف شامل للمنزل بمعدات حديثة ومواد صديقة للبيئة.',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=900',
        oldPrice: 15000,
        newPrice: 10000,
        validUntil: now.add(const Duration(days: 45)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
    ];
  }
}
