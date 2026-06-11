// lib/features/booking/booking_service_screen.dart

import 'package:flutter/material.dart';
import '../../services/booking/booking_submission_service.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String serviceTitle;
  final String providerName;
  final String packageName;
  final String price;
  final String date;
  final String time;

  const BookingScreen({
    super.key,
    required this.serviceId,
    required this.serviceTitle,
    required this.providerName,
    required this.packageName,
    required this.price,
    required this.date,
    required this.time,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingSubmissionService _submissionService =
      BookingSubmissionService();
  late TextEditingController _addressController;
  final _notesController = TextEditingController();

  int _selectedDateIndex = 0;
  late String _selectedTime;
  int _selectedPaymentMethod = 0; // 0: VietQR, 1: Thẻ, 2: Tiền mặt
  bool _isSubmitting = false;

  final List<Map<String, String>> _dates = [
    {'month': 'Th10', 'day': '24', 'weekday': 'Th 5'},
    {'month': 'Th10', 'day': '25', 'weekday': 'Th 6'},
    {'month': 'Th10', 'day': '26', 'weekday': 'Th 7'},
    {'month': 'Th10', 'day': '27', 'weekday': 'Chủ Nhật'},
    {'month': 'Th10', 'day': '28', 'weekday': 'Th 2'},
  ];

  final List<String> _timeSlots = [
    "09:00 SA",
    "10:30 SA",
    "01:00 CH",
    "02:30 CH",
    "04:00 CH",
    "05:30 CH (Hết chỗ)",
  ];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: "Landmark 81, Vinhomes Central Park, Phường 22, Quận Bình Thạnh",
    );
    _selectedTime = widget.time;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<String> _selectedPaymentLabel() async {
    switch (_selectedPaymentMethod) {
      case 1:
        return 'Thẻ Tín dụng / Ghi nợ';
      case 2:
        return 'Tiền mặt sau dịch vụ';
      default:
        return 'Chuyển khoản Online (VietQR)';
    }
  }

  void _confirmBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final selectedDate =
        '${_dates[_selectedDateIndex]['day']} ${_dates[_selectedDateIndex]['month']}';
    final selectedPaymentMethod = await _selectedPaymentLabel();

    final success = await _submissionService.submitBooking(
      serviceId: widget.serviceId,
      serviceTitle: widget.serviceTitle,
      providerName: widget.providerName,
      packageName: widget.packageName,
      price: widget.price,
      scheduledDate: selectedDate,
      scheduledTime: _selectedTime,
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      paymentMethod: selectedPaymentMethod,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu đơn đặt lịch. Vui lòng thử lại sau.'),
        ),
      );
      return;
    }

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
          'Lịch hẹn dịch vụ ${widget.serviceTitle} vào ngày ${_dates[_selectedDateIndex]['day']} thg 10 lúc $_selectedTime đã được ghi nhận hệ thống.',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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


