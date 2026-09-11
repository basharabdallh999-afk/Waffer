import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/services/local_storage_service.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// Global theme notifier — kept for settings_screen.dart compatibility
final ValueNotifier<ThemeMode> appThemeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // تهيئة التخزين المحلي (مطلوب قبل runApp)
  await LocalStorageService.init();

  runApp(const WafferApp());
}

class WafferApp extends StatefulWidget {
  const WafferApp({super.key});

  @override
  State<WafferApp> createState() => _WafferAppState();
}

class _WafferAppState extends State<WafferApp> {
  static const Color primaryRed = Color(0xFFB3241C);

  /// فحص Auto-Login عند بدء التطبيق
  late final Widget _homeWidget;

  @override
  void initState() {
    super.initState();

    if (LocalStorageService.isLoggedIn) {
      final saved = LocalStorageService.getSavedUser();
      if (saved != null) {
        // المستخدم مسجّل دخول — انتقل مباشرة للرئيسية
        _homeWidget = const Directionality(
          textDirection: TextDirection.rtl,
          child: MainNavigationScreen(),
        );
        return;
      }
    }
    // لا جلسة محفوظة — ابدأ من شاشة الترحيب
    _homeWidget = const Directionality(
      textDirection: TextDirection.rtl,
      child: WelcomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'وفر - أفضل العروض في صنعاء',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Cairo',
            brightness: Brightness.light,
            textTheme: GoogleFonts.cairoTextTheme(),
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryRed,
              primary: primaryRed,
              surface: const Color(0xFFF8F8F8),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F8F8),
            appBarTheme: AppBarTheme(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Cairo',
            brightness: Brightness.dark,
            textTheme: GoogleFonts.cairoTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme),
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryRed,
              primary: primaryRed,
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          home: _homeWidget,
        );
      },
    );
  }
}
