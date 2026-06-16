// lib/widgets/network_image_fallback.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _buildAssetPlaceholder();
    }

    if (imageUrl.startsWith('assets/')) {
      return _buildAssetPlaceholder(customPath: imageUrl);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF8F9FF),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF004AC6),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildAssetPlaceholder(),
    );
  }

  Widget _buildAssetPlaceholder({String? customPath}) {
    return Image.asset(
      customPath ?? 'assets/no_icon_placeholder.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFE5EEFF),
          child: const Center(
            child: Icon(
              Icons.image_not_supported_rounded,
              color: Color(0xFF004AC6),
              size: 24,
            ),
          ),
        );
      },
    );
  }
}