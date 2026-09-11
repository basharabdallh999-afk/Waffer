import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/merchant_dashboard_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../services/local_storage_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    this.onSelectTab,
  });

  final ValueChanged<int>? onSelectTab;

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  Widget build(BuildContext context) {
    final user = LocalStorageService.getSavedUser();
    final isLoggedIn = LocalStorageService.isLoggedIn && user != null;
    final isMerchant = user?['isMerchant'] == true;
    final userName = user?['name'] ?? 'زائر المنصة';
    final userEmail = user?['email'] ?? 'أهلاً بك في تطبيق وفر';

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // ─── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 24,
              right: 20,
              left: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B1812), primaryRed],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isLoggedIn && userName.isNotEmpty
                              ? userName.substring(0, 1)
                              : 'و',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: primaryRed,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12.5,
                            ),
                          ),
                          if (isMerchant) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade400,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'حساب تاجر معتمد ★',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: Colors.white, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'وفر • منصة عروض صنعاء التجارية',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Menu Items ────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'الصفحة الرئيسية',
                  subtitle: 'استكشف أحدث الصفقات والتخفيضات',
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab?.call(0);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.grid_view_rounded,
                  title: 'الأقسام والتصنيفات',
                  subtitle: 'تصفح حسب فئات المتاجر',
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab?.call(1);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.favorite_rounded,
                  title: 'العروض المفضلة',
                  subtitle: 'قائمة الصفقات المحفوظة',
                  iconColor: Colors.pink.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab?.call(2);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person_rounded,
                  title: 'الملف الشخصي',
                  subtitle: 'إعدادات الحساب والجلسة',
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab?.call(3);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(thickness: 1, indent: 14, endIndent: 14),
                ),

                if (isMerchant)
                  _buildMenuItem(
                    context,
                    icon: Icons.storefront_rounded,
                    title: 'لوحة تحكم التاجر',
                    subtitle: 'إدارة ونشر عروض متجرك',
                    iconColor: Colors.amber.shade800,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MerchantDashboardScreen(
                            merchantName: userName,
                            storeName: user?['storeName'] ?? userName,
                          ),
                        ),
                      );
                    },
                  ),

                _buildMenuItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'عن التطبيق',
                  subtitle: 'مشروع التدريب الميداني - جامعة الحكمة',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.headset_mic_rounded,
                  title: 'الدعم والمساعدة',
                  subtitle: 'خدمة العملاء: 779888892',
                  iconColor: Colors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    _showSupportDialog(context);
                  },
                ),
              ],
            ),
          ),

          // ─── Footer ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: isLoggedIn
                      ? TextButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await LocalStorageService.clearSession();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const WelcomeScreen()),
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout_rounded,
                              color: primaryRed),
                          label: const Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: primaryRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_rounded,
                                size: 16, color: primaryRed),
                            const SizedBox(width: 6),
                            Text(
                              'وفر • تطبيق عروض صنعاء v1.0.0',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (iconColor ?? primaryRed).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? primaryRed,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11.5,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: Colors.grey,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: primaryRed, size: 24),
            SizedBox(width: 8),
            Text(
              'عن تطبيق وفر',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryRed.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_offer_rounded, color: primaryRed, size: 28),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'منصة وفر - دليلك الأول للتوفير والصفقات في صنعاء',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: primaryRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'ماذا يقدم لك التطبيق؟',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                icon: Icons.storefront_rounded,
                title: 'تصفح عروض المتاجر أولاً بأول',
                subtitle: 'استعراض أحدث التخفيضات اليومية والأسبوعية من كبرى المراكز التجارية والهايبرماركت في صنعاء.',
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                icon: Icons.price_check_rounded,
                title: 'مقارنة الأسعار ونسب الخصم',
                subtitle: 'معرفة السعر الأصلي والسعر بعد التخفيض ونسبة التوفير وتاريخ انتهاء صلاحية العرض بدقة.',
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                icon: Icons.favorite_border_rounded,
                title: 'حفظ وتتبع المفضلة',
                subtitle: 'إمكانية حفظ المنتجات والعروض التي تهمك للرجوع إليها سريعاً أثناء التسوق.',
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                icon: Icons.campaign_rounded,
                title: 'بوابة متكاملة للتجار والشركاء',
                subtitle: 'تمكين أصحاب المحلات والمتاجر من نشر وتحديث عروضهم والترويج لها لآلاف المستهلكين.',
              ),
              const Divider(height: 24),
              Text(
                'مشروع التدريب الميداني - قسم تكنولوجيا المعلومات\nجامعة الحكمة - AL-HIKMA UNIVERSITY\nالإصدار: v1.0.0 (Flutter + ASP.NET Core API)',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: primaryRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: primaryRed, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.support_agent_rounded, color: primaryRed),
            SizedBox(width: 8),
            Text(
              'خدمة العملاء والدعم',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'يسعدنا تواصلكم لتقديم المساعدة والاستفسارات:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.phone_rounded, color: primaryRed, size: 20),
                  SizedBox(width: 10),
                  Text(
                    '779888892',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'أوقات العمل: يومياً من 8 صباحاً حتى 10 مساءً',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تم',
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryRed)),
          ),
        ],
      ),
    );
  }
}
