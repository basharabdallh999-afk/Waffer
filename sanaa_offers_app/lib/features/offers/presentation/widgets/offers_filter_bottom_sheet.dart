import 'package:flutter/material.dart';
import '../controllers/offers_controller.dart';

class OffersFilterBottomSheet extends StatefulWidget {
  const OffersFilterBottomSheet({
    super.key,
    required this.offersController,
  });

  final OffersController offersController;

  static const Color primaryRed = Color(0xFFB3241C);

  static Future<void> show(
    BuildContext context, {
    required OffersController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OffersFilterBottomSheet(offersController: controller),
    );
  }

  @override
  State<OffersFilterBottomSheet> createState() =>
      _OffersFilterBottomSheetState();
}

class _OffersFilterBottomSheetState extends State<OffersFilterBottomSheet> {
  late String _selectedStore;
  late String _selectedCategory;
  String _selectedSort = 'الأحدث';

  final List<String> _sortOptions = [
    'الأحدث',
    'الأعلى خصماً',
    'الأقل سعراً',
    'الأعلى سعراً',
  ];

  final List<String> _categories = [
    'الكل',
    'سوبر ماركت',
    'مطاعم وكافيهات',
    'أجهزة وإلكترونيات',
    'أزياء وملابس',
    'صيدليات ومستلزمات',
  ];

  final List<String> _stores = [
    'الكل',
    'سوبر ماركت',
    'متاجر',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStore = widget.offersController.selectedStoreFilter;
    _selectedCategory = widget.offersController.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Drag Handle ─────────────────────────────────────────────────
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Header ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: OffersFilterBottomSheet.primaryRed
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: OffersFilterBottomSheet.primaryRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'تصفية وفرز العروض',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStore = 'الكل';
                    _selectedCategory = 'الكل';
                    _selectedSort = 'الأحدث';
                  });
                },
                child: const Text(
                  'إعادة ضبط',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ─── Section 1: Type of Store ────────────────────────────────────
          const Text(
            'نوع المتجر',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _stores.map((s) {
              final isSel = _selectedStore == s;
              return ChoiceChip(
                label: Text(s),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _selectedStore = s);
                },
                selectedColor: OffersFilterBottomSheet.primaryRed,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : Colors.black87,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSel
                        ? OffersFilterBottomSheet.primaryRed
                        : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // ─── Section 2: Category ─────────────────────────────────────────
          const Text(
            'القسم أو التصنيف',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((c) {
              final isSel = _selectedCategory == c;
              return ChoiceChip(
                label: Text(c),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _selectedCategory = c);
                },
                selectedColor: OffersFilterBottomSheet.primaryRed,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : Colors.black87,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSel
                        ? OffersFilterBottomSheet.primaryRed
                        : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // ─── Section 3: Sort Options ─────────────────────────────────────
          const Text(
            'ترتيب حسب',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _sortOptions.map((sort) {
              final isSel = _selectedSort == sort;
              return ChoiceChip(
                label: Text(sort),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _selectedSort = sort);
                },
                selectedColor: Colors.black87,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : Colors.black87,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ─── Action Button ───────────────────────────────────────────────
          ElevatedButton(
            onPressed: () {
              widget.offersController.setStoreFilter(_selectedStore);
              widget.offersController.setCategory(_selectedCategory);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: OffersFilterBottomSheet.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'تطبيق الفلترة والترتيب',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
