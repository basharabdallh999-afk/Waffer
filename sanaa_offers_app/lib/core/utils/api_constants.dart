import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String? _customBaseUrl;

  static const String pcWifiIp = '11.90.1.40';
  static const int apiPort = 5232;

  static String get wifiMobileUrl => 'http://$pcWifiIp:$apiPort';
  static String get emulatorUrl => 'http://10.0.2.2:$apiPort';
  static String get localhostUrl => 'http://localhost:$apiPort';

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.trim().isNotEmpty) {
      return _customBaseUrl!.trim();
    }
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) return localhostUrl;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Physical mobile devices connect over local Wi-Fi
        return wifiMobileUrl;
      }
      return localhostUrl;
    } catch (_) {
      return localhostUrl;
    }
  }

  static set customBaseUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      _customBaseUrl = null;
    } else {
      _customBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    }
  }

  static String get registerMerchantUrl => '$baseUrl/api/merchants/register-with-id';
  static String merchantStatusUrl(int userId) => '$baseUrl/api/merchants/status/$userId';
  static String get merchantsUrl => '$baseUrl/api/merchants';
  static String get offersUrl => '$baseUrl/api/offers';
  static String offerByIdUrl(int id) => '$baseUrl/api/offers/$id';
}
