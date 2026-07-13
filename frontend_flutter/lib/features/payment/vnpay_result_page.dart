import 'package:flutter/material.dart';
import '../../services/payment/vnpay_service.dart';


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
      print("Checking payment for ${widget.bookingId}");

      final status =
      await _vnPayService.getPaymentStatus(widget.bookingId);

      print("Received status = $status");

      if (!mounted) return;

      setState(() {
        _status = status;
      });
    } catch (e, s) {
      print(e);
      print(s);

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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildStatusContent(primaryColor),
        ),
      ),
    );
  }

  Widget _buildStatusContent(Color primaryColor) {
    switch (_status) {
      case 'PENDING':
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text('Đang kiểm tra trạng thái thanh toán...'),
          ],
        );
      case 'COMPLETED':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Thanh toán thành công!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Đơn hàng #${widget.bookingId.substring(0, 8)} đã được thanh toán.'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Quay lại trang chủ'),
              ),
            ),
          ],
        );
      case 'FAILED':
      case 'EXPIRED':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 80),
            const SizedBox(height: 16),
            Text(
              _status == 'EXPIRED' ? 'Thanh toán đã bị hủy' : 'Thanh toán thất bại',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Vui lòng thử lại hoặc chọn phương thức khác.'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Thử lại'),
              ),
            ),
          ],
        );
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline, color: Colors.orange, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Trạng thái không xác định',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Chúng tôi chưa nhận được phản hồi từ VNPay. Vui lòng kiểm tra lại sau.'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Quay lại trang chủ'),
              ),
            ),
          ],
        );
    }
  }
}
