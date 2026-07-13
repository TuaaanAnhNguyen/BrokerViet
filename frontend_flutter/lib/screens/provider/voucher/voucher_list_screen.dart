import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/voucher_model.dart';
import '../../../services/voucher_service.dart';
import '../../../utils/voucher_status_utils.dart';
import 'voucher_form_screen.dart';

class VoucherListScreen extends StatefulWidget {
  const VoucherListScreen({super.key});

  @override
  State<VoucherListScreen> createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  final VoucherService _voucherService = VoucherService();

  List<VoucherModel> _vouchers = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _updatingIds = {};

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color surfaceColor = Color(0xFFF8F9FF);
  static const Color darkText = Color(0xFF0B1C30);
  static const Color bodyText = Color(0xFF434655);
  static const Color borderColor = Color(0xFFC3C6D7);

  String? get _providerId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    final providerId = _providerId;
    if (providerId == null) {
      setState(() {
        _errorMessage = 'Vui lòng đăng nhập để xem voucher';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vouchers = await _voucherService.getProviderVouchers(providerId);
      if (mounted) {
        setState(() {
          _vouchers = vouchers;
          _isLoading = false;
        });
      }
    } on VoucherException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải danh sách voucher';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleVoucherStatus(VoucherModel voucher, bool isActive) async {
    if (voucher.status == 'EXPIRED') return;

    final newStatus = isActive ? 'ACTIVE' : 'PAUSED';
    final index = _vouchers.indexWhere((v) => v.id == voucher.id);
    if (index == -1) return;

    final oldVoucher = _vouchers[index];
    setState(() {
      _updatingIds.add(voucher.id);
      _vouchers[index] = oldVoucher.copyWith(status: newStatus);
    });

    try {
      await _voucherService.updateVoucherStatus(voucher.id, newStatus);
    } on VoucherException catch (e) {
      if (mounted) {
        setState(() => _vouchers[index] = oldVoucher);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _vouchers[index] = oldVoucher);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể cập nhật trạng thái voucher')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updatingIds.remove(voucher.id));
      }
    }
  }

  Future<void> _openCreateForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const VoucherFormScreen()),
    );

    if (created == true) {
      _loadVouchers();
    }
  }

  String _usageText(VoucherModel voucher) {
    if (voucher.usageLimit == null) {
      return '${voucher.usedCount} lượt (không giới hạn)';
    }
    return '${voucher.usedCount}/${voucher.usageLimit} lượt';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mã giảm giá',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateForm,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _loadVouchers,
        color: primaryColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: _loadVouchers,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_vouchers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_number_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Chưa có mã giảm giá nào',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _vouchers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final voucher = _vouchers[index];
        return _buildVoucherCard(voucher);
      },
    );
  }

  Widget _buildVoucherCard(VoucherModel voucher) {
    final statusBg = VoucherStatusUtils.getBackgroundColorForStatus(voucher.status);
    final statusText = VoucherStatusUtils.getTextColorForStatus(voucher.status);
    final canToggle = voucher.status != 'EXPIRED';
    final isActive = voucher.status == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  voucher.displayDiscount,
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _usageText(voucher),
                  style: const TextStyle(color: bodyText, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    VoucherStatusUtils.getLabelForStatus(voucher.status),
                    style: TextStyle(
                      color: statusText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (canToggle)
            _updatingIds.contains(voucher.id)
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: isActive,
                    activeThumbColor: primaryColor,
                    onChanged: (value) => _toggleVoucherStatus(voucher, value),
                  ),
        ],
      ),
    );
  }
}
