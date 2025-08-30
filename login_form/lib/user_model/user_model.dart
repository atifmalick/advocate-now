// File: user model/user_model.dart

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
  });

  // Convert a UserModel object into a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
    };
  }

  // Create a UserModel object from a Firestore document snapshot
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }
}
