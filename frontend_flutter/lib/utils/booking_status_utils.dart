import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingStatusUtils {
  /// Returns the background color for the status badge
  static Color getBackgroundColorForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.choDuyet:
        return Colors.orange.shade100; // Warning/Amber
      case BookingStatus.xacNhan:
        return Colors.blue.shade100; // Info/Blue
      case BookingStatus.dangThucHien:
        return Colors.green.shade100; // Success/Green
      case BookingStatus.daHoanThanh:
      case BookingStatus.daHuy:
        return Colors.grey.shade200; // Neutral/Gray
    }
  }

  /// Returns the text color for the status badge
  static Color getTextColorForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.choDuyet:
        return Colors.orange.shade800;
      case BookingStatus.xacNhan:
        return Colors.blue.shade800;
      case BookingStatus.dangThucHien:
        return Colors.green.shade800;
      case BookingStatus.daHoanThanh:
      case BookingStatus.daHuy:
        return Colors.grey.shade700;
    }
  }

  /// Returns the string label for the status
  static String getLabelForStatus(BookingStatus status) {
    return status.value;
  }
}
