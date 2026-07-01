import 'package:flutter/material.dart';
import '../../../models/provider_booking_model.dart';
import '../../../utils/booking_status_utils.dart';
import 'package:intl/intl.dart';

class BookingDetailSheet extends StatelessWidget {
  final ProviderBookingModel booking;

  const BookingDetailSheet({
    super.key,
    required this.booking,
  });

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color darkText = Color(0xFF0B1C30);
  static const Color bodyText = Color(0xFF434655);
  static const Color borderColor = Color(0xFFC3C6D7);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chi tiết lịch hẹn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BookingStatusUtils.getBackgroundColorForStatus(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    BookingStatusUtils.getLabelForStatus(booking.status),
                    style: TextStyle(
                      color: BookingStatusUtils.getTextColorForStatus(booking.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32, color: borderColor),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerInfo(),
                  const SizedBox(height: 24),
                  _buildServiceDetails(),
                  const SizedBox(height: 24),
                  _buildTimeline(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Message logic
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Nhắn tin cho khách hàng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: primaryColor.withValues(alpha: 0.1),
          backgroundImage: booking.customerAvatar != null
              ? NetworkImage(booking.customerAvatar!)
              : null,
          radius: 28,
          child: booking.customerAvatar == null
              ? Text(
                  booking.customerName.isNotEmpty
                      ? booking.customerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.customerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: bodyText),
                  const SizedBox(width: 4),
                  const Text(
                    '*** *** ****', // Masked phone
                    style: TextStyle(color: bodyText),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {},
                    child: const Text(
                      'Hiển thị',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetails() {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.serviceTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.calendar_today_outlined, 'Ngày hẹn:', booking.formattedDate),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.payments_outlined, 
            'Giá tiền:', 
            booking.price != null ? currencyFormat.format(booking.price) : 'Thỏa thuận',
            isValueBold: true,
            valueColor: primaryColor,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.location_on_outlined, 
            'Địa chỉ:', 
            booking.address ?? 'Không được cung cấp',
          ),
          if (booking.customerNotes != null && booking.customerNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Ghi chú của khách hàng:',
              style: TextStyle(fontSize: 13, color: bodyText, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              booking.customerNotes!,
              style: const TextStyle(fontSize: 14, color: darkText),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isValueBold = false, Color valueColor = darkText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: bodyText),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: bodyText, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiến trình',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          title: 'Khách yêu cầu dịch vụ',
          time: booking.requestedAt,
          isCompleted: booking.requestedAt != null,
          isLast: false,
        ),
        _buildTimelineItem(
          title: 'Xác nhận lịch hẹn',
          time: booking.confirmedAt,
          isCompleted: booking.confirmedAt != null,
          isLast: false,
        ),
        _buildTimelineItem(
          title: 'Hoàn thành dịch vụ',
          time: booking.completedAt,
          isCompleted: booking.completedAt != null,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required DateTime? time,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCompleted ? primaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? primaryColor : borderColor,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted ? primaryColor : borderColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? darkText : bodyText,
                ),
              ),
              if (time != null)
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(time),
                  style: const TextStyle(fontSize: 12, color: bodyText),
                ),
              const SizedBox(height: 16), // Spacing equivalent to line height
            ],
          ),
        ),
      ],
    );
  }
}
