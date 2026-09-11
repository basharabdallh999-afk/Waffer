import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة التخزين المحلي — تحفظ الجلسة والمفضلة بين جلسات التطبيق
class LocalStorageService {
  LocalStorageService._();

  static late SharedPreferences _prefs;

  static const _keyToken = 'auth_token';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyIsMerchant = 'is_merchant';
  static const _keyStoreName = 'store_name';
  static const _keyIsApproved = 'is_approved';
  static const _keyIsSuspended = 'is_suspended';
  static const _keySuspensionReason = 'suspension_reason';
  static const _keySuspendedUntil = 'suspended_until';
  static const _keyFavorites = 'favorite_ids';

  /// يجب استدعاؤه في main() قبل runApp()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Token ───────────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) =>
      _prefs.setString(_keyToken, token);

  static String? getToken() => _prefs.getString(_keyToken);

  static bool get isLoggedIn =>
      _prefs.containsKey(_keyToken) &&
      (_prefs.getString(_keyToken)?.isNotEmpty ?? false);

  // ─── User Info ────────────────────────────────────────────────────────────

  static Future<void> saveUser({
    required String name,
    required String email,
    required bool isMerchant,
    String? storeName,
    String? token,
    bool isApproved = true,
    bool isSuspended = false,
    String? suspensionReason,
    String? suspendedUntil,
  }) async {
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setBool(_keyIsMerchant, isMerchant);
    await _prefs.setBool(_keyIsApproved, isApproved);
    await _prefs.setBool(_keyIsSuspended, isSuspended);
    if (storeName != null) await _prefs.setString(_keyStoreName, storeName);
    if (token != null) await _prefs.setString(_keyToken, token);
    if (suspensionReason != null) {
      await _prefs.setString(_keySuspensionReason, suspensionReason);
    } else {
      await _prefs.remove(_keySuspensionReason);
    }
    if (suspendedUntil != null) {
      await _prefs.setString(_keySuspendedUntil, suspendedUntil);
    } else {
      await _prefs.remove(_keySuspendedUntil);
    }
  }

  static Map<String, dynamic>? getSavedUser() {
    final email = _prefs.getString(_keyUserEmail);
    if (email == null) return null;
    return {
      'name': _prefs.getString(_keyUserName) ?? '',
      'email': email,
      'isMerchant': _prefs.getBool(_keyIsMerchant) ?? false,
      'storeName': _prefs.getString(_keyStoreName),
      'token': _prefs.getString(_keyToken),
      'isApproved': _prefs.getBool(_keyIsApproved) ?? true,
      'isSuspended': _prefs.getBool(_keyIsSuspended) ?? false,
      'suspensionReason': _prefs.getString(_keySuspensionReason),
      'suspendedUntil': _prefs.getString(_keySuspendedUntil),
    };
  }

  static Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyIsMerchant);
    await _prefs.remove(_keyStoreName);
    await _prefs.remove(_keyIsApproved);
    await _prefs.remove(_keyIsSuspended);
    await _prefs.remove(_keySuspensionReason);
    await _prefs.remove(_keySuspendedUntil);
  }

  // ─── Favorites ────────────────────────────────────────────────────────────

  static Future<void> saveFavorites(Set<int> ids) async {
    final encoded = jsonEncode(ids.toList());
    await _prefs.setString(_keyFavorites, encoded);
  }

  static Set<int> loadFavorites() {
    final raw = _prefs.getString(_keyFavorites);
    if (raw == null) return {};
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => int.tryParse('$e') ?? 0).toSet()..remove(0);
    } catch (_) {
      return {};
    }
  }
}
