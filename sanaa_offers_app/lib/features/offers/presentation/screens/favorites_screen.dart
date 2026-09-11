import 'package:flutter/material.dart';

import '../controllers/offers_controller.dart';
import '../widgets/offer_card.dart';
import '../widgets/offer_shimmer.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.offersController,
  });

  final OffersController offersController;

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: AnimatedBuilder(
          animation: offersController,
          builder: (_, __) {
            final count = offersController.favoriteOffers.length;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'المُفضلة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: primaryRed,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: offersController,
        builder: (context, child) {
          if (offersController.isLoading) {
            return const SimpleGridShimmer();
          }

          final favorites = offersController.favoriteOffers;

          if (favorites.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: offersController.loadOffers,
            color: primaryRed,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final offer = favorites[index];
                return OfferCard(
                  offer: offer,
                  isFavorite: true,
                  onToggleFavorite: () => offersController.toggleFavorite(offer),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة متحركة
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryRed.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 52,
                  color: primaryRed,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'قائمة المفضلة فارغة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'اضغط على ♥ في أي عرض لحفظه هنا\nوستجده في أي وقت حتى بعد إغلاق التطبيق',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: offersController.loadOffers,
              icon: const Icon(Icons.refresh_rounded, color: primaryRed),
              label: const Text(
                'تحديث العروض',
                style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
