// lib/features/main/service_detail_screen.dart

import 'package:broker_viet/features/chat/conversation_screen.dart';
import 'package:broker_viet/models/review_model.dart';
import 'package:broker_viet/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service_model.dart';
import '../../services/marketplace/service_marketplace_service.dart';
import '../booking/booking_service_screen.dart';
import './map_screen.dart';

import '../../widgets/service/service_detail_app_bar.dart';
import '../../widgets/service/service_tags_section.dart';
import '../../widgets/service/service_title_section.dart';
import '../../widgets/service/service_provider_card.dart';
import '../../widgets/service/service_description_section.dart';
import '../../widgets/service/service_price_packages_section.dart';
import '../../widgets/service/service_reviews_section.dart';
import '../../widgets/service/service_sticky_action_dock.dart';

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
  ReviewModel? _existingReview;

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color surfaceColor = Color(0xFFF8F9FF);

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

      final currentUserId = supabase.auth.currentUser?.id;
      ReviewModel? existingReview;
      if (currentUserId != null) {
        for (var r in reviews) {
          if (r.userId == currentUserId) {
            existingReview = r;
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          _service = service;
          _reviews = reviews;
          _hasPurchased = hasPurchased;
          _existingReview = existingReview;
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
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
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
              ServiceDetailAppBar(
                imageUrl: _service?.imageUrl,
                isFavorited: _isFavorited,
                onFavoriteToggle: () {
                  setState(() {
                    _isFavorited = !_isFavorited;
                  });
                },
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
                          rating: _service?.rating ?? 0.0,
                        ),
                        const SizedBox(height: 24),
                        ServiceProviderCard(
                          providerId: _service?.providerId ?? '',
                          providerUsername:
                              _service?.providerUsername ?? 'Nhà cung cấp',
                          providerAvatarUrl: _service?.providerAvatarUrl,
                        ),
                        const SizedBox(height: 24),
                        ServiceDescriptionSection(
                          description: _service?.subtitle ?? '',
                        ),
                        const SizedBox(height: 24),
                        ServicePricePackagesSection(
                          customTitle: _service?.title,
                          priceLabel: _service?.price ?? 'Liên hệ',
                        ),
                        const SizedBox(height: 24),
                        ServiceReviewsSection(
                          reviews: _reviews,
                          serviceTitle: _service?.title ?? '',
                          hasPurchased: _hasPurchased,
                          existingReview: _existingReview,
                          onWriteReviewPressed: _showReviewForm,
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
            onChatPressed: () async {
              final currentCustomerId = supabase.auth.currentUser?.id ?? '';
              final providerId = _service?.providerId ?? '';
              final providerName = _service?.providerUsername ?? 'Nhà cung cấp';

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
            onMapPressed: () async {
              final providerId = _service?.providerId ?? '';
              final providerName = _service?.providerUsername ?? 'Nhà cung cấp';

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              );

              try {
                final profileData = await supabase
                    .from('profiles')
                    .select('location_latitude, location_longitude')
                    .eq('user_id', providerId)
                    .maybeSingle();

                if (context.mounted) Navigator.pop(context);

                double? targetLat;
                double? targetLng;

                if (profileData != null) {
                  targetLat = (profileData['location_latitude'] as num?)
                      ?.toDouble();
                  targetLng = (profileData['location_longitude'] as num?)
                      ?.toDouble();
                }

                if (targetLat == null || targetLng == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đối tác chưa cập nhật cấu hình vị trí.'),
                      ),
                    );
                  }
                  return;
                }

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        initialTargetLat: targetLat,
                        initialTargetLng: targetLng,
                        initialProviderName: providerName,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi truy vấn bản đồ đối tác: $e'),
                    ),
                  );
                }
              }
            },
            onBookingPressed: () {
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
            },
          ),
        ],
      ),
    );
  }

  void _showReviewForm() {
    final existingReview = _existingReview;
    int localRating = existingReview?.rating ?? 0;
    String? localError;
    bool isSubmitting = false;
    final commentController = TextEditingController(
      text: existingReview?.comment ?? '',
    );

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
              Text(
                existingReview != null
                    ? 'Sửa đánh giá dịch vụ'
                    : 'Đánh giá dịch vụ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (isSubmitting)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: primaryColor),
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setModalState(() {
                          localRating = index + 1;
                          localError = null;
                        });
                      },
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
                    if (localError != null) {
                      setModalState(() => localError = null);
                    }
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

                    setModalState(() => isSubmitting = true);

                    try {
                      if (existingReview != null) {
                        await _marketplaceService.updateReview(
                          reviewId: existingReview.id,
                          rating: localRating,
                          comment: comment,
                        );
                      } else {
                        await _marketplaceService.submitReview(
                          serviceId: widget.serviceId,
                          rating: localRating,
                          comment: comment,
                        );
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              existingReview != null
                                  ? 'Cập nhật đánh giá thành công!'
                                  : 'Cảm ơn bạn đã đánh giá!',
                            ),
                          ),
                        );
                        _loadServiceDetail();
                      }
                    } catch (e) {
                      setModalState(() {
                        localError = 'Lỗi hệ thống: $e';
                        isSubmitting = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    existingReview != null
                        ? 'Cập nhật đánh giá'
                        : 'Gửi đánh giá',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (existingReview != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa đánh giá?'),
                          content: const Text(
                            'Bạn có chắc chắn muốn xóa vĩnh viễn đánh giá này không?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        setModalState(() => isSubmitting = true);
                        try {
                          await _marketplaceService.deleteReview(
                            existingReview.id,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã xóa đánh giá!')),
                            );
                            _loadServiceDetail();
                          }
                        } catch (e) {
                          setModalState(() {
                            localError = 'Lỗi khi xóa: $e';
                            isSubmitting = false;
                          });
                        }
                      }
                    },
                    child: const Text(
                      'Xóa đánh giá',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
