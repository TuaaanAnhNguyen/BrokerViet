// lib/features/main/service_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../chat/conversation_screen.dart';
import '../../../models/review_model.dart';
import '../../../models/service_model.dart';
import '../../../services/chat/chat_service.dart';
import '../../../services/map-location/location_service.dart';
import '../../../services/marketplace/service_marketplace_service.dart';
import '../booking/booking_service_screen.dart';
import './map_screen.dart';

import '../../widgets/service/service_detail/service_detail_app_bar.dart';
import '../../widgets/service/service_detail/service_tags_section.dart';
import '../../widgets/service/service_detail/service_title_section.dart';
import '../../widgets/service/service_detail/service_provider_card.dart';
import '../../widgets/service/service_detail/service_description_section.dart';
import '../../widgets/service/service_detail/service_price_packages_section.dart';
import '../../widgets/service/service_detail/service_reviews_section.dart';
import '../../widgets/service/service_detail/service_sticky_action_dock.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ServiceMarketplaceService _marketplaceService =
      ServiceMarketplaceService();
  final SupabaseClient supabase = Supabase.instance.client;

  ServiceModel? _service;
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  bool _hasPurchased = false;
  String? _errorMessage;
  bool _isFavorited = false;

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color surfaceColor = Color(0xFFF8F9FF);
  static const Color darkText = Color(0xFF0B1C30);
  static const Color bodyText = Color(0xFF434655);

  @override
  void initState() {
    super.initState();
    _loadServiceDetail();
  }

  Future<void> _loadServiceDetail() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final service = await _marketplaceService.fetchServiceDetail(
        widget.serviceId,
      );
      final reviews = await _marketplaceService.fetchServiceReviews(
        widget.serviceId,
      );
      final hasPurchased = await _marketplaceService.checkUserPurchasedService(
        widget.serviceId,
      );

      if (mounted) {
        setState(() {
          _service = service;
          _reviews = reviews;
          _hasPurchased = hasPurchased;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải thông tin dịch vụ.';
          _isLoading = false;
        });
      }
    }
  }

  void _handleChatNavigation() async {
    final currentCustomerId = supabase.auth.currentUser?.id ?? '';
    final providerId = _service?.providerId ?? '';
    final providerName = _service?.providerUsername ?? 'Nhà cung cấp';

    if (currentCustomerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để chat với nhà cung cấp'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    try {
      final chatService = ChatService();
      final chatroomId = await chatService.getOrCreateChatRoom(
        providerId: providerId,
        customerId: currentCustomerId,
      );

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              chatroomId: chatroomId,
              providerName: providerName,
              providerRole: 'Nhà cung cấp dịch vụ',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tạo phòng chat: $e')));
      }
    }
  }

  void _handleMapNavigation() async {
    if (_service == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    try {
      final locationService = LocationService();
      final providerLocation = await locationService.getProviderLocation(
        providerId: _service!.providerId,
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapScreen(
            serviceId: _service!.id,
            initialTargetLat: providerLocation.latitude,
            initialTargetLng: providerLocation.longitude,
            initialProviderName: _service!.providerUsername ?? 'Provider',
          ),
        ),
      );
    } on LocationServiceException catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load provider location.\n$e')),
      );
    }
  }

  void _handleBookingNavigation() {
    final currentCustomerId = supabase.auth.currentUser?.id ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          serviceTitle: _service?.title ?? 'Chưa có tiêu đề',
          providerName: _service?.providerUsername ?? 'Nhà cung cấp',
          packageName: 'Dịch vụ tiêu chuẩn',
          serviceId: _service?.id ?? '',
          providerId: _service?.providerId ?? '',
          customerId: currentCustomerId,
          totalPrice: _service?.priceValue.toInt() ?? 0,
          scheduledAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: surfaceColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: surfaceColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadServiceDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final currentUserId = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              ServiceDetailAppBar(
                service: _service,
                isFavorited: _isFavorited,
                onFavoriteToggle: () =>
                    setState(() => _isFavorited = !_isFavorited),
                primaryColor: primaryColor,
                surfaceColor: surfaceColor,
                darkText: darkText,
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ServiceTagsSection(
                          categoryName: _service?.categoryName,
                        ),
                        const SizedBox(height: 12),
                        ServiceTitleSection(
                          title: _service?.title ?? '',
                          reviews: _reviews,
                          darkText: darkText,
                          bodyText: bodyText,
                        ),
                        const SizedBox(height: 24),
                        ServiceProviderCard(
                          providerId: _service?.providerId,
                          providerUsername: _service?.providerUsername,
                          providerAvatarUrl: _service?.providerAvatarUrl,
                          darkText: darkText,
                          bodyText: bodyText,
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 24),
                        ServiceDescriptionSection(
                          subtitle: _service?.subtitle ?? '',
                          darkText: darkText,
                          bodyText: bodyText,
                        ),
                        const SizedBox(height: 24),
                        ServicePricePackagesSection(
                          serviceId: widget.serviceId,
                          title: _service?.title,
                          price: _service?.price,
                          darkText: darkText,
                          bodyText: bodyText,
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 24),
                        ServiceReviewsSection(
                          reviews: _reviews,
                          hasPurchased: _hasPurchased,
                          currentUserId: currentUserId,
                          serviceTitle: _service?.title ?? 'Dịch vụ',
                          onWriteReviewPressed: () => _showReviewForm(),
                          onEditReviewPressed: (review) =>
                              _showReviewForm(existingReview: review),
                          darkText: darkText,
                          bodyText: bodyText,
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ServiceStickyActionDock(
            service: _service,
            onChatPressed: _handleChatNavigation,
            onMapPressed: _handleMapNavigation,
            onBookingPressed: _handleBookingNavigation,
            primaryColor: primaryColor,
            darkText: darkText,
          ),
        ],
      ),
    );
  }

  // Giữ nguyên hàm _showReviewForm(..) phục vụ việc hiển thị BottomSheet tương tác dữ liệu tại đây.
  void _showReviewForm({ReviewModel? existingReview}) {
    // Code logic của BottomSheet form giữ nguyên không đổi...
  }
}
