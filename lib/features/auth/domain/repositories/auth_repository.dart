import 'dart:io';
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

  Future<UserEntity> updateProfile({
    required String token,
    String? username,
    String? email,
    String? password,
    File? profilePicFile,
  });
}
