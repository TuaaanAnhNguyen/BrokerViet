// lib/widgets/avatar_builder.dart

import 'package:flutter/material.dart';
import './network_image_fallback.dart';

Widget buildAvatar(String avatarPath, {double radius = 40}) {
  if (avatarPath.isNotEmpty && 
      (avatarPath.startsWith('http://') || avatarPath.startsWith('https://'))) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEFF4FF),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: NetworkImageWithFallback(
          imageUrl: avatarPath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  final String validAssetPath = avatarPath.trim().isEmpty ? 'assets/default_profile.png' : avatarPath;

  return CircleAvatar(
    radius: radius,
    backgroundImage: AssetImage(validAssetPath),
  );
}