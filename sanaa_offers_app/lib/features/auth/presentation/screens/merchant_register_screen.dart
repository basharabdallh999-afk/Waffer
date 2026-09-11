import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/input_validators.dart';
import 'merchant_dashboard_screen.dart';

class MerchantRegisterScreen extends StatefulWidget {
  const MerchantRegisterScreen({super.key});

  @override
  State<MerchantRegisterScreen> createState() => _MerchantRegisterScreenState();
}

class _MerchantRegisterScreenState extends State<MerchantRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showServerConfigDialog() {
    final ctrl = TextEditingController(text: ApiConstants.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.dns, color: primaryRed),
            SizedBox(width: 8),
            Text('عنوان خادم الـ API', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إذا كنت تقوم بالاختبار من هاتف جوال حقيقي، أدخل عنوان الـ IP الخاص بجهاز الكمبيوتر في نفس شبكة Wi-Fi:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: 'عنوان السيرفر (Base URL)',
                hintText: 'http://${ApiConstants.pcWifiIp}:5232',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'خيارات سريعة للاختيار المباشر:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.wifi, size: 16, color: primaryRed),
                  label: Text('جوال Wi-Fi (${ApiConstants.pcWifiIp})'),
                  backgroundColor: primaryRed.withValues(alpha: 0.1),
                  onPressed: () {
                    ctrl.text = ApiConstants.wifiMobileUrl;
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.phone_android, size: 16),
                  label: const Text('محاكي (10.0.2.2)'),
                  onPressed: () {
                    ctrl.text = ApiConstants.emulatorUrl;
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.computer, size: 16),
                  label: const Text('كمبيوتر (localhost)'),
                  onPressed: () {
                    ctrl.text = ApiConstants.localhostUrl;
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ApiConstants.customBaseUrl = null;
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('استعادة الافتراضي'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white),
            onPressed: () {
              ApiConstants.customBaseUrl = ctrl.text.trim();
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تحديث عنوان الخادم إلى: ${ApiConstants.baseUrl}')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    int? createdMerchantId;
    int? createdUserId;
    bool requestSucceeded = false;
    String errorMessage = '';

    try {
      final uri = Uri.parse(ApiConstants.registerMerchantUrl);
      final req = http.MultipartRequest('POST', uri);

      req.fields['Username'] = _usernameController.text.trim();
      req.fields['Password'] = _passwordController.text.trim();
      req.fields['Phone'] = _phoneController.text.trim();
      req.fields['StoreName'] = _storeNameController.text.trim();
      req.fields['Address'] = _addressController.text.trim();

      final streamedRes = await req.send().timeout(const Duration(seconds: 15));
      final res = await http.Response.fromStream(streamedRes);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        createdMerchantId = data['id'];
        createdUserId = data['userId'];
        requestSucceeded = true;
      } else {
        try {
          final err = jsonDecode(res.body);
          errorMessage = err['message'] ?? 'فشل الخادم في حفظ الطلب (رمز: ${res.statusCode})';
        } catch (_) {
          errorMessage = 'فشل إرسال الطلب (رمز استجابة الخادم: ${res.statusCode})';
        }
      }
    } catch (e) {
      errorMessage = 'تعذر الاتصال بخادم الـ API على العنوان:\n${ApiConstants.registerMerchantUrl}\n\nيرجى التأكد من تشغيل خادم الـ API وتوصيل الهاتف بنفس شبكة الكمبيوتر.';
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!requestSucceeded) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('فشل إرسال الطلب للخادم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage, style: const TextStyle(fontSize: 13, height: 1.5)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Text(
                  'تنبيه: لن يظهر طلب التاجر في لوحة إدارة الموقع إذا لم يتم إرساله بنجاح إلى السيرفر.',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showServerConfigDialog();
              },
              child: const Text('تعديل عنوان السيرفر (IP)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال طلب تسجيل التاجر بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MerchantDashboardScreen(
          merchantName: _usernameController.text.trim(),
          storeName: _storeNameController.text.trim(),
          merchantId: createdMerchantId,
          userId: createdUserId,
          isApproved: false, // Default is Pending for review by Admin
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        title: const Text(
          'تسجيل حساب تاجر جديد',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'إعدادات عنوان السيرفر',
            onPressed: _showServerConfigDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryRed.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryRed, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'يرجى تعبئة كافة البيانات وارفاق وثائق الهوية الشخصية ليتم مراجعتها واعتماد حسابك من قبل الإدارة.',
                          style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Inputs
                _buildInputField(
                  controller: _usernameController,
                  label: 'اسم المستخدم / الاسم الكامل',
                  icon: Icons.person_outline,
                  validator: InputValidators.validateFullName,
                ),
                const SizedBox(height: 14),

                _buildInputField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: InputValidators.validatePassword,
                ),
                const SizedBox(height: 14),

                _buildInputField(
                  controller: _phoneController,
                  label: 'رقم الهاتف (الواتساب)',
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.trim().length < 6 ? 'يرجى إدخال رقم هاتف صحيح' : null,
                ),
                const SizedBox(height: 14),

                _buildInputField(
                  controller: _storeNameController,
                  label: 'اسم المتجر / النشاط التجاري',
                  icon: Icons.storefront_outlined,
                  validator: InputValidators.validateStoreName,
                ),
                const SizedBox(height: 14),

                _buildInputField(
                  controller: _addressController,
                  label: 'موقع المتجر / العنوان في صنعاء',
                  icon: Icons.location_on_outlined,
                  validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال عنوان المتجر' : null,
                ),
                const SizedBox(height: 28),

                const SizedBox(height: 20),

                // Submit Registration Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'إرسال طلب التسجيل',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryRed),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }}
