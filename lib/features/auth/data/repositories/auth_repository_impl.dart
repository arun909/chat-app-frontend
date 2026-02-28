import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.register(
      username: username,
      email: email,
      password: password,
    );
    
    return UserEntity(
      id: userModel.id,
      username: userModel.username,
      email: userModel.email,
      token: userModel.token,
    );
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    return UserEntity(
      id: userModel.id,
      username: userModel.username,
      email: userModel.email,
      token: userModel.token,
    );
  }
}
