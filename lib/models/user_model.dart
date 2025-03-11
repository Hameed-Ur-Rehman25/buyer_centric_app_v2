class UserModel {
  final String uid;
  final String email;
  final String? username;
  final String? profileImage;

  UserModel({
    required this.uid,
    required this.email,
    this.username,
    this.profileImage,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String?,
      profileImage: map['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'profileImage': profileImage,
    };
  }
}
