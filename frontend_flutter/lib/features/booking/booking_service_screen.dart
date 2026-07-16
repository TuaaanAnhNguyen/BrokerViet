// lib/features/booking/booking_service_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/booking/booking_service.dart';
import '../../services/navigation_service.dart';
import '../../services/payment/vnpay_service.dart';
import '../../services/map-location/location_service.dart';
import '../../widgets/payment/vietqr_payment.dart';
import '../../widgets/voucher/voucher_input_field.dart';

import '../../widgets/booking/booking_header_card.dart';
import '../../widgets/booking/booking_schedule_tile.dart';
import '../../widgets/booking/booking_address_input.dart';
import '../../widgets/booking/payment_method_selector.dart';
import '../../widgets/booking/invoice_breakdown_card.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String? providerName;
  final String serviceTitle;
  final String packageName;
  final String customerId;
  final String providerId;
  final String? serviceType;
  final DateTime scheduledAt;
  final int totalPrice;
  final String? serviceImageUrl;

  const BookingScreen({
    super.key,
    required this.serviceId,
    this.providerName,
    required this.serviceTitle,
    required this.packageName,
    required this.customerId,
    required this.providerId,
    required this.scheduledAt,
    required this.totalPrice,
    this.serviceType,
    this.serviceImageUrl,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  final VNPayService _vnPayService = VNPayService();
  final LocationService _locationService = LocationService();

  late TextEditingController _addressController;

  // Workflow State Tracking
  String? _createdBookingId;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;

  // Payment State Tracking
  int _selectedPaymentMethod = 0; // 0: VietQR, 2: Tiền mặt, 3: VNPAY
  String? _appliedVoucherCode;
  double _discountAmount = 0;
  late double _finalPrice;

  @override
  void initState() {
    super.initState();
    _finalPrice = widget.totalPrice.toDouble();
    _addressController = TextEditingController(text: "");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFetchCurrentLocation();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleFetchCurrentLocation() async {
    if (_isLoadingLocation) return;
    setState(() => _isLoadingLocation = true);

    try {
      final currentLoc = await _locationService.getMyLocation();
      if (currentLoc.address != null && currentLoc.address!.isNotEmpty) {
        _addressController.text = currentLoc.address!;
        return;
      }

      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        final response = await client.functions.invoke('fetch-profile');
        if (response.status == 200 && response.data != null) {
          final dataMap = response.data as Map<String, dynamic>;
          final profileData = dataMap['profile'] as Map<String, dynamic>?;
          final savedAddress =
              profileData?['address'] ?? profileData?['location_text'];
          if (savedAddress != null && savedAddress.toString().isNotEmpty) {
            _addressController.text = savedAddress.toString();
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _createInitialBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final bookingResult = await _bookingService.createBooking(
        serviceId: widget.serviceId,
        customerId: widget.customerId,
        providerId: widget.providerId,
        totalPrice: widget.totalPrice,
        scheduledAt: widget.scheduledAt,
        serviceType: widget.serviceType,
        voucherCode: null,
      );

      final confirmedId = (bookingResult['booking_id'] != null)
          ? bookingResult['booking_id'].toString()
          : await _bookingService.getLatestBookingId(widget.customerId);

      if (confirmedId == null || confirmedId.isEmpty) {
        throw Exception("Could not retrieve booking ID.");
      }

      if (mounted) {
        setState(() => _isSubmitting = false);

        final navigatorState = NavigationService.navigatorKey.currentState;

        if (navigatorState != null) {
          // 2. Clear all details screens (Booking -> Detail) to reveal the shell
          navigatorState.popUntil((route) => route.isFirst);

          // 3. Extract the clean base layer BuildContext
          final rootContext = navigatorState.context;

          _showStep1SuccessDialog(rootContext, confirmedId);
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo yêu cầu: ${e.toString()}')),
      );
    }
  }

  void _showStep1SuccessDialog(BuildContext targetContext, String bookingId) {
    final String displayId = bookingId.length > 8
        ? bookingId.substring(0, 8).toUpperCase()
        : bookingId.toUpperCase();

    showDialog(
      context: targetContext,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF004AC6)),
            SizedBox(width: 8),
            Text(
              'Đã tạo yêu cầu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Đơn đặt lịch ($displayId) đã được tạo thành công ở trạng thái chờ duyệt. Bạn có thể theo dõi tiến độ tại mục Đơn đã mua.',
          style: const TextStyle(color: Color(0xFF434655)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AC6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _onVoucherApplied(
    String? voucherCode,
    double discountAmount,
    double finalPrice,
  ) {
    setState(() {
      _appliedVoucherCode = voucherCode;
      _discountAmount = discountAmount;
      _finalPrice = finalPrice;
    });
  }

  void _executeFinalPayment() async {
    setState(() => _isSubmitting = true);
    final int finalCalculatedPrice = _finalPrice.round();
    final String trackingMemo = _createdBookingId!
        .substring(0, 8)
        .toUpperCase();
    final rootNavigator = Navigator.of(context);

    try {
      // Update booking table with voucher if used
      if (_appliedVoucherCode != null) {
        // Optional: add a patch method in your booking service if necessary
      }

      setState(() => _isSubmitting = false);

      if (_selectedPaymentMethod == 0) {
        // VietQR Setup
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Thanh toán đơn hàng')),
              body: Center(
                child: VietQRPaymentWidget(
                  memo: trackingMemo,
                  paymentAmount: finalCalculatedPrice,
                  providerBankCode: 'bidv',
                  providerBankAccount: '8821165401',
                  onSimulateSuccess: () {
                    Navigator.pop(context);
                    _showSuccessDialog(
                      rootNavigator,
                      'Thanh toán qua VietQR ($trackingMemo) thành công.',
                    );
                  },
                ),
              ),
            ),
          ),
        );
      } else if (_selectedPaymentMethod == 3) {
        // VNPay Flow
        final paymentUrl = await _vnPayService.createPaymentUrl(
          bookingId: _createdBookingId!,
          amount: finalCalculatedPrice,
          orderInfo: 'Thanh toan don hang ${widget.serviceTitle}',
        );
        if (paymentUrl != null) {
          await _vnPayService.openVNPay(paymentUrl);
        }
      } else {
        // Cash Flow
        _showSuccessDialog(
          rootNavigator,
          'Lịch hẹn ghi nhận theo hình thức Tiền mặt sau dịch vụ.',
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xử lý thanh toán.')),
      );
    }
  }

  void _showSuccessDialog(NavigatorState rootNav, String dynamicMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF004AC6)),
            SizedBox(width: 8),
            Text(
              'Thành công',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          dynamicMessage,
          style: const TextStyle(color: Color(0xFF434655)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              rootNav.popUntil((route) => route.isFirst);
            },
            child: const Text('Về Trang Chủ'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND";
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color outlineVariant = Color(0xFFC3C6D7);

    // Dynamic routing inside the scaffold depending on the step state
    final bool isBookingCreated = _createdBookingId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: Text(
          isBookingCreated ? 'Thanh toán lịch đặt' : 'Xác nhận đặt',
          style: const TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: isBookingCreated
                    ? _buildPaymentView() // State 2: Accepted / Created View
                    : _buildDraftView(), // State 1: New Draft View
              ),
              _buildBottomActionDock(isBookingCreated),
            ],
          ),
        ),
      ),
    );
  }

  /// View State 1: Top 3 Cards Only (Pre-booking generation)
  Widget _buildDraftView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BookingHeaderCard(
          serviceTitle: widget.serviceTitle,
          packageName: widget.packageName,
          serviceImageUrl: widget.serviceImageUrl,
        ),
        const SizedBox(height: 20),
        BookingScheduleTile(scheduledAt: widget.scheduledAt),
        const SizedBox(height: 20),
        BookingAddressInput(
          controller: _addressController,
          isLoading: _isLoadingLocation,
          onFetchCurrentLocation: _handleFetchCurrentLocation,
        ),
      ],
    );
  }

  /// View State 2: Appends Payment Configurations Post-Creation
  Widget _buildPaymentView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Optional reminder alert notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF004AC6), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đơn đặt lịch của bạn đã được ghi nhận. Vui lòng tiến hành thanh toán.',
                  style: TextStyle(color: Color(0xFF004AC6), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PaymentMethodSelector(
          selectedPaymentMethod: _selectedPaymentMethod,
          onMethodChanged: (methodIndex) {
            setState(() => _selectedPaymentMethod = methodIndex);
          },
        ),
        const SizedBox(height: 20),
        VoucherInputField(
          providerId: widget.providerId,
          customerId: widget.customerId,
          serviceId: widget.serviceId,
          orderValue: widget.totalPrice.toDouble(),
          onVoucherApplied: _onVoucherApplied,
        ),
        const SizedBox(height: 20),
        InvoiceBreakdownCard(
          packageName: widget.packageName,
          serviceFee: widget.totalPrice.toDouble(),
          discountAmount: _discountAmount,
          totalAmount: _finalPrice,
          appliedVoucherCode: _appliedVoucherCode,
        ),
      ],
    );
  }

  /// Shared context action dock that changes behavior based on execution states
  Widget _buildBottomActionDock(bool isCreatedState) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color bodyText = Color(0xFF434655);
    const Color outlineVariant = Color(0xFFC3C6D7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
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
                    Text(
                      isCreatedState ? 'Giá thanh toán cuối' : 'Giá tạm tính',
                      style: const TextStyle(fontSize: 12, color: bodyText),
                    ),
                    Text(
                      _formatCurrency(
                        isCreatedState
                            ? _finalPrice
                            : widget.totalPrice.toDouble(),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.verified_user, color: bodyText, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Thanh toán bảo mật',
                      style: TextStyle(fontSize: 12, color: bodyText),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : (isCreatedState
                        ? _executeFinalPayment
                        : _createInitialBooking),
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
                  : Text(
                      isCreatedState ? 'Thanh toán ngay' : 'Đặt lịch ngay',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
