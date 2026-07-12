// lib/utils/booking_status_utils.dart

import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingStatusUtils {
  /// Returns the background color for the status badge
  static Color getBackgroundColorForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.dangThucHien:
        return Colors.orange.shade100; // Warning/Amber
      case BookingStatus.daHoanThanh:
      case BookingStatus.daHuy:
        return Colors.grey.shade200; // Neutral/Gray
    }
  }

  /// Returns the text color for the status badge
  static Color getTextColorForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.dangThucHien:
        return Colors.orange.shade800;
      case BookingStatus.daHoanThanh:
      case BookingStatus.daHuy:
        return Colors.grey.shade700;
    }
  }

  /// Returns the string label for the status
  static String getLabelForStatus(BookingStatus status) {
    return status.uiLabel;
  }
}