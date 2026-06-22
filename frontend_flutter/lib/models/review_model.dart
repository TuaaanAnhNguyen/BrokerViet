class ReviewModel {
  final String id;
  final String userName;
  final String userAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    // Giả định chúng ta lấy data kèm join với bảng profiles
    final profile = map['profiles'] as Map<String, dynamic>?;
    return ReviewModel(
      id: map['id'],
      userName: profile?['username'] ?? 'Người dùng',
      userAvatar: profile?['avatar_url'] ?? '',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}