class UserEntity {
  final String id;
  final String username;
  final String email;
  final String? token;
  final String? profilePic;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.token,
    this.profilePic,
  });
}
