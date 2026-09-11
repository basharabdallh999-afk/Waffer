import 'package:flutter/material.dart';

import '../../../../core/widgets/error_retry_widget.dart';
import '../controllers/offers_controller.dart';
import '../widgets/offer_card.dart';
import '../widgets/offer_shimmer.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({
    super.key,
    required this.offersController,
  });

  final OffersController offersController;

  static const Color primaryRed = Color(0xFFB3241C);



  static const List<String> _storeFilters = ['الكل', 'سوبر ماركت', 'متاجر'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'الأقسام والعروض',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: offersController,
        builder: (context, child) {
          return Column(
            children: [


              // ─── فلتر نوع المتجر ─────────────────────────────────────
              Container(
                color: Colors.white,
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: _storeFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _storeFilters[index];
                    final isSelected = offersController.selectedStoreFilter == filter;
                    return GestureDetector(
                      onTap: () => offersController.setStoreFilter(filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryRed : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? primaryRed : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // ─── محتوى العروض ────────────────────────────────────────
              Expanded(
                child: offersController.isLoading
                    ? const SimpleGridShimmer()
                    : offersController.errorMessage != null &&
                            offersController.offers.isEmpty
                        ? ErrorRetryWidget(
                            message: offersController.errorMessage!,
                            onRetry: offersController.loadOffers,
                          )
                        : offersController.offers.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
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
                                  itemCount: offersController.offers.length,
                                  itemBuilder: (context, index) {
                                    final offer = offersController.offers[index];
                                    final isFav = offersController.isFavorite(offer.id);
                                    return OfferCard(
                                      offer: offer,
                                      isFavorite: isFav,
                                      onToggleFavorite: () =>
                                          offersController.toggleFavorite(offer),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد عروض في هذا القسم حالياً',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اختر قسم آخر أو عد لاحقاً لمتابعة العروض الجديدة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}


