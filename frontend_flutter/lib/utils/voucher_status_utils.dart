import 'package:flutter/material.dart';

class VoucherStatusUtils {
  static Color getBackgroundColorForStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green.shade100;
      case 'PAUSED':
        return Colors.orange.shade100;
      case 'EXPIRED':
        return Colors.grey.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  static Color getTextColorForStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green.shade800;
      case 'PAUSED':
        return Colors.orange.shade800;
      case 'EXPIRED':
        return Colors.grey.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  static String getLabelForStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Đang hoạt động';
      case 'PAUSED':
        return 'Tạm dừng';
      case 'EXPIRED':
        return 'Hết hạn';
      default:
        return status;
    }
  }
}
