import '../../domain/entities/user_entity.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  final UserEntity user;
  const ProfileSuccess(this.user);
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}
