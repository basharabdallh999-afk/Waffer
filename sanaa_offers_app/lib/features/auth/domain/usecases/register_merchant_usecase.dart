import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterMerchantParams {
  const RegisterMerchantParams({
    required this.storeName,
    required this.email,
    required this.password,
  });
  final String storeName;
  final String email;
  final String password;
}

class RegisterMerchantUseCase
    implements UseCase<UserEntity, RegisterMerchantParams> {
  const RegisterMerchantUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<UserEntity> call(RegisterMerchantParams params) {
    return repository.registerMerchant(
      params.storeName,
      params.email,
      params.password,
    );
  }
}
