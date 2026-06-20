// lib/models/payment_model.dart

enum PaymentStatus { pending, completed, failed, expired }

class PaymentModel {
  final String paymentId;
  final String bookingId;
  final String payerId;
  final int amount;
  final String targetBankCode;
  final String targetAccountNumber;
  final String paymentMemo;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? referenceTransactionId;

  PaymentModel({
    required this.paymentId,
    required this.bookingId,
    required this.payerId,
    required this.amount,
    required this.targetBankCode,
    required this.targetAccountNumber,
    required this.paymentMemo,
    required this.status,
    required this.createdAt,
    this.referenceTransactionId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['payment_id'] as String,
      bookingId: json['booking_id'] as String,
      payerId: json['payer_id'] as String,
      amount: (json['amount'] as num).toInt(),
      targetBankCode: json['target_bank_code'] as String,
      targetAccountNumber: json['target_account_number'] as String,
      paymentMemo: json['payment_memo'] as String,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      referenceTransactionId: json['reference_transaction_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'payer_id': payerId,
      'amount': amount,
      'target_bank_code': targetBankCode,
      'target_account_number': targetAccountNumber,
      'payment_memo': paymentMemo,
      'status': status.name,
    };
  }

  static PaymentStatus _parseStatus(String statusStr) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == statusStr.toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }
}