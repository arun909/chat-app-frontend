import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
  });

  Future<UserEntity> login({
  required String email,
  required String password,
});
}
