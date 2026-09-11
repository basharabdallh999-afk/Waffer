import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  const LoginUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<UserEntity> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}
