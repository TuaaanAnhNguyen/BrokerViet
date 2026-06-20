// lib/features/booking/booking_service_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/booking/booking_service.dart';
import '../../widgets/payment/vietqr_payment.dart';

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
  final String? serviceImageUrl; // Added to make the header image dynamic

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
  late TextEditingController _addressController;
  final _notesController = TextEditingController();

  int _selectedPaymentMethod = 0; // 0: VietQR, 1: Thẻ, 2: Tiền mặt
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
      default:
        return 'Chuyển khoản Online (VietQR)';
    }
  }

  void _processBookingAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final paymentLabel = _selectedPaymentLabel();
    debugPrint('Payment method selected: $paymentLabel');

    // Calculate final billing amount matching UI breakdown
    final double serviceFee = widget.totalPrice.toDouble();
    const double platformFee = 15000;
    final double discount = serviceFee * 0.10;
    final int finalCalculatedAmount = (serviceFee + platformFee - discount).toInt();

    try {
      // 1. Call your Supabase Edge Function / Service table insert
      final bookingResult = await _bookingService.createBooking(
        serviceId: widget.serviceId,
        customerId: widget.customerId,
        providerId: widget.providerId,
        totalPrice: finalCalculatedAmount, // Use final matching amount
        scheduledAt: widget.scheduledAt,
        serviceType: widget.serviceType,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // Extract generated data or fall back to local random values for execution tracking
      final String trackingMemo = (bookingResult != null && bookingResult['booking_id'] != null)
          ? bookingResult['booking_id'].toString().substring(0, 8).toUpperCase()
          : 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

      // 2. Routing logic depending on chosen payment method
      if (_selectedPaymentMethod == 0) {
        // Option 0: VietQR route -> Send straight to transaction validation screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Thanh toán đơn hàng')),
              body: Center(
                child: VietQRPaymentWidget(
                  memo: trackingMemo,
                  paymentAmount: finalCalculatedAmount,
                  providerBankCode: 'bidv', // Change or fetch dynamically if needed
                  providerBankAccount: '8821165401',
                ),
              ),
            ),
          ),
        );
      } else {
        // Options 1 & 2: Cash/Card Route -> Show standard success modal back to root home screen
        final rootNavigator = Navigator.of(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              style: const TextStyle(color: Color(0xFF434655)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Về Trang Chủ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      debugPrint("Booking Execution Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lưu đơn đặt lịch. Vui lòng thử lại sau.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color surfaceColor = Color(0xFFF8F9FF);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    final double serviceFee = widget.totalPrice.toDouble();
    const double platformFee = 15000;
    final double discount = serviceFee * 0.10;
    final double totalAmount = serviceFee + platformFee - discount;

    String formatCurrency(double amount) {
      return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND";
    }

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text(
          'Xác nhận đặt lịch',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: outlineVariant.withValues(alpha: 0.5), height: 1),
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
            // Scrollable Main Content Form Group
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 1. Dynamic Summary Block
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFE5EEFF),
                              image: widget.serviceImageUrl != null && widget.serviceImageUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(widget.serviceImageUrl!),
                                      fit: BoxFit.cover,
                                  )
                                  : null,
                            ),
                            child: widget.serviceImageUrl == null || widget.serviceImageUrl!.isEmpty
                                ? const Icon(Icons.build_circle_outlined, color: primaryColor, size: 36)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CHI TIẾT ĐƠN ĐẶT DỊCH VỤ',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.serviceTitle,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gói: ${widget.packageName}',
                                  style: const TextStyle(color: bodyText, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Clean Appointment Slot View (Replaces redundant manual selectors)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: primaryColor, size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thời gian đã chọn lịch',
                                style: TextStyle(fontSize: 12, color: bodyText),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('EEEE, dd MMMM, yyyy - HH:mm', 'vi').format(widget.scheduledAt),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. Location Input Block
                    const Text(
                      'Địa điểm làm việc',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      validator: (value) => value!.isEmpty ? 'Vui lòng nhập địa chỉ cụ thể' : null,
                      style: const TextStyle(fontSize: 14, color: darkText),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on, color: primaryColor),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _addressController.text =
                                  "Landmark 81, Vinhomes Central Park, Phường 22, Quận Bình Thạnh");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF39B8FD),
                              foregroundColor: const Color(0xFF004666),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Hiện tại', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Instruction Notes Area
                    const Text(
                      'Ghi chú cho kỹ thuật viên',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Mô tả thêm về tình trạng máy hoặc hướng dẫn đường đi...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 5. Payment Selection Grid Rows
                    const Text(
                      'Phương thức thanh toán',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentRow(0, Icons.qr_code_2, 'Chuyển khoản Online (VietQR)',
                        'Quét mã QR nhanh chóng qua ứng dụng ngân hàng', primaryColor, outlineVariant),
                    const SizedBox(height: 8),
                    _buildPaymentRow(1, Icons.credit_card, 'Thẻ Tín dụng / Ghi nợ',
                        'Visa, Mastercard, JCB', primaryColor, outlineVariant),
                    const SizedBox(height: 8),
                    _buildPaymentRow(2, Icons.payments, 'Tiền mặt sau dịch vụ',
                        'Thanh toán sau khi hoàn thành sửa chữa', primaryColor, outlineVariant),
                    const SizedBox(height: 20),

                    // 6. Cost Breakdown Invoice Detail Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chi tiết hóa đơn',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText),
                          ),
                          const SizedBox(height: 12),
                          _buildBillRow('Phí dịch vụ (${widget.packageName})', formatCurrency(serviceFee), bodyText),
                          const SizedBox(height: 6),
                          _buildBillRow('Phí nền tảng', formatCurrency(platformFee), bodyText),
                          const SizedBox(height: 6),
                          _buildBillRow('Khuyến mãi giảm giá (PROMO10)', '-${formatCurrency(discount)}', primaryColor, isMedium: true),
                          const Divider(height: 24, thickness: 0.5, color: outlineVariant),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tổng cộng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                              Text(formatCurrency(totalAmount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 7. Standardized Solid Action Checkout Bar Footer (No more overlapping text!)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: outlineVariant.withValues(alpha: 0.5))),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -4))
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Giá thanh toán cuối', style: TextStyle(fontSize: 12, color: bodyText)),
                            Text(formatCurrency(totalAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(Icons.verified_user, color: bodyText, size: 14),
                            SizedBox(width: 4),
                            Text('Thanh toán bảo mật', style: TextStyle(fontSize: 12, color: bodyText)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _processBookingAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Xác nhận đặt lịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 11, color: bodyText),
                        children: [
                          TextSpan(text: 'Bằng việc nhấn nút "Xác nhận đặt lịch", bạn đồng ý với '),
                          TextSpan(text: 'Điều khoản dịch vụ', style: TextStyle(color: primaryColor, decoration: TextDecoration.underline)),
                          TextSpan(text: ' của chúng tôi.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(int index, IconData icon, String title, String subtitle, Color activeColor, Color defaultOutline) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? activeColor : defaultOutline.withValues(alpha: 0.6), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: defaultOutline.withValues(alpha: 0.5)),
              ),
              child: Icon(icon, color: isSelected ? activeColor : const Color(0xFF434655)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B1C30))),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF434655), fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? activeColor : defaultOutline, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: activeColor),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String cost, Color textColor, {bool isMedium = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: isMedium ? FontWeight.w500 : FontWeight.normal)),
        Text(cost, style: TextStyle(color: textColor, fontSize: 13, fontWeight: isMedium ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}