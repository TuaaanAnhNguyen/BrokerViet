// lib/widgets/service/service_detail_app_bar.dart

import 'package:flutter/material.dart';
import '../network_image_fallback.dart';

class ServiceDetailAppBar extends StatelessWidget {
  final String? imageUrl;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;

  const ServiceDetailAppBar({
    super.key,
    required this.imageUrl,
    required this.isFavorited,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004AC6);
    const Color darkText = Color(0xFF0B1C30);
    const Color surfaceColor = Color(0xFFF8F9FF);

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withAlpha(204),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: darkText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundColor: Colors.white.withAlpha(204),
          child: IconButton(
            icon: const Icon(Icons.share, color: darkText),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.white.withAlpha(204),
          child: IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : darkText,
            ),
            onPressed: onFavoriteToggle,
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWithFallback(
              imageUrl: imageUrl ?? '',
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
}