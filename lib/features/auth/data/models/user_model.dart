class UserModel {
  final String id;
  final String username;
  final String email;
  final String? token;
  final String? profilePic;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.token,
    this.profilePic,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Backend returns _id for MongoDB documents
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      token: json['token']?.toString(),
      profilePic: json['profilePic']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
      'profilePic': profilePic,
    };
  }
}
