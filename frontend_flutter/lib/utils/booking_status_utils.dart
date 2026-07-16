// lib/utils/booking_status_utils.dart

import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingStatusUtils {
  /// Returns the main text/foreground color for the status badge
  static Color getTextColorForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.daHoanThanh:
        return const Color(0xFF2E7D32);
      case BookingStatus.dangChoDuyet:
        return const Color(0xFFE65100);
      case BookingStatus.daChapNhan:
        return const Color.fromARGB(255, 7, 99, 219);
      case BookingStatus.daBiHuy:
        return const Color.fromARGB(255, 247, 65, 247);
      case BookingStatus.daHuy:
        return Colors.red.shade700;
    }
  }

  static Color getBackgroundColorForStatus(BookingStatus status) {
    return getTextColorForStatus(status).withOpacity(0.1);
  }

  static String getLabelForStatus(BookingStatus status) {
    return status.uiLabel;
  }
}
