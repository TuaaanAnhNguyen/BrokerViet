// lib/features/main/service_detail_screen.dart

import 'package:broker_viet/features/chat/conversation_screen.dart';
import 'package:broker_viet/models/review_model.dart';
import 'package:broker_viet/services/chat/chat_service.dart';
import 'package:broker_viet/services/map-location/location_service.dart';
import 'package:broker_viet/widgets/avatar_builder.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/network_image_fallback.dart';
import '../../models/service_model.dart';
import 'package:broker_viet/screens/provider/view_provider_screen.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import '../booking/booking_service_screen.dart';
import '../../widgets/voucher/voucher_badge.dart';
import './map_screen.dart';

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
      print('\n\n>>> Lỗi load service detail: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải thông tin dịch vụ.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FF),
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

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
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
                        _buildTagsSection(),
                        const SizedBox(height: 12),
                        _buildTitleSection(),
                        const SizedBox(height: 24),
                        _buildProviderCard(),
                        const SizedBox(height: 24),
                        _buildDescriptionSection(),
                        const SizedBox(height: 24),
                        _buildPricePackagesSection(),
                        const SizedBox(height: 24),
                        _buildReviewsSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildStickyActionDock(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: darkText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: const Icon(Icons.share, color: darkText),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : darkText,
            ),
            onPressed: () => setState(() => _isFavorited = !_isFavorited),
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWithFallback(
              imageUrl: _service?.imageUrl ?? '',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [surfaceColor, Colors.transparent],
                  stops: [0.0, 0.3],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    final categoryName = _service?.categoryName;
    return Row(
      children: [
        if (categoryName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF39B8FD).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              categoryName,
              style: const TextStyle(
                color: Color(0xFF006591),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _service?.title ?? '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              _service?.rating.toStringAsFixed(1) ?? '0.0',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewProviderScreen(
              providerId: _service?.providerId ?? '',
              providerName: _service?.providerUsername ?? 'Nhà cung cấp',
              avatarUrl: _service?.providerAvatarUrl,
              isPro: true, // defaulting to true since badge says PRO
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EEFF).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC3C6D7).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            buildAvatar(_service?.providerAvatarUrl ?? '', radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _service?.providerUsername ?? 'Nhà cung cấp',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: bodyText),
                      SizedBox(width: 4),
                      Text(
                        'Phản hồi ~15 phút',
                        style: TextStyle(color: bodyText, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Về dịch vụ này',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _service?.subtitle ?? '',
          style: const TextStyle(color: bodyText, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPricePackagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin chi phí',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC3C6D7), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _service?.title ?? 'Giá dịch vụ trọn gói',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Chi phí dịch vụ niêm yết công khai',
                      style: TextStyle(color: bodyText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                _service?.price ?? 'Liên hệ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VoucherBadge(serviceId: widget.serviceId),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đánh giá (${_reviews.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            if (_hasPurchased)
              TextButton.icon(
                onPressed: _showReviewForm,
                icon: const Icon(Icons.rate_review, size: 18),
                label: const Text('Viết đánh giá'),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Chưa có đánh giá nào cho dịch vụ này.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews.length > 3 ? 3 : _reviews.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildAvatar(review.userAvatar, radius: 16),
                      const SizedBox(width: 8),
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          5,
                          (starIndex) => Icon(
                            Icons.star,
                            color: starIndex < review.rating
                                ? Colors.amber
                                : Colors.grey[300],
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.comment,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: bodyText,
                    ),
                  ),
                ],
              );
            },
          ),
        if (_reviews.isNotEmpty) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              // TODO: Navigate to all reviews screen
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Color(0xFFC3C6D7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Xem tất cả đánh giá',
              style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  void _showReviewForm() {
    int localRating = 0;
    String? localError;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Đánh giá dịch vụ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Vui lòng chọn mức độ hài lòng'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setModalState(() {
                      localRating = index + 1;
                      localError = null;
                    }),
                    icon: Icon(
                      Icons.star,
                      size: 40,
                      color: index < localRating
                          ? Colors.amber
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                maxLines: 3,
                onChanged: (_) {
                  if (localError != null)
                    setModalState(() => localError = null);
                },
                decoration: InputDecoration(
                  hintText: 'Hãy chia sẻ trải nghiệm của bạn (bắt buộc)...',
                  errorText: localError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final comment = commentController.text.trim();

                  if (localRating == 0) {
                    setModalState(
                      () => localError = 'Vui lòng chọn số sao đánh giá!',
                    );
                    return;
                  }

                  if (comment.isEmpty) {
                    setModalState(
                      () => localError = 'Vui lòng nhập nội dung đánh giá!',
                    );
                    return;
                  }

                  try {
                    await _marketplaceService.submitReview(
                      serviceId: widget.serviceId,
                      rating: localRating,
                      comment: comment,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cảm ơn bạn đã đánh giá!'),
                        ),
                      );
                      _loadServiceDetail();
                    }
                  } catch (e) {
                    setModalState(() => localError = 'Lỗi hệ thống: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Gửi đánh giá',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyActionDock() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: const Border(
            top: BorderSide(color: Color(0xFFC3C6D7), width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              InkWell(
                onTap: () async {
                  final currentCustomerId = supabase.auth.currentUser?.id ?? '';
                  final providerId = _service?.providerId ?? '';
                  final providerName =
                      _service?.providerUsername ?? 'Nhà cung cấp';

                  if (currentCustomerId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vui lòng đăng nhập để chat với nhà cung cấp',
                        ),
                      ),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Không thể tạo phòng chat: $e')),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: darkText),
                ),
              ),
              const SizedBox(width: 8),

              InkWell(
                onTap: () async {
                  if (_service == null) return;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  );

                  try {
                    final locationService = LocationService();

                    final providerLocation = await locationService
                        .getProviderLocation(providerId: _service!.providerId);

                    if (!context.mounted) return;

                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(
                          serviceId: _service!.id,
                          initialTargetLat: providerLocation.latitude,
                          initialTargetLng: providerLocation.longitude,
                          initialProviderName:
                              _service!.providerUsername ?? 'Provider',
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
                      SnackBar(
                        content: Text('Unable to load provider location.\n$e'),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFC3C6D7).withOpacity(0.5),
                    ),
                  ),
                  child: const Icon(Icons.map_outlined, color: primaryColor),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final currentCustomerId =
                        supabase.auth.currentUser?.id ?? '';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(
                          serviceTitle: _service?.title ?? 'Chưa có tiêu đề',
                          providerName:
                              _service?.providerUsername ?? 'Nhà cung cấp',
                          packageName: 'Dịch vụ tiêu chuẩn',
                          serviceId: _service?.id ?? '',
                          providerId: _service?.providerId ?? '',
                          customerId: currentCustomerId,
                          totalPrice: _service?.priceValue.toInt() ?? 0,
                          scheduledAt: DateTime.now(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đặt Ngay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
