import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> registerPersonal(String name, String email, String password);
  Future<UserEntity> registerMerchant(String storeName, String email, String password);
}