@override
Widget build(BuildContext context) {
  const Color primaryColor = Color(0xFF004AC6);
  const Color surfaceColor = Color(0xFFF8F9FF);
  const Color darkText = Color(0xFF0B1C30);
  const Color bodyText = Color(0xFF434655);
  const Color outlineVariant = Color(0xFFC3C6D7);

  // Tính toán lại hóa đơn dựa trên dữ liệu giá của ví dụ dịch vụ nhận vào
  final double serviceFee = widget.price.contains('1.200.000')
      ? 1200000
      : 450000;
  const double platformFee = 15000;
  final double discount = serviceFee * 0.10; // Giảm giá 10% từ mã PROMO10
  final double totalAmount = serviceFee + platformFee - discount;

  String formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND";
  }

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
        child: Container(
          color: outlineVariant.withValues(alpha: 0.5),
          height: 1,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: primaryColor),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: bodyText),
          onPressed: () {},
        ),
      ],
    ),
    body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
          children: [
            // 1. Summary Block (Thông tin dịch vụ)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFE5EEFF),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAwN6BAzPJqU5zEDXkeQ4R_YP2zSyDRqvkVWroXAj7OzI6PwYn8sLETf4IO1M6e-CkKLE6ZNVCegqwyt4Ghxmx0BphbcmK-DOkf_ULTwiuLLgLgVU7NTcL9GBAZ90taZ1fpA2OLokUdt-yJaQiaeIhDgmG4rx1YgXEN9FLTmGKVZeidlJ2unJJcFGb8O5W0D88WE-zvPjoivdDDc3kb8HuaUHFnux7IIF7Cj5xBIZOns3Q4grf-nUDiyEJYAH7wqvs3IaKEuxT-65_3',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SỬA CHỮA PHẦN CỨNG',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.serviceTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '4.9 (248 đánh giá) • 45-60 phút',
                              style: TextStyle(
                                color: bodyText.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Schedule Grid Selector
            const Text(
              'Chọn thời gian hẹn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedDateIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = index),
                    child: Container(
                      width: 64,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _dates[index]['month']!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.white70 : bodyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _dates[index]['day']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : darkText,
                            ),
                          ),
                          Text(
                            _dates[index]['weekday']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white70 : bodyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _timeSlots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.5,
              ),
              itemBuilder: (context, index) {
                final timeText = _timeSlots[index];
                final isFull = timeText.contains('(Hết chỗ)');
                final isSelected = _selectedTime == timeText && !isFull;

                return InkWell(
                  onTap: isFull
                      ? null
                      : () => setState(() => _selectedTime = timeText),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : (isFull ? Colors.transparent : Colors.white),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : outlineVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Text(
                      timeText.replaceAll(' (Hết chỗ)', ''),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: AppFontWeight.boldOrNormal(isSelected),
                        color: isSelected
                            ? Colors.white
                            : (isFull
                                  ? darkText.withValues(alpha: 0.3)
                                  : darkText),
                        decoration: isFull ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 3. Location Input Block
            const Text(
              'Địa điểm làm việc',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập địa chỉ cụ thể' : null,
              style: const TextStyle(fontSize: 14, color: darkText),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on, color: primaryColor),
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(
                        () => _addressController.text =
                            "Landmark 81, Vinhomes Central Park, Phường 22, Quận Bình Thạnh",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF39B8FD),
                      foregroundColor: const Color(0xFF004666),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Hiện tại',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
            const SizedBox(height: 24),

            // 4. Instruction Notes Area
            const Text(
              'Ghi chú cho kỹ thuật viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Mô tả thêm về tình trạng máy hoặc hướng dẫn đường đi...',
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
            const SizedBox(height: 24),

            // 5. Payment Matrix Rows
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentRow(
              0,
              Icons.qr_code_2,
              'Chuyển khoản Online (VietQR)',
              'Quét mã QR nhanh chóng qua ứng dụng ngân hàng',
              primaryColor,
              outlineVariant,
            ),
            const SizedBox(height: 8),
            _buildPaymentRow(
              1,
              Icons.credit_card,
              'Thẻ Tín dụng / Ghi nợ',
              'Visa, Mastercard, JCB',
              primaryColor,
              outlineVariant,
            ),
            const SizedBox(height: 8),
            _buildPaymentRow(
              2,
              Icons.payments,
              'Tiền mặt sau dịch vụ',
              'Thanh toán sau khi hoàn thành sửa chữa',
              primaryColor,
              outlineVariant,
            ),
            const SizedBox(height: 28),

            // 6. Detailed Bill Cost Breakdown Block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết hóa đơn',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBillRow(
                    'Phí dịch vụ (${widget.packageName})',
                    formatCurrency(serviceFee),
                    bodyText,
                  ),
                  const SizedBox(height: 6),
                  _buildBillRow(
                    'Phí nền tảng',
                    formatCurrency(platformFee),
                    bodyText,
                  ),
                  const SizedBox(height: 6),
                  _buildBillRow(
                    'Khuyến mãi giảm giá (PROMO10)',
                    '-${formatCurrency(discount)}',
                    primaryColor,
                    isMedium: true,
                  ),
                  const Divider(
                    height: 24,
                    thickness: 0.5,
                    color: outlineVariant,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      Text(
                        formatCurrency(totalAmount),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),

    // 7. Fixed Bottom Checkout Bar
    bottomSheet: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
        ),
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
                    const Text(
                      'Giá thanh toán cuối',
                      style: TextStyle(fontSize: 12, color: bodyText),
                    ),
                    Text(
                      formatCurrency(totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.verified_user, color: bodyText, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Thanh toán bảo mật',
                      style: TextStyle(
                        fontSize: 12,
                        color: bodyText.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Xác nhận đặt lịch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 11, color: bodyText),
                children: [
                  TextSpan(
                    text:
                        'Bằng việc nhấn nút "Xác nhận đặt lịch", bạn đồng ý với ',
                  ),
                  TextSpan(
                    text: 'Điều khoản dịch vụ',
                    style: TextStyle(
                      color: primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' của chúng tôi.'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPaymentRow(
  int index,
  IconData icon,
  String title,
  String subtitle,
  Color activeColor,
  Color defaultOutline,
) {
  final isSelected = _selectedPaymentMethod == index;
  return GestureDetector(
    onTap: () => setState(() => _selectedPaymentMethod = index),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? activeColor
              : defaultOutline.withValues(alpha: 0.6),
          width: isSelected ? 2 : 1,
        ),
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
            child: Icon(
              icon,
              color: isSelected ? activeColor : const Color(0xFF434655),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF434655),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? activeColor : defaultOutline,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}

Widget _buildBillRow(
  String label,
  String cost,
  Color textColor, {
  bool isMedium = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: isMedium ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      Text(
        cost,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: isMedium ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}
}

// Helper class giải quyết lỗi gán kiểu trong logic TextStyle
class AppFontWeight {
  static FontWeight boldOrNormal(bool condition) {
    return condition ? FontWeight.bold : FontWeight.normal;
  }
}
