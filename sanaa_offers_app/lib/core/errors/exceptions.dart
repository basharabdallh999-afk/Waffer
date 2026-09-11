class ServerException implements Exception {
  const ServerException([this.message = 'حدث خطأ أثناء الاتصال بالخادم']);
  final String message;

  @override
  String toString() => message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'حدث خطأ أثناء قراءة البيانات المحفوظة']);
  final String message;

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}
