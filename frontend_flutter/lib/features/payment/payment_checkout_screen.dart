// lib/features/payment/payment_checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/payment/vietqr_payment.dart';
import '../../services/notification/notification_service.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final String bookingId;
  final int amount;
  final String paymentMemo;
  final String? providerBankCode;
  final String? providerAccountNumber;

  const PaymentCheckoutScreen({
    Key? key,
    required this.bookingId,
    required this.amount,
    required this.paymentMemo,
    this.providerBankCode,
    this.providerAccountNumber,
  }) : super(key: key);

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _subscribeToPaymentStatus();
  }

  void _subscribeToPaymentStatus() {
    _supabase
        .from('payments')
        .stream(primaryKey: ['payment_id'])
        .eq('payment_memo', widget.paymentMemo)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final currentStatus = data.first['status'] as String;
            if (currentStatus == 'completed' && mounted) {
              setState(() {
                _isPaid = true;
              });
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh Toán Đơn Hàng'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _isPaid ? _buildSuccessState() : _buildPaymentState(),
        ),
      ),
    );
  }

  Widget _buildPaymentState() {
    return Column(
      children: [
        VietQRPaymentWidget(
          memo: widget.paymentMemo,
          paymentAmount: widget.amount,
          providerBankCode: widget.providerBankCode,
          providerBankAccount: widget.providerAccountNumber,
        ),
        const SizedBox(height: 20),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(height: 12),
        const Text(
          'Đang chờ giao dịch từ ngân hàng...',
          style: TextStyle(color: Colors.grey),
        ),
        
        // --- STUDENT TEST TRIGGER BUTTON ---
        const SizedBox(height: 32),
        TextButton.icon(
          icon: const Icon(Icons.bug_report, color: Colors.orange),
          label: const Text('Simulate Bank Callback (Testing Only)', style: TextStyle(color: Colors.orange)),
          onPressed: _mockBankNotificationCallback,
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        const SizedBox(height: 16),
        const Text(
          'Thanh Toán Thành Công!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Đơn hàng #${widget.bookingId.substring(0, 8)} đã được xác nhận.'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text('Quay lại trang chủ'),
        ),
      ],
    );
  }

  Future<void> _mockBankNotificationCallback() async {
    try {
      await _supabase
          .from('payments')
          .update({'status': 'completed'})
          .eq('payment_memo', widget.paymentMemo);
          
      // Fetch booking details to get customer and provider IDs
      final bookingRes = await _supabase
          .from('bookings')
          .select('customer_id, provider_id, service_type')
          .eq('booking_id', widget.bookingId)
          .maybeSingle();

      if (bookingRes != null) {
        final customerId = bookingRes['customer_id'] as String;
        final providerId = bookingRes['provider_id'] as String;
        final serviceType = bookingRes['service_type'] ?? 'Dịch vụ';

        // Notify Customer
        await _notificationService.createNotification(
          userId: customerId,
          title: 'Thanh toán thành công',
          content: 'Đơn hàng "$serviceType" (#${widget.bookingId.substring(0, 8)}) đã được xác nhận thanh toán.',
        );

        // Notify Provider
        await _notificationService.createNotification(
          userId: providerId,
          title: 'Đã nhận thanh toán',
          content: 'Khách hàng đã thanh toán thành công cho dịch vụ "$serviceType".',
        );
      }
          
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulated successful bank transfer update!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Simulation error: $e')),
      );
    }
  }
}