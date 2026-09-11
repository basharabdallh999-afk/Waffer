import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/auth_response.dart';
import '../models/offer.dart';
import '../models/user.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: '',
        );

  final http.Client _client;
  final String baseUrl;

  Future<AuthResponse> login(String email, String password) async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));
      return const AuthResponse(token: 'demo-token', userName: 'مستخدم وفر');
    }
    final json = await _request('POST', '/api/auth/login', body: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(json);
  }

  Future<UserModel> registerPersonal(
      String name, String email, String password) async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));
      return UserModel(
        name: name,
        email: email,
        isMerchant: false,
      );
    }
    final json = await _request('POST', '/api/auth/register-personal', body: {
      'name': name,
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(json);
  }

  Future<UserModel> registerMerchant(
      String storeName, String email, String password) async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));
      return UserModel(
        name: storeName,
        email: email,
        isMerchant: true,
        storeName: storeName,
      );
    }
    final json = await _request('POST', '/api/auth/register-merchant', body: {
      'storeName': storeName,
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(json);
  }

  Future<List<Offer>> fetchOffers({
    String? category,
    String? storeFilter,
    String? searchQuery,
  }) async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 400));
      var list = _getDemoOffers();

      if (category != null && category != 'الكل') {
        list = list.where((o) => o.category == category).toList();
      }

      if (storeFilter != null && storeFilter != 'الكل') {
        list = list.where((o) => o.storeType == storeFilter).toList();
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list
            .where((o) =>
                o.title.toLowerCase().contains(q) ||
                o.storeName.toLowerCase().contains(q) ||
                o.description.toLowerCase().contains(q))
            .toList();
      }

      return list;
    }

    final queryParams = <String>[];
    if (category != null && category != 'الكل') {
      queryParams.add('category=${Uri.encodeQueryComponent(category)}');
    }
    if (storeFilter != null && storeFilter != 'الكل') {
      queryParams.add('storeFilter=${Uri.encodeQueryComponent(storeFilter)}');
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams.add('q=${Uri.encodeQueryComponent(searchQuery)}');
    }

    final queryStr = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final path = '/api/offers$queryStr';
    final payload = await _request('GET', path);
    final items =
        payload['items'] ?? payload['data'] ?? payload['offers'] ?? payload;
    if (items is! List) throw const ApiException('صيغة بيانات العروض غير صحيحة');
    return items
        .whereType<Map>()
        .map((item) => Offer.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Offer>> fetchBannerOffers() async {
    final all = await fetchOffers();
    return all.where((o) => o.isFeaturedBanner).toList();
  }

  Future<Map<String, dynamic>> _request(String method, String path,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}$path');
    final response = method == 'GET'
        ? await _client.get(uri)
        : await _client.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('تعذر الاتصال بالخادم (${response.statusCode})',
          statusCode: response.statusCode);
    }
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
  }

  List<Offer> _getDemoOffers() {
    return [
      Offer(
        id: 101,
        title: 'عروض الجندول الأسبوعية - خصم يصل 40%',
        storeName: 'سوبر ماركت الجندول',
        category: 'مواد غذائية',
        description: 'أقوى تخفيضات الأسبوع على التمور، الأرز، والزيوت من الجندول.',
        imageUrl: 'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?w=900',
        oldPrice: 25000,
        newPrice: 14900,
        validUntil: DateTime.now().add(const Duration(days: 7)),
        isFeaturedBanner: true,
        storeType: 'سوبر ماركت',
      ),
      Offer(
        id: 102,
        title: 'مهرجان التوفير من هايبر صنعاء',
        storeName: 'هايبر صنعاء',
        category: 'ألبان',
        description: 'عروض حصرية على جميع منتجات الألبان والأجبان والعصائر.',
        imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=900',
        oldPrice: 12000,
        newPrice: 8500,
        validUntil: DateTime.now().add(const Duration(days: 5)),
        isFeaturedBanner: true,
        storeType: 'سوبر ماركت',
      ),
      Offer(
        id: 1,
        title: 'سلة رمضان العائلية',
        storeName: 'متجر الوفاء',
        category: 'مواد غذائية',
        description: 'اختيارات أساسية للعائلة تشمل السكر، الدقيق، والزيت بسعر مميز.',
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=900',
        oldPrice: 18500,
        newPrice: 13900,
        validUntil: DateTime.now().add(const Duration(days: 12)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
      Offer(
        id: 2,
        title: 'زيت دوار الشمس (2 لتر)',
        storeName: 'سوبر ماركت صنعاء',
        category: 'زيوت',
        description: 'زيت نباتي عالي الجودة وصحي للطهي والقلي اليومي.',
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=900',
        oldPrice: 3200,
        newPrice: 2500,
        validUntil: DateTime.now().add(const Duration(days: 10)),
        isFeaturedBanner: false,
        storeType: 'سوبر ماركت',
      ),
      Offer(
        id: 3,
        title: 'تشكيلة أجبان وألبان متكاملة',
        storeName: 'هايبر صنعاء',
        category: 'ألبان',
        description: 'عرض عائلي ممتاز للشركات والأسر وبأسعار تنافسية.',
        imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=900',
        oldPrice: 6000,
        newPrice: 4500,
        validUntil: DateTime.now().add(const Duration(days: 4)),
        isFeaturedBanner: false,
        storeType: 'سوبر ماركت',
      ),
      Offer(
        id: 4,
        title: 'حزمة العصائر الطازجة الطبيعية',
        storeName: 'محل البركة',
        category: 'حلويات',
        description: 'عصائر طازجة مشكلة 100% بدون إضافات حافظة.',
        imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=900',
        oldPrice: 4000,
        newPrice: 2900,
        validUntil: DateTime.now().add(const Duration(days: 6)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
      Offer(
        id: 5,
        title: 'سلة الخضار والفواكه الطازجة',
        storeName: 'مزرعة الخير',
        category: 'خضار وفواكه',
        description: 'تشكيلة متنوعة من تفاح، موز، طماطم، وخيار طازج يومياً.',
        imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=900',
        oldPrice: 8000,
        newPrice: 5800,
        validUntil: DateTime.now().add(const Duration(days: 3)),
        isFeaturedBanner: false,
        storeType: 'متاجر',
      ),
    ];
  }
}