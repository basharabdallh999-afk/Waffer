import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this.remoteDataSource);
  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      return await remoteDataSource.login(email, password);
    } on ServerException catch (e) {
      AppLogger.e('Login failed: ${e.message}');
      throw ValidationFailure(e.message);
    } catch (e, st) {
      AppLogger.e('Unexpected login failure', e, st);
      throw const ServerFailure();
    }
  }

  @override
  Future<UserEntity> registerPersonal(String name, String email, String password) async {
    try {
      return await remoteDataSource.registerPersonal(name, email, password);
    } catch (e, st) {
      AppLogger.e('Personal registration failure', e, st);
      throw const ServerFailure('فشل إنشاء الحساب الشخصي، يرجى إعادة المحاولة');
    }
  }

  @override
  Future<UserEntity> registerMerchant(String storeName, String email, String password) async {
    try {
      return await remoteDataSource.registerMerchant(storeName, email, password);
    } catch (e, st) {
      AppLogger.e('Merchant registration failure', e, st);
      throw const ServerFailure('فشل إنشاء حساب التاجر، يرجى إعادة المحاولة');
    }
  }
}
