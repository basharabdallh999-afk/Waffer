import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

import '../../../../core/utils/api_constants.dart';
import '../../../navigation/presentation/screens/main_navigation_screen.dart';
import 'welcome_screen.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({
    super.key,
    required this.merchantName,
    required this.storeName,
    this.merchantId,
    this.userId,
    this.isApproved = false,
    this.isSuspended = false,
    this.suspensionReason,
    this.suspendedUntil,
  });

  final String merchantName;
  final String storeName;
  final int? merchantId;
  final int? userId;
  final bool isApproved;
  final bool isSuspended;
  final String? suspensionReason;
  final String? suspendedUntil;

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  late bool _isApproved;
  late bool _isSuspended;
  String? _suspensionReason;
  String? _suspendedUntil;
  int? _merchantId;
  int? _userId;

  bool _isLoading = false;
  List<Map<String, dynamic>> _offers = [];

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  void initState() {
    super.initState();
    _isApproved = widget.isApproved;
    _isSuspended = widget.isSuspended;
    _suspensionReason = widget.suspensionReason;
    _suspendedUntil = widget.suspendedUntil;
    _merchantId = widget.merchantId;
    _userId = widget.userId;

    if (_isApproved && !_isSuspended) {
      _fetchMerchantOffers();
    } else if (_userId != null || _merchantId != null) {
      _checkLiveStatus();
    }
  }

  Future<void> _checkLiveStatus() async {
    setState(() => _isLoading = true);

    try {
      final targetUrl = _userId != null 
          ? ApiConstants.merchantStatusUrl(_userId!) 
          : '${ApiConstants.baseUrl}/api/merchants/${_merchantId ?? 1}';
      final uri = Uri.parse(targetUrl);
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _merchantId = data['id'] ?? _merchantId;
            _isApproved = data['isApproved'] == true;
            _isSuspended = data['isSuspended'] == true;
            _suspensionReason = data['suspensionReason'] as String?;
            _suspendedUntil = data['suspendedUntil']?.toString();
          });
          if (_isApproved && !_isSuspended) {
            _fetchMerchantOffers();
          }
        }
      }
    } catch (_) {
      // Keep existing state if offline
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMerchantOffers() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(ApiConstants.offersUrl);
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        final filtered = list.where((o) {
          if (_merchantId != null && o['merchantId'] != null) {
            return o['merchantId'] == _merchantId;
          }
          final m = o['merchant'];
          if (m != null && m['storeName'] != null) {
            return m['storeName'].toString().contains(widget.storeName);
          }
          return false;
        }).toList();

        if (mounted) {
          setState(() {
            _offers = filtered.cast<Map<String, dynamic>>();
          });
        }
      }
    } catch (_) {
      // Do not inject fake offers; only show what the merchant actually adds!
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddOfferDialog() {
    if (!_isApproved) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('طلبك قيد المراجعة', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('لا يمكن نشر العروض حالياً لأن متجرك بانتظار المراجعة والتوثيق من قِبل إدارة منصة وفر.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
          ],
        ),
      );
      return;
    }
    if (_isSuspended) {
      final period = _suspendedUntil != null && _suspendedUntil!.isNotEmpty ? 'حتى $_suspendedUntil' : 'بشكل نهائي';
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('المتجر موقوف عن النشر', style: TextStyle(fontWeight: FontWeight.bold, color: primaryRed)),
          content: Text('تم إيقاف متجرك عن نشر العروض $period.\n\nسبب الإيقاف: ${_suspensionReason ?? "مخالفة الشروط والأحكام"}.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
          ],
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final origPriceCtrl = TextEditingController();
    final discPriceCtrl = TextEditingController();
    int selectedCategoryId = 1;
    bool isFlash = false;
    XFile? pickedImage;

    final categories = [
      {'id': 1, 'name': 'سوبرماركت ومواد غذائية'},
      {'id': 2, 'name': 'إلكترونيات وهواتف'},
      {'id': 3, 'name': 'مطاعم وكافيهات'},
      {'id': 4, 'name': 'أزياء وملابس'},
      {'id': 5, 'name': 'صحة وجمال'},
      {'id': 6, 'name': 'سيارات وخدمات'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إضافة عرض تخفيض جديد',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'عنوان العرض *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال عنوان العرض' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'تفاصيل العرض ومزاياه',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: origPriceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'السعر القديم (ر.ي) *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || double.tryParse(v) == null ? 'أدخل سعر صحيح' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: discPriceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'سعر التخفيض (ر.ي) *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || double.tryParse(v) == null ? 'أدخل سعر صحيح' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'القسم / التصنيف',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem<int>(
                              value: c['id'] as int,
                              child: Text(c['name'] as String),
                            ))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedCategoryId = v ?? 1),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('عرض خاطف (Flash Sale) ⚡', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('تمييز العرض لفرصة توفير سريعة ومحدودة'),
                    value: isFlash,
                    activeThumbColor: primaryRed,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setModalState(() => isFlash = v),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                      if (picked != null) {
                        setModalState(() => pickedImage = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: pickedImage != null ? Colors.green : Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                        color: pickedImage != null ? Colors.green.shade50 : Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(pickedImage != null ? Icons.check_circle : Icons.add_photo_alternate,
                              color: pickedImage != null ? Colors.green : primaryRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pickedImage != null ? 'تم اختيار صورة العرض بنجاح' : 'اختيار صورة للعرض',
                              style: TextStyle(
                                  color: pickedImage != null ? Colors.green.shade900 : Colors.black87,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (pickedImage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FutureBuilder<Uint8List>(
                          future: pickedImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              );
                            }
                            return const Center(child: CircularProgressIndicator(color: primaryRed));
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(ctx);
                        await _createOffer(
                          title: titleCtrl.text.trim(),
                          desc: descCtrl.text.trim(),
                          origPrice: double.parse(origPriceCtrl.text.trim()),
                          discPrice: double.parse(discPriceCtrl.text.trim()),
                          categoryId: selectedCategoryId,
                          isFlash: isFlash,
                          image: pickedImage,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('نشر العرض الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createOffer({
    required String title,
    required String desc,
    required double origPrice,
    required double discPrice,
    required int categoryId,
    required bool isFlash,
    XFile? image,
  }) async {
    setState(() => _isLoading = true);

    try {
      final req = http.MultipartRequest('POST', Uri.parse(ApiConstants.offersUrl));
      req.fields['Title'] = title;
      req.fields['Description'] = desc;
      req.fields['OriginalPrice'] = origPrice.toString();
      req.fields['DiscountedPrice'] = discPrice.toString();
      req.fields['CategoryId'] = categoryId.toString();
      req.fields['MerchantId'] = (_merchantId ?? 1).toString();
      req.fields['IsFlashSale'] = isFlash.toString();
      req.fields['StartDate'] = DateTime.now().toIso8601String();
      req.fields['EndDate'] = DateTime.now().add(const Duration(days: 14)).toIso8601String();

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final mimeType = image.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
          req.files.add(http.MultipartFile.fromBytes(
            'Image',
            bytes,
            filename: image.name,
            contentType: MediaType.parse(mimeType),
          ));
        } else {
          req.files.add(await http.MultipartFile.fromPath('Image', image.path));
        }
      }

      final streamed = await req.send().timeout(const Duration(seconds: 10));
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم نشر العرض بنجاح! 🎉'), backgroundColor: Colors.green),
          );
        }
        _fetchMerchantOffers();
        return;
      } else {
        String msg = 'رمز الخطأ: ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is List) {
            msg = decoded.join('\n');
          } else if (decoded is Map) {
            msg = decoded['message'] ?? decoded['error'] ?? res.body;
          }
        } catch (_) {
          if (res.body.isNotEmpty) {
            msg = res.body;
          }
        }
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('فشل نشر العرض', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text(msg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('حسناً'),
                )
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر الاتصال بالخادم لنشر العرض. يرجى التأكد من تشغيل السيرفر.'), backgroundColor: primaryRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOffer({
    required int offerId,
    required String title,
    required String desc,
    required double origPrice,
    required double discPrice,
    required int categoryId,
    required bool isFlash,
    required DateTime startDate,
    required DateTime endDate,
    XFile? image,
  }) async {
    setState(() => _isLoading = true);

    try {
      final req = http.MultipartRequest('PUT', Uri.parse('${ApiConstants.offersUrl}/$offerId'));
      req.fields['Title'] = title;
      req.fields['Description'] = desc;
      req.fields['OriginalPrice'] = origPrice.toString();
      req.fields['DiscountedPrice'] = discPrice.toString();
      req.fields['CategoryId'] = categoryId.toString();
      req.fields['MerchantId'] = (_merchantId ?? 1).toString();
      req.fields['IsFlashSale'] = isFlash.toString();
      req.fields['StartDate'] = startDate.toIso8601String();
      req.fields['EndDate'] = endDate.toIso8601String();

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final mimeType = image.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
          req.files.add(http.MultipartFile.fromBytes(
            'Image',
            bytes,
            filename: image.name,
            contentType: MediaType.parse(mimeType),
          ));
        } else {
          req.files.add(await http.MultipartFile.fromPath('Image', image.path));
        }
      }

      final streamed = await req.send().timeout(const Duration(seconds: 10));
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تعديل العرض بنجاح! 🎉'), backgroundColor: Colors.green),
          );
        }
        _fetchMerchantOffers();
        return;
      } else {
        String msg = 'رمز الخطأ: ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is List) {
            msg = decoded.join('\n');
          } else if (decoded is Map) {
            msg = decoded['message'] ?? decoded['error'] ?? res.body;
          }
        } catch (_) {
          if (res.body.isNotEmpty) {
            msg = res.body;
          }
        }
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('فشل تعديل العرض', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text(msg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('حسناً'),
                )
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر الاتصال بالخادم لتعديل العرض.'), backgroundColor: primaryRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteOffer(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف العرض'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا العرض نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await http.delete(Uri.parse(ApiConstants.offerByIdUrl(id))).timeout(const Duration(seconds: 5));
    } catch (_) {}

    setState(() {
      _offers.removeWhere((o) => o['id'] == id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف العرض بنجاح.')),
      );
    }
  }

  void _showEditOfferDialog(Map<String, dynamic> offer) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: offer['title']?.toString() ?? '');
    final descCtrl = TextEditingController(text: offer['description']?.toString() ?? '');
    final origPriceCtrl = TextEditingController(text: offer['originalPrice']?.toString() ?? '0');
    final discPriceCtrl = TextEditingController(text: offer['discountedPrice']?.toString() ?? '0');

    int selectedCategoryId = offer['categoryId'] is int
        ? offer['categoryId'] as int
        : int.tryParse(offer['categoryId']?.toString() ?? '') ?? 1;

    bool isFlash = offer['isFlashSale'] == true;

    DateTime startDate = DateTime.tryParse(offer['startDate']?.toString() ?? '') ?? DateTime.now();
    DateTime endDate = DateTime.tryParse(offer['endDate']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 14));

    XFile? pickedImage;
    final existingImageUrl = offer['imageUrl']?.toString() ?? '';

    final categories = [
      {'id': 1, 'name': 'سوبرماركت ومواد غذائية'},
      {'id': 2, 'name': 'إلكترونيات وهواتف'},
      {'id': 3, 'name': 'مطاعم وكافيهات'},
      {'id': 4, 'name': 'أزياء وملابس'},
      {'id': 5, 'name': 'صحة وجمال'},
      {'id': 6, 'name': 'سيارات وخدمات'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'تعديل بيانات العرض',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'عنوان العرض *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخل عنوان العرض' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'تفاصيل العرض ومزاياه',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: origPriceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'السعر القديم (ر.ي) *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || double.tryParse(v) == null ? 'أدخل سعر صحيح' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: discPriceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'سعر التخفيض (ر.ي) *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || double.tryParse(v) == null ? 'أدخل سعر صحيح' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'القسم / التصنيف',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem<int>(
                              value: c['id'] as int,
                              child: Text(c['name'] as String),
                            ))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedCategoryId = v ?? 1),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('عرض خاطف (Flash Sale) ⚡', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('تمييز العرض لفرصة توفير سريعة ومحدودة'),
                    value: isFlash,
                    activeThumbColor: primaryRed,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setModalState(() => isFlash = v),
                  ),
                  const SizedBox(height: 12),
                  // Date Duration Picker Section
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 18),
                          label: Text('البدء: ${startDate.year}-${startDate.month}-${startDate.day}'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() => startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 18),
                          label: Text('الانتهاء: ${endDate.year}-${endDate.month}-${endDate.day}'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: startDate,
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() => endDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                      if (picked != null) {
                        setModalState(() => pickedImage = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: pickedImage != null ? Colors.green : Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                        color: pickedImage != null ? Colors.green.shade50 : Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Icon(pickedImage != null ? Icons.check_circle : Icons.add_photo_alternate,
                              color: pickedImage != null ? Colors.green : primaryRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pickedImage != null ? 'تم اختيار صورة جديدة بنجاح' : 'تغيير صورة العرض (اختياري)',
                              style: TextStyle(
                                  color: pickedImage != null ? Colors.green.shade900 : Colors.black87,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (pickedImage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FutureBuilder<Uint8List>(
                          future: pickedImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              );
                            }
                            return const Center(child: CircularProgressIndicator(color: primaryRed));
                          },
                        ),
                      ),
                    ),
                  ] else if (existingImageUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          existingImageUrl.startsWith('http')
                              ? existingImageUrl
                              : '${ApiConstants.baseUrl}/${existingImageUrl.replaceAll(RegExp(r'^/+'), '')}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(ctx);
                        final offerId = offer['id'] is int ? offer['id'] as int : int.tryParse(offer['id'].toString()) ?? 0;
                        await _updateOffer(
                          offerId: offerId,
                          title: titleCtrl.text.trim(),
                          desc: descCtrl.text.trim(),
                          origPrice: double.parse(origPriceCtrl.text.trim()),
                          discPrice: double.parse(discPriceCtrl.text.trim()),
                          categoryId: selectedCategoryId,
                          isFlash: isFlash,
                          startDate: startDate,
                          endDate: endDate,
                          image: pickedImage,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('حفظ التعديلات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          title: Text(
            widget.storeName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث البيانات',
              onPressed: () {
                _checkLiveStatus();
                if (_isApproved) _fetchMerchantOffers();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryRed))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Banner
                    _buildStatusBanner(),
                    const SizedBox(height: 20),

                    // If Approved & Not Suspended: Show Dashboard Operations
                    if (_isApproved && !_isSuspended) ...[
                      _buildSummaryStats(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'عروض المتجر المنشورة',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddOfferDialog,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('إضافة عرض جديد'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildOffersList(),
                    ],

                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined, color: primaryRed),
                      label: const Text(
                        'تصفح التطبيق كعميل (استعراض العروض العامة)',
                        style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.headset_mic_outlined, color: primaryRed, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'المساعدة والدعم للتواصل: 779888892',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    // 1: Suspended
    if (_isSuspended) {
      final period = _suspendedUntil != null && _suspendedUntil!.isNotEmpty
          ? 'إيقاف مؤقت حتى $_suspendedUntil'
          : 'إيقاف نهائي عن نشر العروض';
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.gavel_rounded, color: Colors.red.shade800, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تم إيقاف متجرك عن نشر العروض 🚫',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        period,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_suspensionReason != null && _suspensionReason!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'سبب الإيقاف: $_suspensionReason',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red.shade900),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              'لا يمكنك إضافة أو تعديل العروض أثناء فترة الإيقاف. يرجى التواصل مع إدارة منصة وفر لمزيد من التفاصيل.',
              style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _checkLiveStatus,
              icon: const Icon(Icons.sync, size: 18),
              label: const Text('فحص وتحديث حالة المتجر الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    // 2: Approved
    if (_isApproved) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حساب تاجر معتمد ومفعل ✅',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مرحباً بك يا ${widget.merchantName}. يمكنك الآن إضافة وتعديل وإدارة عروض متجرك ونشرها للعملاء فوراً.',
                    style: TextStyle(fontSize: 13, color: Colors.green.shade900),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 0: Pending (Default)
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: Colors.amber.shade800, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'طلبك قيد المراجعة من قِبل الإدارة ⏳',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber.shade900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'تم استلام بيانات متجرك بنجاح. يجري حالياً مراجعتها من قبل فريق إدارة منصة وفر في صنعاء. سيتم تفعيل لوحة العروض فور اعتماد الحساب.',
            style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _checkLiveStatus,
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('فحص وتحديث حالة الاعتماد الآن'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('إجمالي العروض', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '${_offers.length}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryRed),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نطاق التغطية', style: TextStyle(color: Colors.grey, fontSize: 13)),
                SizedBox(height: 6),
                Text(
                  'صنعاء 📍',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOffersList() {
    if (_offers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'لا توجد عروض منشورة حتى الآن',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 4),
            Text(
              'اضغط على "إضافة عرض جديد" للبدء بنشر عروضك في صنعاء.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final o = _offers[i];
        final title = o['title']?.toString() ?? 'عرض بدون عنوان';
        final origPrice = o['originalPrice'] ?? 0;
        final discPrice = o['discountedPrice'] ?? 0;
        final isFlash = o['isFlashSale'] == true;
        final id = o['id'] is int ? o['id'] as int : int.tryParse(o['id'].toString()) ?? i;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_offer, color: primaryRed),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isFlash)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('خاطف ⚡', style: TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$origPrice ر.ي',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$discPrice ر.ي',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryRed,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: primaryRed, size: 20),
                tooltip: 'تعديل',
                onPressed: () => _showEditOfferDialog(o),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                tooltip: 'حذف',
                onPressed: () => _deleteOffer(id),
              ),
            ],
          ),
        );
      },
    );
  }
}
