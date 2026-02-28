import '../../../auth/domain/entities/user_entity.dart';

abstract class UserSearchState {
  const UserSearchState();
}

class UserSearchInitial extends UserSearchState {
  const UserSearchInitial();
}

class UserSearchLoading extends UserSearchState {
  const UserSearchLoading();
}

class UserSearchSuccess extends UserSearchState {
  final List<UserEntity> users;
  const UserSearchSuccess(this.users);
}

class UserSearchError extends UserSearchState {
  final String message;
  const UserSearchError(this.message);
}
