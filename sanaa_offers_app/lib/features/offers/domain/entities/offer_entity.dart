class OfferEntity {
  const OfferEntity({
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
    this.storeType = 'سوبر ماركت', // 'سوبر ماركت' or 'متاجر'
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
  final String storeType;

  int get discountPercent => oldPrice <= 0
      ? 0
      : ((oldPrice - newPrice) / oldPrice * 100).round();
}
