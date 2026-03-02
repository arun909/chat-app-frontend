import 'dart:io';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<UserEntity> execute({
    required String token,
    String? username,
    String? email,
    String? password,
    File? profilePicFile,
  }) {
    return _repository.updateProfile(
      token: token,
      username: username,
      email: email,
      password: password,
      profilePicFile: profilePicFile,
    );
  }
}
