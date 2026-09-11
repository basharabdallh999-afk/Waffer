import 'package:flutter/material.dart';

import '../../../../core/utils/api_constants.dart';
import '../../../../main.dart';
import '../controllers/profile_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.profileController,
  });

  final ProfileController profileController;

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
      ),
      body: AnimatedBuilder(
        animation: profileController,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      // Notifications Switch Tile
                      SwitchListTile(
                        activeThumbColor: primaryRed,
                        secondary: const Icon(Icons.notifications_outlined, color: primaryRed),
                        title: const Text(
                          'تفعيل الإشعارات',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'احصل على إشعارات حول العروض الجديدة',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        value: profileController.notificationsEnabled,
                        onChanged: (val) => profileController.toggleNotifications(val),
                      ),
                      const Divider(height: 1),

                      // Language Tile
                      ListTile(
                        leading: const Icon(Icons.language, color: primaryRed),
                        title: const Text(
                          'لغة التطبيق',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'العربية',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('اللغة الافتراضية حالياً هي العربية'),
                              backgroundColor: primaryRed,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),

                      // Appearance Theme Switch Tile (Dark Mode)
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: appThemeNotifier,
                        builder: (context, themeMode, _) {
                          final isDark = themeMode == ThemeMode.dark;
                          return SwitchListTile(
                            activeThumbColor: primaryRed,
                            secondary: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: primaryRed,
                            ),
                            title: const Text(
                              'الوضع الليلي (Dark Mode)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text(
                              isDark ? 'الوضع الليلي مفعّل' : 'الوضع الفاتح مفعّل',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            value: isDark,
                            onChanged: (val) {
                              appThemeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                            },
                          );
                        },
                      ),
                      const Divider(height: 1),

                      // App Version Tile
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: primaryRed),
                        title: const Text(
                          'الإصدار',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        trailing: Text(
                          '1.0.0',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Help & Support Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.headset_mic_outlined, color: primaryRed),
                        title: const Text(
                          'المساعدة والدعم للتواصل',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'خدمة عملاء وتجار منصة وفر في صنعاء',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone, size: 14, color: primaryRed),
                              SizedBox(width: 4),
                              Text(
                                '779888892',
                                style: TextStyle(fontWeight: FontWeight.bold, color: primaryRed, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Row(
                                children: [
                                  Icon(Icons.support_agent, color: primaryRed),
                                  SizedBox(width: 8),
                                  Text('المساعدة والدعم', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('يسعدنا تواصلكم وتقديم المساعدة لكافة التجار والعملاء في صنعاء.'),
                                  SizedBox(height: 12),
                                  Text('رقم الهاتف / الواتساب المعتمد:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  SelectableText(
                                    '779888892',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryRed),
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('حسناً'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.dns_outlined, color: primaryRed),
                        title: const Text(
                          'عنوان خادم الـ API',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Text(
                          ApiConstants.baseUrl,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                        onTap: () {
                          final ctrl = TextEditingController(text: ApiConstants.baseUrl);
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('تعديل عنوان السيرفر (API)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              content: TextField(
                                controller: ctrl,
                                decoration: const InputDecoration(
                                  labelText: 'Base URL',
                                  hintText: 'http://192.168.1.x:5232',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    ApiConstants.customBaseUrl = null;
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('الافتراضي'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white),
                                  onPressed: () {
                                    ApiConstants.customBaseUrl = ctrl.text.trim();
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('حفظ'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
