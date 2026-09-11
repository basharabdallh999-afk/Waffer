abstract class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'تعذر الاتصال بالخادم، يرجى المحاولة لاحقاً']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'يرجى التحقق من اتصال الإنترنت بالمحاولة مجدداً']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'حدث خطأ غير متوقع']);
}
