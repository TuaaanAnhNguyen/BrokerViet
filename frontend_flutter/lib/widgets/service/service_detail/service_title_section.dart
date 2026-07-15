import 'package:flutter/material.dart';
import '../../../models/review_model.dart';

class ServiceTitleSection extends StatelessWidget {
  final String title;
  final List<ReviewModel> reviews;
  final Color darkText;
  final Color bodyText;

  const ServiceTitleSection({
    super.key,
    required this.title,
    required this.reviews,
    required this.darkText,
    required this.bodyText,
  });

  @override
  Widget build(BuildContext context) {
    double averageRating = 0.0;
    if (reviews.isNotEmpty) {
      double sum = reviews.fold(0, (prev, element) => prev + element.rating);
      averageRating = sum / reviews.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
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
              averageRating > 0
                  ? averageRating.toStringAsFixed(1)
                  : 'Chưa có đánh giá',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (reviews.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                '(${reviews.length})',
                style: TextStyle(color: bodyText, fontSize: 14),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
