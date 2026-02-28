import '../../domain/entities/user_entity.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final UserEntity user;
  const RegisterSuccess(this.user);
}

class RegisterError extends RegisterState {
  final String message;
  const RegisterError(this.message);
}
