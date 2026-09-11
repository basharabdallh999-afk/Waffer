class InputValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تتكون من 6 أحرف على الأقل';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الاسم الكامل';
    }
    if (value.trim().length < 3) {
      return 'الاسم يجب أن لا يقل عن 3 أحرف';
    }
    return null;
  }

  static String? validateStoreName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال اسم المتجر';
    }
    if (value.trim().length < 2) {
      return 'اسم المتجر قصيرة جداً';
    }
    return null;
  }

  static String? validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!urlPattern.hasMatch(value.trim())) {
      return 'يرجى إدخال رابط صورة صحيح (URL)';
    }
    return null;
  }
}
