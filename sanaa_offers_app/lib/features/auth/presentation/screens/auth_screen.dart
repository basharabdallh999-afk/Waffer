import 'package:flutter/material.dart';

import '../../../../core/utils/input_validators.dart';
import '../../../navigation/presentation/screens/main_navigation_screen.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_merchant_usecase.dart';
import '../../domain/usecases/register_personal_usecase.dart';
import '../controllers/auth_controller.dart';
import 'merchant_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex; // 0: تسجيل دخول, 1: حساب شخصي, 2: حساب تاجر

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late int _selectedTab;
  bool _obscurePassword = true;
  late AuthController _authController;

  // Controllers for Login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Controllers for Personal Account
  final _personalNameController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _personalPasswordController = TextEditingController();

  // Controllers for Merchant Account
  final _merchantStoreNameController = TextEditingController();
  final _merchantEmailController = TextEditingController();
  final _merchantPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;

    final authRepo = AuthRepositoryImpl(AuthRemoteDataSourceImpl());
    _authController = AuthController(
      loginUseCase: LoginUseCase(authRepo),
      registerPersonalUseCase: RegisterPersonalUseCase(authRepo),
      registerMerchantUseCase: RegisterMerchantUseCase(authRepo),
    );
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _personalNameController.dispose();
    _personalEmailController.dispose();
    _personalPasswordController.dispose();
    _merchantStoreNameController.dispose();
    _merchantEmailController.dispose();
    _merchantPasswordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(
          initialUser: _authController.currentUser,
        ),
      ),
    );
  }

  void _navigateToMerchantDashboard({
    required String name,
    required String storeName,
    bool isApproved = false,
    bool isSuspended = false,
    String? suspensionReason,
    String? suspendedUntil,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MerchantDashboardScreen(
          merchantName: name,
          storeName: storeName,
          isApproved: isApproved,
          isSuspended: isSuspended,
          suspensionReason: suspensionReason,
          suspendedUntil: suspendedUntil,
        ),
      ),
    );
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    final success = await _authController.login(email, password);

    if (mounted) {
      if (success) {
        final user = _authController.currentUser;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'مرحباً بك مجدداً، ${user?.name ?? email}!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        if (user?.isMerchant == true) {
          _navigateToMerchantDashboard(
            name: user!.name,
            storeName: user.storeName ?? user.name,
            isApproved: user.isApproved,
            isSuspended: user.isSuspended,
            suspensionReason: user.suspensionReason,
            suspendedUntil: user.suspendedUntil,
          );
        } else {
          _navigateToHome();
        }
      } else if (_authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authController.errorMessage!),
            backgroundColor: primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _submitPersonalRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _personalNameController.text.trim();
    final email = _personalEmailController.text.trim();
    final password = _personalPasswordController.text.trim();

    final success = await _authController.registerPersonal(name, email, password);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إنشاء حسابك بنجاح، أهلاً بك يا $name!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _navigateToHome();
      } else if (_authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authController.errorMessage!),
            backgroundColor: primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _submitMerchantRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final storeName = _merchantStoreNameController.text.trim();
    final email = _merchantEmailController.text.trim();
    final password = _merchantPasswordController.text.trim();

    final success = await _authController.registerMerchant(storeName, email, password);

    if (mounted) {
      if (success) {
        // عرض رسالة مراجعة وتوثيق المتجر الاحترافية للمستخدم
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706), size: 42),
            ),
            title: const Text(
              'تم استلام طلب الانضمام بنجاح',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'أهلاً بك يا متجر "$storeName"!\n\nسيتم مراجعة وتوثيق متجرك من قِبل إدارة منصة وفر قريباً. ستتمكن من نشر وإدارة العروض فور اعتماد المتجر.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: Color(0xFFD97706), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'يظهر طلب متجرك الآن لدى مدير المنصة في موقع الويب للموافقة والتوثيق.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _navigateToMerchantDashboard(
                    name: storeName,
                    storeName: storeName,
                    isApproved: false,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(46),
                ),
                child: const Text('متابعة إلى لوحة التحكم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
        );
      } else if (_authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authController.errorMessage!),
            backgroundColor: primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _loginAsGuest() {
    _authController.loginAsGuest();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AnimatedBuilder(
                animation: _authController,
                builder: (context, child) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        // ─── Brand Header (Waffer / وفر) ─────────────────
                        const _WafferBrandHeader(),
                        const SizedBox(height: 36),

                        // ─── Segmented Control Switcher ───────────────────
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              _buildSegmentTab(0, 'تسجيل دخول'),
                              _buildSegmentTab(1, 'حساب شخصي'),
                              _buildSegmentTab(2, 'حساب تاجر'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // ─── Tab Content ──────────────────────────────────
                        if (_selectedTab == 0) _buildLoginForm(),
                        if (_selectedTab == 1) _buildPersonalForm(),
                        if (_selectedTab == 2) _buildMerchantForm(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _formKey.currentState?.reset();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryRed.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CustomInputField(
          controller: _loginEmailController,
          hintText: 'البريد الإلكتروني',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: InputValidators.validateEmail,
        ),
        const SizedBox(height: 16),
        _CustomInputField(
          controller: _loginPasswordController,
          hintText: 'كلمة المرور',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF6B7280),
              size: 22,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: InputValidators.validatePassword,
        ),
        const SizedBox(height: 24),

        // زر دخول
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _authController.isLoading ? null : _submitLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _authController.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'دخول',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 22),

        // فاصل أو
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'أو',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
          ],
        ),
        const SizedBox(height: 22),

        // زر الدخول كزائر
        OutlinedButton(
          onPressed: _loginAsGuest,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            side: const BorderSide(color: Color(0xFFE06D66), width: 1.5),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'الدخول كزائر',
                style: TextStyle(
                  color: primaryRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.face_retouching_natural_rounded, color: primaryRed, size: 22),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CustomInputField(
          controller: _personalNameController,
          hintText: 'الاسم الكامل',
          icon: Icons.person_outline_rounded,
          validator: InputValidators.validateFullName,
        ),
        const SizedBox(height: 16),
        _CustomInputField(
          controller: _personalEmailController,
          hintText: 'البريد الإلكتروني',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: InputValidators.validateEmail,
        ),
        const SizedBox(height: 16),
        _CustomInputField(
          controller: _personalPasswordController,
          hintText: 'كلمة المرور',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF6B7280),
              size: 22,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: InputValidators.validatePassword,
        ),
        const SizedBox(height: 24),

        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _authController.isLoading ? null : _submitPersonalRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _authController.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'إنشاء حساب شخصي',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMerchantForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CustomInputField(
          controller: _merchantStoreNameController,
          hintText: 'اسم المتجر',
          icon: Icons.storefront_outlined,
          validator: InputValidators.validateStoreName,
        ),
        const SizedBox(height: 16),
        _CustomInputField(
          controller: _merchantEmailController,
          hintText: 'البريد الإلكتروني للمتجر',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: InputValidators.validateEmail,
        ),
        const SizedBox(height: 16),
        _CustomInputField(
          controller: _merchantPasswordController,
          hintText: 'كلمة المرور',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF6B7280),
              size: 22,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: InputValidators.validatePassword,
        ),
        const SizedBox(height: 24),

        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _authController.isLoading ? null : _submitMerchantRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _authController.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'إنشاء حساب تاجر',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}

class _WafferBrandHeader extends StatelessWidget {
  const _WafferBrandHeader();

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: [
            const Text(
              'Waffer',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: primaryRed,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryRed.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'وفر',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'أفضل العروض في صنعاء',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CustomInputField extends StatelessWidget {
  const _CustomInputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: primaryRed, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryRed, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryRed, width: 1.8),
        ),
      ),
    );
  }
}
