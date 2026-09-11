class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.storeName,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.oldPrice,
    required this.newPrice,
    required this.validUntil,
    this.isFeaturedBanner = false,
    this.storeType = 'سوبر ماركت',
  });

  final int id;
  final String title;
  final String storeName;
  final String category;
  final String description;
  final String imageUrl;
  final double oldPrice;
  final double newPrice;
  final DateTime? validUntil;
  final bool isFeaturedBanner;
  final String storeType; // 'سوبر ماركت' or 'متاجر'

  int get discountPercent => oldPrice <= 0
      ? 0
      : ((oldPrice - newPrice) / oldPrice * 100).round();

  factory Offer.fromJson(Map<String, dynamic> json) {
    double number(dynamic value) => double.tryParse('$value') ?? 0;
    return Offer(
      id: int.tryParse('${json['id'] ?? json['offerId'] ?? 0}') ?? 0,
      title: '${json['title'] ?? json['name'] ?? 'عرض مميز'}',
      storeName: '${json['storeName'] ?? json['store'] ?? 'متجر محلي'}',
      category: '${json['category'] ?? 'مواد غذائية'}',
      description: '${json['description'] ?? 'استفد من هذا العرض المميز لفترة محدودة.'}',
      imageUrl: '${json['imageUrl'] ?? json['image'] ?? ''}',
      oldPrice: number(json['oldPrice'] ?? json['priceBefore']),
      newPrice: number(json['newPrice'] ?? json['price']),
      validUntil: DateTime.tryParse('${json['validUntil'] ?? ''}'),
      isFeaturedBanner: json['isFeaturedBanner'] == true,
      storeType: '${json['storeType'] ?? 'سوبر ماركت'}',
    );
  }
}