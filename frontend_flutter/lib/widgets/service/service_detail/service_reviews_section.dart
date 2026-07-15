// lib/widgets/service/service_detail/service_reviews_section.dart

import 'package:flutter/material.dart';
import '../../../models/review_model.dart';
import '../../../features/main/all_reviews_screen.dart';
import '../../review/review_tile.dart';

class ServiceReviewsSection extends StatelessWidget {
  final List<ReviewModel> reviews;
  final bool hasPurchased;
  final String? currentUserId;
  final String serviceTitle;
  final VoidCallback onWriteReviewPressed;
  final Function(ReviewModel) onEditReviewPressed;
  final Color darkText;
  final Color bodyText;
  final Color primaryColor;

  const ServiceReviewsSection({
    super.key,
    required this.reviews,
    required this.hasPurchased,
    required this.currentUserId,
    required this.serviceTitle,
    required this.onWriteReviewPressed,
    required this.onEditReviewPressed,
    required this.darkText,
    required this.bodyText,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đánh giá (${reviews.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            if (hasPurchased)
              TextButton.icon(
                onPressed: onWriteReviewPressed,
                icon: const Icon(Icons.rate_review, size: 18),
                label: const Text('Viết đánh giá'),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (reviews.isEmpty)
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
            itemCount: reviews.length > 3 ? 3 : reviews.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final isOwner =
                  currentUserId != null && review.userId == currentUserId;

              return ReviewTile(
                review: review,
                darkText: darkText,
                bodyText: bodyText,
                onEditPressed: isOwner
                    ? () => onEditReviewPressed(review)
                    : null,
              );
            },
          ),
        if (reviews.isNotEmpty) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllReviewsScreen(
                    reviews: reviews,
                    serviceTitle: serviceTitle,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Color(0xFFC3C6D7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Xem tất cả đánh giá',
              style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }
}
