import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterPersonalParams {
  const RegisterPersonalParams({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}

class RegisterPersonalUseCase
    implements UseCase<UserEntity, RegisterPersonalParams> {
  const RegisterPersonalUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<UserEntity> call(RegisterPersonalParams params) {
    return repository.registerPersonal(
      params.name,
      params.email,
      params.password,
    );
  }
}
