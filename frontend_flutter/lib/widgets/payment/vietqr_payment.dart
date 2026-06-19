// lib/widget/payment/vietqr_payment.dart

import 'package:flutter/material.dart';
import 'package:vietqr_gen/vietqr_generator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/bank_mapper.dart';

const String myAltBankCode = 'bidv';
const String myAltBankAccount = '8821165401';

class VietQRPaymentWidget extends StatelessWidget {
  final String memo;
  final int paymentAmount;
  final String? providerBankCode;
  final String? providerBankAccount;

  const VietQRPaymentWidget({
    Key? key,
    required this.memo,
    required this.paymentAmount,
    this.providerBankCode,
    this.providerBankAccount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String napasPayload = VietQR.generate(
      bank: BankMapper.fromString(
        (providerBankCode != null && providerBankCode!.isNotEmpty)
            ? providerBankCode!
            : myAltBankCode,
      ),
      accountNumber:
          (providerBankAccount != null && providerBankAccount!.isNotEmpty)
          ? providerBankAccount!
          : myAltBankAccount,
      amount: paymentAmount.toDouble(),
      message: 'BROKERVIET $memo',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: QrImageView(
            data: napasPayload,
            version: QrVersions.auto,
            size: 260.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nội dung chuyển khoản: BROKERVIET $memo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
