import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String message, [String tag = 'DEBUG']) {
    if (kDebugMode) {
      debugPrint('[$tag] 💡 $message');
    }
  }

  static void info(String message, [String tag = 'INFO']) {
    if (kDebugMode) {
      debugPrint('[$tag] ℹ️ $message');
    }
  }

  static void w(String message, [String tag = 'WARN']) {
    if (kDebugMode) {
      debugPrint('[$tag] ⚠️ $message');
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace, String tag = 'ERROR']) {
    if (kDebugMode) {
      debugPrint('[$tag] 🚨 $message');
      if (error != null) debugPrint('Error details: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}
