// lib/widgets/provider/provider_booking_card.dart

import 'package:flutter/material.dart';
import '../../models/provider_booking_model.dart';
import '../../models/booking_model.dart';
import '../../utils/booking_status_utils.dart';

class ProviderBookingCard extends StatelessWidget {
  final ProviderBookingModel booking;
  final VoidCallback? onTap;
  final Function(BookingStatus newStatus)? onStatusUpdate;

  const ProviderBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onStatusUpdate,
  });

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color darkText = Color(0xFF0B1C30);
  static const Color bodyText = Color(0xFF434655);
  static const Color borderColor = Color(0xFFC3C6D7);

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = booking.status == BookingStatus.daHuy;
    final bool isPending = booking.status == BookingStatus.dangChoDuyet;

    return Opacity(
      opacity: isCancelled ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    backgroundImage: booking.customerAvatar != null
                        ? NetworkImage(booking.customerAvatar!)
                        : null,
                    radius: 24,
                    child: booking.customerAvatar == null
                        ? Text(
                            booking.customerName.isNotEmpty
                                ? booking.customerName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.serviceTitle,
                          style: const TextStyle(color: bodyText, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Date Row
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: bodyText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              booking.formattedDate,
                              style: const TextStyle(
                                color: bodyText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (booking.address != null &&
                            booking.address!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: bodyText,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  booking.address!,
                                  style: const TextStyle(
                                    color: bodyText,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BookingStatusUtils.getBackgroundColorForStatus(
                        booking.status,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      BookingStatusUtils.getLabelForStatus(booking.status),
                      style: TextStyle(
                        color: BookingStatusUtils.getTextColorForStatus(
                          booking.status,
                        ),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (isPending) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: borderColor),
                const SizedBox(height: 12),
                _buildQuickActions(booking.status),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BookingStatus status) {
    if (status == BookingStatus.dangChoDuyet) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onStatusUpdate?.call(BookingStatus.daHuy),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Từ chối'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => onStatusUpdate?.call(BookingStatus.daHoanThanh),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Chấp nhận'),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
