// lib/screens/provider/view_provider_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:broker_viet/models/service_model.dart';
import 'package:broker_viet/widgets/avatar_builder.dart';
import 'package:broker_viet/widgets/network_image_fallback.dart';
import 'package:broker_viet/features/chat/conversation_screen.dart';
import 'package:broker_viet/services/chat/chat_service.dart';
import 'package:broker_viet/features/main/service_detail_screen.dart';
import 'package:broker_viet/services/provider/provider_profile_service.dart';

class ViewProviderScreen extends StatefulWidget {
  final String providerId;
  final String providerName;
  final String? avatarUrl;
  final bool isPro;

  const ViewProviderScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    this.avatarUrl,
    required this.isPro,
  });

  @override
  State<ViewProviderScreen> createState() => _ViewProviderScreenState();
}

class _ViewProviderScreenState extends State<ViewProviderScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProviderProfileService _providerProfileService =
      ProviderProfileService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _bio;
  List<ServiceModel> _services = [];
  double _averageRating = 5.0;
  int _reviewsCount = 0;

  static const Color primaryColor = Color(0xFF004AC6);
  static const Color surfaceColor = Color(0xFFF8F9FF);
  static const Color darkText = Color(0xFF0B1C30);
  static const Color bodyText = Color(0xFF434655);

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final data = await _providerProfileService.fetchProviderProfileDetails(
        widget.providerId,
      );

      final bio = data['bio'] as String?;

      final servicesJson = (data['services'] as List<dynamic>? ?? []);
      final loadedServices = servicesJson
          .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final averageRating = (data['average_rating'] as num).toDouble();
      final reviewsCount = (data['reviews_count'] as num).toInt();

      if (mounted) {
        setState(() {
          _bio = bio;
          _services = loadedServices;
          _averageRating = averageRating;
          _reviewsCount = reviewsCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('>>> Lỗi khi tải dữ liệu nhà cung cấp: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải thông tin nhà cung cấp.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleChat() async {
    final currentCustomerId = _supabase.auth.currentUser?.id ?? '';
    if (currentCustomerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để chat với nhà cung cấp'),
        ),
      );
      return;
    }

    if (currentCustomerId == widget.providerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không thể chat với chính mình')),
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
        providerId: widget.providerId,
        customerId: currentCustomerId,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              chatroomId: chatroomId,
              providerName: widget.providerName,
              providerRole: 'Nhà cung cấp dịch vụ',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tạo phòng chat: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text(
          'Nhà cung cấp',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        centerTitle: true,
      ),
      body: _buildBody(screenWidth),
    );
  }

  Widget _buildBody(double screenWidth) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProviderData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(screenWidth),
          _buildServicesSection(screenWidth),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    final double horizontalPadding = screenWidth * 0.05;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20,
      ),
      child: Column(
        children: [
          // Circular avatar
          Center(
            child: buildAvatar(
              widget.avatarUrl ?? '',
              radius: screenWidth * 0.12,
            ),
          ),
          const SizedBox(height: 16),
          // Name and PRO Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.providerName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.isPro) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Star rating & review count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkText,
                  fontSize: 14,
                ),
              ),
              Text(
                ' · $_reviewsCount đánh giá',
                style: const TextStyle(color: bodyText, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Response time
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: bodyText),
              SizedBox(width: 6),
              Text(
                'Phản hồi ~15 phút',
                style: TextStyle(color: bodyText, fontSize: 13),
              ),
            ],
          ),
          if (_bio != null && _bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Bio
            Text(
              _bio!,
              style: const TextStyle(
                color: bodyText,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 20),
          // Full-width Message button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _handleChat,
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text(
                'Nhắn tin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(double screenWidth) {
    final double horizontalPadding = screenWidth * 0.05;

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dịch vụ đang cung cấp',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 16),
          if (_services.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'Chưa có dịch vụ nào',
                  style: TextStyle(
                    color: bodyText.withOpacity(0.7),
                    fontSize: 15,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _services.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final service = _services[index];
                return _buildServiceCard(service, screenWidth);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service, double screenWidth) {
    return Card(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(serviceId: service.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageWithFallback(
                  imageUrl: service.imageUrl ?? '',
                  width: screenWidth * 0.20,
                  height: screenWidth * 0.20,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              // Right Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          service.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
