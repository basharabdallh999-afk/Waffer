import 'package:flutter/material.dart';

import 'auth_screen.dart';

/// شاشة الترحيب وتسجيل الدخول الرئيسية لمنصة وفر
/// تعرض واجهة التبويبات الثلاثية المطابقة للتصميم (تسجيل دخول، حساب شخصي، حساب تاجر)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen(initialTabIndex: 0);
  }
}
