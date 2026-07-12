// lib/features/booking/booking_service_screen.dart

// lib/features/booking/booking_service_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/booking/booking_service.dart';
import '../../services/payment/vnpay_service.dart';

import '../../widgets/payment/vietqr_payment.dart';
import '../../widgets/booking/booking_service_summary_card.dart';
import '../../widgets/booking/booking_schedule_tile.dart';
import '../../widgets/booking/booking_address_input.dart';
import '../../widgets/booking/booking_notes_input.dart';
import '../../widgets/booking/booking_payment_selector.dart';
import '../../widgets/booking/booking_bill_details_section.dart';
import '../../widgets/booking/booking_bottom_action_bar.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String? providerName;
  final String serviceTitle;
  final String packageName;
  final String customerId;
  final String providerId;
  final String? serviceType;
  final DateTime scheduledAt;
  final int totalPrice;
  final String? serviceImageUrl;

  const BookingScreen({
    super.key,
    required this.serviceId,
    this.providerName,
    required this.serviceTitle,
    required this.packageName,
    required this.customerId,
    required this.providerId,
    required this.scheduledAt,
    required this.totalPrice,
    this.serviceType,
    this.serviceImageUrl,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  final VNPayService _vnPayService = VNPayService();

  late TextEditingController _addressController;
  final _notesController = TextEditingController();

  int _selectedPaymentMethod = 0; // 0: VietQR, 1: Thẻ, 2: Tiền mặt, 3: VNPAY
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: "Landmark 81, Vinhomes Central Park, Phường 22, Quận Bình Thạnh",
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _selectedPaymentLabel() {
    switch (_selectedPaymentMethod) {
      case 1:
        return 'Thẻ Tín dụng / Ghi nợ';
      case 2:
        return 'Tiền mặt sau dịch vụ';
      case 3:
        return 'Cổng thanh toán VNPAY';
      default:
        return 'Chuyển khoản Online (VietQR)';
    }
  }

  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND";
  }

  void _processBookingAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final int finalCalculatedPrice = widget.totalPrice;
    final paymentLabel = _selectedPaymentLabel();

    try {
      final bookingResult = await _bookingService.createBooking(
        serviceId: widget.serviceId,
        customerId: widget.customerId,
        providerId: widget.providerId,
        totalPrice: finalCalculatedPrice,
        scheduledAt: widget.scheduledAt,
        serviceType: widget.serviceType,
      );

      final String? confirmedBookingId =
          (bookingResult != null && bookingResult['booking_id'] != null)
          ? bookingResult['booking_id'].toString()
          : await _bookingService.getLatestBookingId(widget.customerId);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (confirmedBookingId == null) {
        throw Exception("Could not retrieve booking ID after creation.");
      }

      final String trackingMemo = confirmedBookingId
          .substring(0, 8)
          .toUpperCase();
      final rootNavigator = Navigator.of(context);

      if (_selectedPaymentMethod == 0) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Thanh toán đơn hàng')),
              body: Center(
                child: VietQRPaymentWidget(
                  memo: trackingMemo,
                  paymentAmount: finalCalculatedPrice,
                  providerBankCode: 'bidv',
                  providerBankAccount: '8821165401',
                  onSimulateSuccess: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Giả lập thanh toán thành công',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        content: Text(
                          'Hệ thống ghi nhận thanh toán thành công cho dịch vụ ${widget.serviceTitle} theo hình thức mã định danh VietQR ($trackingMemo).',
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              rootNavigator.popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004AC6),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Về Trang Chủ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      } else if (_selectedPaymentMethod == 3) {
        final paymentUrl = await _vnPayService.createPaymentUrl(
          bookingId: confirmedBookingId,
          amount: finalCalculatedPrice,
          orderInfo: 'Thanh toan don hang ${widget.serviceTitle}',
        );
        if (paymentUrl != null) {
          await _vnPayService.openVNPay(paymentUrl);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể khởi tạo thanh toán VNPAY.'),
              ),
            );
          }
        }
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF004AC6)),
                SizedBox(width: 8),
                Text(
                  'Đặt lịch thành công',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Text(
              'Lịch hẹn dịch vụ ${widget.serviceTitle} vào ngày ${DateFormat('dd/MM/yyyy HH:mm').format(widget.scheduledAt)} đã được ghi nhận thành công theo hình thức $paymentLabel.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  rootNavigator.popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Về Trang Chủ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu đơn đặt lịch. Vui lòng thử lại sau.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color outlineVariant = Color(0xFFC3C6D7);

    final double serviceFee = widget.totalPrice.toDouble();

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text(
          'Xác nhận đặt lịch',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: outlineVariant.withAlpha(127), height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    BookingServiceSummaryCard(
                      serviceTitle: widget.serviceTitle,
                      packageName: widget.packageName,
                      serviceImageUrl: widget.serviceImageUrl,
                    ),
                    const SizedBox(height: 20),
                    BookingScheduleTile(scheduledAt: widget.scheduledAt),
                    const SizedBox(height: 20),
                    const Text(
                      'Địa điểm làm việc',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    BookingAddressInput(controller: _addressController),
                    const SizedBox(height: 20),
                    const Text(
                      'Ghi chú cho kỹ thuật viên',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    BookingNotesInput(controller: _notesController),
                    const SizedBox(height: 20),
                    const Text(
                      'Phương thức thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    BookingPaymentSelector(
                      selectedMethod: _selectedPaymentMethod,
                      onMethodChanged: (value) =>
                          setState(() => _selectedPaymentMethod = value),
                    ),
                    const SizedBox(height: 20),
                    BookingBillDetailsSection(
                      packageName: widget.packageName,
                      serviceFee: serviceFee,
                      totalAmount: serviceFee,
                      formatCurrency: _formatCurrency,
                    ),
                  ],
                ),
              ),
            ),
            BookingBottomActionBar(
              totalAmount: serviceFee,
              isSubmitting: _isSubmitting,
              onSubmitPressed: _processBookingAction,
              formatCurrency: _formatCurrency,
            ),
          ],
        ),
      ),
    );
  }
}
