// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String studentId;
  final String avatarPath;
  final String memberTier;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    required this.avatarPath,
    required this.memberTier,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? studentId,
    String? avatarPath,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      avatarPath: avatarPath ?? this.avatarPath,
      memberTier: memberTier,
    );
  }
}
