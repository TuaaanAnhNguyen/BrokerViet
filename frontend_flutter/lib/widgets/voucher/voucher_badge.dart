import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/voucher_model.dart';
import '../../services/voucher_service.dart';

class VoucherBadge extends StatefulWidget {
  final String serviceId;

  const VoucherBadge({super.key, required this.serviceId});

  @override
  State<VoucherBadge> createState() => _VoucherBadgeState();
}

class _VoucherBadgeState extends State<VoucherBadge> {
  final VoucherService _voucherService = VoucherService();
  late Future<List<VoucherModel>> _vouchersFuture;

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color darkText = Color(0xFF0B1C30);

  @override
  void initState() {
    super.initState();
    _vouchersFuture = _voucherService.getActiveVouchersForService(
      widget.serviceId,
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã sao chép mã $code')));
  }

  List<VoucherModel> _sortedVouchers(List<VoucherModel> vouchers) {
    final sorted = List<VoucherModel>.from(vouchers);
    sorted.sort((a, b) => b.discountValue.compareTo(a.discountValue));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VoucherModel>>(
      future: _vouchersFuture,
      builder: (context, snapshot) {
        // debugPrint('[VoucherBadge] serviceId: ${widget.serviceId}');
        // debugPrint('[VoucherBadge] connectionState: ${snapshot.connectionState}');
        // debugPrint('[VoucherBadge] hasData: ${snapshot.hasData}');
        // debugPrint('[VoucherBadge] hasError: ${snapshot.hasError}');
        if (snapshot.hasError) {
          debugPrint('[VoucherBadge] error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          debugPrint('[VoucherBadge] data length: ${snapshot.data!.length}');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final vouchers = _sortedVouchers(snapshot.data!);

        if (vouchers.length == 1) {
          return _buildVoucherCard(vouchers.first);
        }

        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vouchers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return _buildVoucherCard(vouchers[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildVoucherCard(VoucherModel voucher) {
    return Material(
      color: const Color(0xFFE5EEFF),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _copyCode(voucher.code),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
          ),
          child: Text(
            '🎟 Mã ${voucher.code} — ${voucher.displayDiscount}',
            style: const TextStyle(
              color: darkText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
