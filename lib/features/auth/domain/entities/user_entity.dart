class UserEntity {
  final String id;
  final String username;
  final String email;
  final String? profilePic;
  final String? token;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.profilePic,
    this.token,
  });
}
