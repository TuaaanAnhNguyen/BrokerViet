// lib/models/profile_model.dart

class ProfileModel {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String? role;
  final String? address;
  final String? locationText;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? openingHour;
  final String? closingHour;
  final String? payoutBankCode;
  final String? payoutAccountNumber;

  // Appended runtime metadata parameters from auth.users
  final String? email;
  final String? phone;

  ProfileModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.role,
    this.address,
    this.locationText,
    this.locationLatitude,
    this.locationLongitude,
    this.openingHour,
    this.closingHour,
    this.payoutBankCode,
    this.payoutAccountNumber,
    this.email,
    this.phone,
  });

  factory ProfileModel.fromJson(
    Map<String, dynamic> json, {
    String? authEmail,
    String? authPhone,
  }) {
    return ProfileModel(
      userId: json['user_id'] as String,
      username: json['username'] as String? ?? 'Người dùng',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String? ?? 'CUSTOMER',
      address: json['address'] as String?,
      locationText: json['location_text'] as String?,
      locationLatitude: (json['location_latitude'] as num?)?.toDouble(),
      locationLongitude: (json['location_longitude'] as num?)?.toDouble(),
      openingHour: json['opening_hour'] as String?,
      closingHour: json['closing_hour'] as String?,
      payoutBankCode: json['payout_bank_code'] as String?,
      payoutAccountNumber: json['payout_account_number'] as String?,
      email: authEmail,
      phone: authPhone,
    );
  }

  Map<String, dynamic> toUpdatePayload() {
    final Map<String, dynamic> payload = {
      'username': username,
      'bio': bio,
      'address': address,
      'avatar_url': avatarUrl,
      'location_latitude': locationLatitude,
      'location_longitude': locationLongitude,
      'location_text': locationText,
    };

    if (role?.toUpperCase() == 'PROVIDER') {
      payload.addAll({
        'opening_hour': _normalizeTime(openingHour),
        'closing_hour': _normalizeTime(closingHour),
        'payout_bank_code': payoutBankCode,
        'payout_account_number': payoutAccountNumber,
      });
    }

    return payload;
  }

  String? _normalizeTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(timeStr)) return timeStr;
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(timeStr)) return '$timeStr:00';
    return timeStr;
  }

  ProfileModel copyWith({
    String? username,
    String? avatarUrl,
    String? bio,
    String? role,
    String? address,
    String? locationText,
    double? locationLatitude,
    double? locationLongitude,
    String? openingHour,
    String? closingHour,
    String? payoutBankCode,
    String? payoutAccountNumber,
    String? email,
    String? phone,
  }) {
    return ProfileModel(
      userId: this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      address: address ?? this.address,
      locationText: locationText ?? this.locationText,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      openingHour: openingHour ?? this.openingHour,
      closingHour: closingHour ?? this.closingHour,
      payoutBankCode: payoutBankCode ?? this.payoutBankCode,
      payoutAccountNumber: payoutAccountNumber ?? this.payoutAccountNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
