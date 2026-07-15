import 'package:flutter/material.dart';
import '../../../services/payment/vnpay_service.dart';
import '../../widgets/payment/payment_pending_widget.dart';
import '../../widgets/payment/payment_success_widget.dart';
import '../../widgets/payment/payment_failed_widget.dart';
import '../../widgets/payment/payment_unknown_widget.dart';

class VNPayResultPage extends StatefulWidget {
  final String bookingId;

  const VNPayResultPage({
    super.key,
    required this.bookingId,
  });

  @override
  State<VNPayResultPage> createState() => _VNPayResultPageState();
}

class _VNPayResultPageState extends State<VNPayResultPage> {
  final _vnPayService = VNPayService();
  String _status = 'PENDING';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      debugPrint("Checking payment for ${widget.bookingId}");
      final status = await _vnPayService.getPaymentStatus(widget.bookingId);
      debugPrint("Received status = $status");

      if (!mounted) return;
      setState(() {
        _status = status;
      });
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());

      if (!mounted) return;
      setState(() {
        _status = "FAILED";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF004AC6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả thanh toán'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView( // Đảm bảo không bị lỗi tràn màn hình (Overflow) trên các máy nhỏ
          padding: const EdgeInsets.all(24.0),
          child: _buildStatusContent(primaryColor),
        ),
      ),
    );
  }

  Widget _buildStatusContent(Color primaryColor) {
    switch (_status) {
      case 'PENDING':
        return const PaymentPendingWidget();
      case 'COMPLETED':
        return PaymentSuccessWidget(
          bookingId: widget.bookingId,
          primaryColor: primaryColor,
        );
      case 'FAILED':
      case 'EXPIRED':
        return PaymentFailedWidget(
          status: _status,
          primaryColor: primaryColor,
        );
      default:
        return PaymentUnknownWidget(
          primaryColor: primaryColor,
        );
    }
  }
}