// lib/widget/payment/vietqr_payment.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vietqr_gen/vietqr_generator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/bank_mapper.dart';

const String myAltBankCode = 'bidv';
const String myAltBankAccount = '8821165401';

class VietQRPaymentWidget extends StatefulWidget {
  final String memo;
  final int paymentAmount;
  final String? providerBankCode;
  final String? providerBankAccount;
  final VoidCallback? onSimulateSuccess;

  const VietQRPaymentWidget({
    Key? key,
    required this.memo,
    required this.paymentAmount,
    this.providerBankCode,
    this.providerBankAccount,
    this.onSimulateSuccess,
  }) : super(key: key);

  @override
  State<VietQRPaymentWidget> createState() => _VietQRPaymentWidgetState();
}

class _VietQRPaymentWidgetState extends State<VietQRPaymentWidget> {
  final GlobalKey _qrKey = GlobalKey(); // Key to capture the QR boundary
  bool _isSimulating = false;
  bool _isSharing = false;

  // Helper to format currency
  String _formatCurrency(int amount) {
    return "${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND";
  }

  // Captures the QR image and shares it natively
  Future<void> _shareQrCode() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Find the render object and capture as image pixels
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Temporarily write file to share it natively
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/vietqr_payment_${widget.memo}.png',
      ).create();
      await file.writeAsBytes(buffer);

      // Trigger native share sheet (Allows saving to photos or sharing to bank app)
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Mã QR Thanh toán đơn hàng BROKERVIET ${widget.memo}');
    } catch (e) {
      debugPrint("Error capturing/sharing QR code: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xuất ảnh QR. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String activeBankCode =
        (widget.providerBankCode != null && widget.providerBankCode!.isNotEmpty)
        ? widget.providerBankCode!
        : myAltBankCode;

    final String activeBankAccount =
        (widget.providerBankAccount != null &&
            widget.providerBankAccount!.isNotEmpty)
        ? widget.providerBankAccount!
        : myAltBankAccount;

    final String napasPayload = VietQR.generate(
      bank: BankMapper.fromString(activeBankCode),
      accountNumber: activeBankAccount,
      amount: widget.paymentAmount.toDouble(),
      message: 'BROKERVIET ${widget.memo}',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Captured QR Image Frame
          RepaintBoundary(
            key: _qrKey,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header branding inside image
                  const Text(
                    'VIETQR QUICKPAY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF004AC6),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  QrImageView(
                    data: napasPayload,
                    version: QrVersions.auto,
                    size: 240.0,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(widget.paymentAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Interactive Share Utility Trigger
          OutlinedButton.icon(
            onPressed: _isSharing ? null : _shareQrCode,
            icon: _isSharing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_for_offline, size: 18),
            label: const Text(
              'Lưu / Chia sẻ mã QR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF004AC6),
              side: const BorderSide(color: Color(0xFF004AC6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Clear Instruction Details Invoice Breakdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFC3C6D7).withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THÔNG TIN CHUYỂN KHOẢN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004AC6),
                    letterSpacing: 1.1,
                  ),
                ),
                const Divider(height: 16),
                _buildInfoRow('Ngân hàng', activeBankCode.toUpperCase()),
                _buildInfoRow('Số tài khoản', activeBankAccount),
                _buildInfoRow('Số tiền', _formatCurrency(widget.paymentAmount)),
                _buildInfoRow(
                  'Nội dung',
                  'BROKERVIET ${widget.memo}',
                  isBoldValue: true,
                ),
              ],
            ),
          ),

          // ---- TESTING BLOCK ----
          const SizedBox(height: 20),
          if (widget.onSimulateSuccess != null)
            TextButton.icon(
              onPressed: _isSimulating
                  ? null
                  : () async {
                      setState(() => _isSimulating = true);
                      await Future.delayed(const Duration(seconds: 1));
                      widget.onSimulateSuccess!();
                      if (mounted) setState(() => _isSimulating = false);
                    },
              icon: _isSimulating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bug_report, size: 16, color: Colors.amber),
              label: const Text(
                '[Dev Option] Giả lập Thanh toán Thành công',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF434655), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: const Color(0xFF0B1C30),
                fontSize: 13,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
