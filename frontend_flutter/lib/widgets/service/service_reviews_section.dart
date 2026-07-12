// lib/widgets/service/service_reviews_section.dart

import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../widgets/avatar_builder.dart';
import '../../features/main/all_reviews_screen.dart';

class ServiceReviewsSection extends StatelessWidget {
  final List<ReviewModel> reviews;
  final String serviceTitle; // <-- Add this line
  final bool hasPurchased;
  final ReviewModel? existingReview;
  final VoidCallback onWriteReviewPressed;

  const ServiceReviewsSection({
    super.key,
    required this.reviews,
    required this.serviceTitle, // <-- Add this line
    required this.hasPurchased,
    required this.existingReview,
    required this.onWriteReviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color bodyText = Color(0xFF434655);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đánh giá (${reviews.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            if (hasPurchased)
              TextButton.icon(
                onPressed: onWriteReviewPressed,
                icon: Icon(
                  existingReview != null ? Icons.edit : Icons.rate_review,
                  size: 18,
                ),
                label: Text(
                  existingReview != null ? 'Sửa đánh giá' : 'Viết đánh giá',
                ),
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
        if (reviews.isNotEmpty) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllReviewsScreen(
                    reviews: reviews,
                    serviceTitle: serviceTitle, // <-- Pass it here!
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
            child: const Text(
              'Xem tất cả đánh giá',
              style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }
}
