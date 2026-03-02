import 'dart:io';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

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
      profilePic: userModel.profilePic,
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
      profilePic: userModel.profilePic,
    );
  }

  @override
  Future<UserEntity> updateProfile({
    required String token,
    String? username,
    String? email,
    String? password,
    File? profilePicFile,
  }) async {
    final userModel = await _remoteDataSource.updateProfile(
      token: token,
      username: username,
      email: email,
      password: password,
      profilePicFile: profilePicFile,
    );

    return UserEntity(
      id: userModel.id,
      username: userModel.username,
      email: userModel.email,
      token: userModel.token,
      profilePic: userModel.profilePic,
    );
  }
}
