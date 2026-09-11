import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> registerPersonal(String name, String email, String password);
  Future<UserEntity> registerMerchant(String storeName, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserEntity> login(String email, String password) async {
    AppLogger.d('Attempting API login for $email');

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/auth/login');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final token = data['token'] as String? ?? data['accessToken'] as String?;
        final user = data['user'] as Map<String, dynamic>? ?? data;
        return UserEntity(
          name: '${user['name'] ?? user['storeName'] ?? email.split('@').first}',
          email: email,
          isMerchant: user['role'] == 'merchant' || user['role'] == 'Merchant' || user['isMerchant'] == true,
          storeName: user['storeName'] as String?,
          token: token,
          isApproved: user['isApproved'] as bool? ?? true,
          isSuspended: user['isSuspended'] as bool? ?? false,
          suspensionReason: user['suspensionReason'] as String?,
          suspendedUntil: user['suspendedUntil']?.toString(),
        );
      } else if (res.statusCode == 401 || res.statusCode == 400) {
        throw const ServerException('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else {
        throw ServerException('خطأ في الخادم (${res.statusCode})');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      // ─── Fallback Mock Login ───────────────────────────────────────────
      AppLogger.w('API login unavailable, using mock: $e');
      await Future.delayed(const Duration(milliseconds: 400));

      if (email.contains('wrong') || password.length < 4) {
        throw const ServerException('بيانات الدخول غير صحيحة أو الحساب غير موجود');
      }
      return UserEntity(
        name: email.contains('merchant') ? 'متجر الصنعاني' : 'علي المحمدي',
        email: email,
        isMerchant: email.contains('merchant'),
        storeName: email.contains('merchant') ? 'متجر الصنعاني' : null,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        isApproved: true,
        isSuspended: false,
      );
    }
  }

  @override
  Future<UserEntity> registerPersonal(String name, String email, String password) async {
    AppLogger.d('API register personal: $name ($email)');

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/auth/register');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': 'customer'}),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final token = data['token'] as String? ?? data['accessToken'] as String?;
        return UserEntity(
          name: name,
          email: email,
          isMerchant: false,
          token: token,
        );
      } else {
        final body = jsonDecode(res.body);
        throw ServerException('${body['message'] ?? 'فشل تسجيل الحساب'}');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      // ─── Fallback Mock ─────────────────────────────────────────────────
      AppLogger.w('API register unavailable, using mock: $e');
      await Future.delayed(const Duration(milliseconds: 400));
      return UserEntity(
        name: name,
        email: email,
        isMerchant: false,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  @override
  Future<UserEntity> registerMerchant(String storeName, String email, String password) async {
    AppLogger.d('API register merchant: $storeName ($email)');

    try {
      final uri = Uri.parse(ApiConstants.registerMerchantUrl);
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'storeName': storeName, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final token = data['token'] as String? ?? data['accessToken'] as String?;
        return UserEntity(
          name: storeName,
          email: email,
          isMerchant: true,
          storeName: storeName,
          token: token,
          isApproved: false,
          isSuspended: false,
        );
      } else {
        final body = jsonDecode(res.body);
        throw ServerException('${body['message'] ?? 'فشل تسجيل حساب التاجر'}');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      // ─── Fallback Mock ─────────────────────────────────────────────────
      AppLogger.w('API merchant register unavailable, using mock: $e');
      await Future.delayed(const Duration(milliseconds: 400));
      return UserEntity(
        name: storeName,
        email: email,
        isMerchant: true,
        storeName: storeName,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        isApproved: false,
        isSuspended: false,
      );
    }
  }
}
