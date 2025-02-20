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
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'],
      profileImage: map['profileImage'],
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
