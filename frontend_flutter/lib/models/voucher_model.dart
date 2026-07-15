// lib/models/voucher_model.dart

class VoucherModel {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final double? maxDiscountAmount;
  final double minOrderValue;
  final int? usageLimit;
  final int usageLimitPerUser;
  final int usedCount;
  final List<String>? applicableServiceIds;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    required this.minOrderValue,
    this.usageLimit,
    required this.usageLimitPerUser,
    required this.usedCount,
    this.applicableServiceIds,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
  });

  /// Postgres `timestamptz` trả về qua JSON thường có dạng
  /// "2026-08-01 00:00:00+07" (dấu cách thay vì "T", offset thiếu ":00").
  /// DateTime.parse() của Dart không tự xử lý được các dạng này,
  /// nên cần chuẩn hoá về ISO 8601 trước khi parse.
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      throw FormatException('Giá trị ngày giờ bị null');
    }

    var str = value.toString().trim();

    // Thay dấu cách giữa ngày và giờ thành "T" nếu chưa có
    if (!str.contains('T')) {
      str = str.replaceFirst(' ', 'T');
    }

    // Chuẩn hoá offset dạng "+07" hoặc "-07" thành "+07:00" / "-07:00"
    final offsetMatch = RegExp(r'([+-]\d{2})$').firstMatch(str);
    if (offsetMatch != null) {
      str = str.replaceRange(
        offsetMatch.start,
        offsetMatch.end,
        '${offsetMatch.group(1)}:00',
      );
    }

    return DateTime.parse(str);
  }

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    double? parseNumeric(dynamic value) {
      if (value == null) return null;
      return double.parse(value.toString());
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      return int.parse(value.toString());
    }

    return VoucherModel(
      id: json['id'].toString(),
      code: json['code']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? 'FIXED_AMOUNT',
      discountValue: double.parse(json['discount_value'].toString()),
      maxDiscountAmount: parseNumeric(json['max_discount_amount']),
      minOrderValue: parseNumeric(json['min_order_value']) ?? 0,
      usageLimit: json['usage_limit'] != null
          ? parseInt(json['usage_limit'])
          : null,
      usageLimitPerUser: parseInt(json['usage_limit_per_user']),
      usedCount: parseInt(json['used_count']),
      applicableServiceIds: (json['applicable_service_ids'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      startDate: _parseDateTime(json['start_date']),
      endDate: _parseDateTime(json['end_date']),
      status: json['status']?.toString() ?? 'ACTIVE',
      createdAt: json['created_at'] != null
          ? _parseDateTime(json['created_at'])
          : DateTime.now(),
    );
  }

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isUsageMaxedOut => usageLimit != null && usedCount >= usageLimit!;

  String get displayDiscount {
    if (discountType == 'PERCENTAGE') {
      return 'Giảm ${discountValue.toStringAsFixed(0)}%';
    }
    return 'Giảm ${_formatVnd(discountValue)}';
  }

  /// Same VND formatting pattern as [ServiceModel.fromJson].
  static String _formatVnd(double value) {
    return "${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}₫";
  }

  VoucherModel copyWith({String? status, int? usedCount}) {
    return VoucherModel(
      id: id,
      code: code,
      discountType: discountType,
      discountValue: discountValue,
      maxDiscountAmount: maxDiscountAmount,
      minOrderValue: minOrderValue,
      usageLimit: usageLimit,
      usageLimitPerUser: usageLimitPerUser,
      usedCount: usedCount ?? this.usedCount,
      applicableServiceIds: applicableServiceIds,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
