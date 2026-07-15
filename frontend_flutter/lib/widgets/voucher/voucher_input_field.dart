import 'package:flutter/material.dart';

import '../../services/voucher_service.dart';

class VoucherInputField extends StatefulWidget {
  final String providerId;
  final String customerId;
  final String serviceId;
  final double orderValue;
  final void Function(
    String? voucherCode,
    double discountAmount,
    double finalPrice,
  ) onVoucherApplied;

  const VoucherInputField({
    super.key,
    required this.providerId,
    required this.customerId,
    required this.serviceId,
    required this.orderValue,
    required this.onVoucherApplied,
  });

  @override
  State<VoucherInputField> createState() => _VoucherInputFieldState();
}

class _VoucherInputFieldState extends State<VoucherInputField> {
  final VoucherService _voucherService = VoucherService();
  final _codeController = TextEditingController();

  bool _isApplying = false;
  bool _isApplied = false;
  double _discountAmount = 0;
  String? _errorMessage;

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color darkText = Color(0xFF0B1C30);
  static const Color borderColor = Color(0xFFC3C6D7);

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _formatVnd(double value) {
    return "${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}₫";
  }

  Future<void> _applyVoucher() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mã giảm giá');
      return;
    }

    setState(() {
      _isApplying = true;
      _errorMessage = null;
    });

    try {
      final result = await _voucherService.validateVoucher(
        code: code,
        providerId: widget.providerId,
        customerId: widget.customerId,
        serviceId: widget.serviceId,
        orderValue: widget.orderValue,
      );

      if (!mounted) return;

      if (result.valid) {
        final discount = result.discountAmount ?? 0;
        final finalPrice = result.finalPrice ?? widget.orderValue;
        setState(() {
          _isApplied = true;
          _discountAmount = discount;
          _errorMessage = null;
        });
        widget.onVoucherApplied(code, discount, finalPrice);
      } else {
        setState(() {
          _isApplied = false;
          _discountAmount = 0;
          _errorMessage = result.error ?? 'Mã giảm giá không hợp lệ';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể xác thực mã giảm giá';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  void _removeVoucher() {
    setState(() {
      _isApplied = false;
      _discountAmount = 0;
      _errorMessage = null;
      _codeController.clear();
    });
    widget.onVoucherApplied(null, 0, widget.orderValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mã giảm giá',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                enabled: !_isApplied,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Nhập mã voucher',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isApplying
                    ? null
                    : (_isApplied ? _removeVoucher : _applyVoucher),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isApplying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_isApplied ? 'Xóa mã' : 'Áp dụng'),
              ),
            ),
          ],
        ),
        if (_isApplied)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Đã áp dụng: -${_formatVnd(_discountAmount)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
      ],
    );
  }
}
