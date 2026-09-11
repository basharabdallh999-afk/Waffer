import 'package:flutter/material.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_merchant_usecase.dart';
import '../../domain/usecases/register_personal_usecase.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required this.loginUseCase,
    required this.registerPersonalUseCase,
    required this.registerMerchantUseCase,
  });

  final LoginUseCase loginUseCase;
  final RegisterPersonalUseCase registerPersonalUseCase;
  final RegisterMerchantUseCase registerMerchantUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  bool get isAuthenticated =>
      _currentUser != null && !(_currentUser!.isGuest);

  // ─── Auto-Login ───────────────────────────────────────────────────────────

  /// يُستدعى عند بدء التطبيق — يحاول استعادة الجلسة المحفوظة
  bool tryAutoLogin() {
    final saved = LocalStorageService.getSavedUser();
    if (saved == null) return false;
    _currentUser = UserEntity(
      name: saved['name'] as String,
      email: saved['email'] as String,
      isMerchant: saved['isMerchant'] as bool,
      storeName: saved['storeName'] as String?,
      token: saved['token'] as String?,
      isApproved: saved['isApproved'] as bool? ?? true,
      isSuspended: saved['isSuspended'] as bool? ?? false,
      suspensionReason: saved['suspensionReason'] as String?,
      suspendedUntil: saved['suspendedUntil'] as String?,
    );
    AppLogger.info('Auto-login: ${_currentUser!.name}');
    notifyListeners();
    return true;
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await loginUseCase(LoginParams(email: email, password: password));
      _currentUser = user;
      // حفظ الجلسة محلياً
      await LocalStorageService.saveUser(
        name: user.name,
        email: user.email,
        isMerchant: user.isMerchant,
        storeName: user.storeName,
        token: user.token ?? 'local_token_${user.email}',
        isApproved: user.isApproved,
        isSuspended: user.isSuspended,
        suspensionReason: user.suspensionReason,
        suspendedUntil: user.suspendedUntil,
      );
      AppLogger.info('User logged in: ${user.name}');
      _setLoading(false);
      return true;
    } on Failure catch (f) {
      _errorMessage = f.message;
      AppLogger.w('Login failed: ${f.message}');
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً';
      _setLoading(false);
      return false;
    }
  }

  // ─── Register Personal ────────────────────────────────────────────────────

  Future<bool> registerPersonal(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await registerPersonalUseCase(
        RegisterPersonalParams(name: name, email: email, password: password),
      );
      _currentUser = user;
      await LocalStorageService.saveUser(
        name: user.name,
        email: user.email,
        isMerchant: false,
        token: user.token ?? 'local_token_${user.email}',
      );
      _setLoading(false);
      return true;
    } on Failure catch (f) {
      _errorMessage = f.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع أثناء تسجيل الحساب الشخصي';
      _setLoading(false);
      return false;
    }
  }

  // ─── Register Merchant ────────────────────────────────────────────────────

  Future<bool> registerMerchant(String storeName, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await registerMerchantUseCase(
        RegisterMerchantParams(storeName: storeName, email: email, password: password),
      );
      _currentUser = user;
      await LocalStorageService.saveUser(
        name: storeName,
        email: user.email,
        isMerchant: true,
        storeName: storeName,
        token: user.token ?? 'local_token_${user.email}',
        isApproved: false,
        isSuspended: false,
      );
      _setLoading(false);
      return true;
    } on Failure catch (f) {
      _errorMessage = f.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع أثناء تسجيل حساب التاجر';
      _setLoading(false);
      return false;
    }
  }

  // ─── Guest ────────────────────────────────────────────────────────────────

  void loginAsGuest() {
    _currentUser = UserEntity.guest();
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await LocalStorageService.clearSession();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
