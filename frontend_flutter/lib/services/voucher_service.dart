import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/voucher_model.dart';

class VoucherValidationResult {
  final bool valid;
  final String? voucherId;
  final double? discountAmount;
  final double? finalPrice;
  final String? error;

  const VoucherValidationResult({
    required this.valid,
    this.voucherId,
    this.discountAmount,
    this.finalPrice,
    this.error,
  });
}

class VoucherException implements Exception {
  final String message;

  VoucherException(this.message);

  @override
  String toString() => message;
}

class VoucherService {
  final _client = Supabase.instance.client;

  dynamic _parseData(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }
    return data;
  }

  Map<String, dynamic> _handleResponse(
    FunctionResponse response, {
    bool useValidKey = false,
  }) {
    if (response.status != 200) {
      final parsed = _parseData(response.data);
      if (parsed is Map<String, dynamic>) {
        final message = parsed['error']?.toString();
        if (message != null && message.isNotEmpty) {
          throw VoucherException(message);
        }
      }
      throw VoucherException('Yêu cầu thất bại (mã ${response.status})');
    }

    final parsed = _parseData(response.data);
    if (parsed is! Map<String, dynamic>) {
      throw VoucherException('Phản hồi không hợp lệ từ máy chủ');
    }

    if (useValidKey) {
      final valid = parsed['valid'] == true;
      if (!valid) {
        throw VoucherException(
          parsed['error']?.toString() ?? 'Mã giảm giá không hợp lệ',
        );
      }
      return parsed;
    }

    if (parsed['success'] != true) {
      throw VoucherException(parsed['error']?.toString() ?? 'Yêu cầu thất bại');
    }

    return parsed;
  }

  List<VoucherModel> _parseVoucherList(dynamic data) {
    if (data is String) {
      data = jsonDecode(data);
    }

    if (data is! List) {
      throw VoucherException('Phản hồi danh sách voucher không hợp lệ');
    }

    return data
        .map((item) => VoucherModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String> createVoucher({
    required String providerId,
    required String code,
    required String discountType,
    required double discountValue,
    required DateTime startDate,
    required DateTime endDate,
    double? maxDiscountAmount,
    double minOrderValue = 0,
    int? usageLimit,
    int usageLimitPerUser = 1,
    List<String>? applicableServiceIds,
  }) async {
    final response = await _client.functions.invoke(
      'create-provider-voucher',
      method: HttpMethod.post,
      body: {
        'provider_id': providerId,
        'code': code,
        'discount_type': discountType,
        'discount_value': discountValue,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        if (maxDiscountAmount != null) 'max_discount_amount': maxDiscountAmount,
        'min_order_value': minOrderValue,
        if (usageLimit != null) 'usage_limit': usageLimit,
        'usage_limit_per_user': usageLimitPerUser,
        if (applicableServiceIds != null)
          'applicable_service_ids': applicableServiceIds,
      },
    );

    final data = _handleResponse(response);
    final voucherId = data['voucher_id']?.toString();
    if (voucherId == null || voucherId.isEmpty) {
      throw VoucherException('Không nhận được mã voucher sau khi tạo');
    }
    return voucherId;
  }

  Future<List<VoucherModel>> getProviderVouchers(String providerId) async {
    final response = await _client.functions.invoke(
      'get-provider-vouchers',
      method: HttpMethod.get,
      queryParameters: {'provider_id': providerId},
    );

    if (response.status != 200) {
      final parsed = _parseData(response.data);
      if (parsed is Map<String, dynamic>) {
        throw VoucherException(
          parsed['error']?.toString() ?? 'Không thể tải danh sách voucher',
        );
      }
      throw VoucherException('Không thể tải danh sách voucher');
    }

    return _parseVoucherList(response.data);
  }

  Future<void> updateVoucherStatus(String voucherId, String status) async {
    final response = await _client.functions.invoke(
      'update-voucher-status',
      method: HttpMethod.post,
      body: {'voucher_id': voucherId, 'status': status},
    );

    _handleResponse(response);
  }

  Future<List<VoucherModel>> getActiveVouchersForService(
    String serviceId,
  ) async {
    final response = await _client.functions.invoke(
      'get-active-vouchers-for-service',
      method: HttpMethod.get,
      queryParameters: {'service_id': serviceId},
    );

    if (response.status != 200) {
      final parsed = _parseData(response.data);
      if (parsed is Map<String, dynamic>) {
        throw VoucherException(
          parsed['error']?.toString() ?? 'Không thể tải voucher khả dụng',
        );
      }
      throw VoucherException('Không thể tải voucher khả dụng');
    }

    return _parseVoucherList(response.data);
  }

  Future<VoucherValidationResult> validateVoucher({
    required String code,
    required String providerId,
    required String customerId,
    required String serviceId,
    required double orderValue,
  }) async {
    final response = await _client.functions.invoke(
      'validate-voucher',
      method: HttpMethod.post,
      body: {
        'code': code,
        'provider_id': providerId,
        'customer_id': customerId,
        'service_id': serviceId,
        'order_value': orderValue,
      },
    );

    if (response.status != 200) {
      final parsed = _parseData(response.data);
      if (parsed is Map<String, dynamic>) {
        return VoucherValidationResult(
          valid: false,
          error: parsed['error']?.toString() ?? 'Mã giảm giá không hợp lệ',
        );
      }
      return const VoucherValidationResult(
        valid: false,
        error: 'Không thể xác thực mã giảm giá',
      );
    }

    final parsed = _parseData(response.data);
    if (parsed is! Map<String, dynamic>) {
      return const VoucherValidationResult(
        valid: false,
        error: 'Phản hồi không hợp lệ từ máy chủ',
      );
    }

    if (parsed['valid'] != true) {
      return VoucherValidationResult(
        valid: false,
        error: parsed['error']?.toString() ?? 'Mã giảm giá không hợp lệ',
      );
    }

    double? parseNumeric(dynamic value) {
      if (value == null) return null;
      return double.parse(value.toString());
    }

    return VoucherValidationResult(
      valid: true,
      voucherId: parsed['voucher_id']?.toString(),
      discountAmount: parseNumeric(parsed['discount_amount']),
      finalPrice: parseNumeric(parsed['final_price']),
    );
  }

  //   Future<String> createBookingWithVoucher({
  //     required String customerId,
  //     required String providerId,
  //     required String serviceId,
  //     required double price,
  //     String? voucherCode,
  //     DateTime? bookingTime,
  //   }) async {
  //     final response = await _client.functions.invoke(
  //       'create-booking',
  //       method: HttpMethod.post,
  //       body: {
  //         'customer_id': customerId,
  //         'provider_id': providerId,
  //         'service_id': serviceId,
  //         'price': price,
  //         if (voucherCode != null) 'voucher_code': voucherCode,
  //         if (bookingTime != null) 'booking_time': bookingTime.toIso8601String(),
  //       },
  //     );

  //     final data = _handleResponse(response);
  //     final bookingId = data['booking_id']?.toString();
  //     if (bookingId == null || bookingId.isEmpty) {
  //       throw VoucherException('Không nhận được mã đặt lịch sau khi tạo');
  //     }
  //     return bookingId;
  //   }
}
