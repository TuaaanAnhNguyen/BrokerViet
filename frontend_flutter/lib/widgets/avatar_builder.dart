// lib/widgets/avatar_builder.dart

import 'dart:io';
import 'package:flutter/material.dart';
import './network_image_fallback.dart';

Widget buildAvatar(String avatarPath, {double radius = 40}) {
  // 1. Xử lý link URL từ mạng (Supabase)
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

  // 2. Xử lý ảnh từ bộ nhớ máy (File cục bộ khi vừa chọn xong)
  if (avatarPath.isNotEmpty &&
      !avatarPath.startsWith('assets/') &&
      File(avatarPath).existsSync()) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: FileImage(File(avatarPath)),
    );
  }

  // 3. Xử lý Assets mặc định (Ảnh mẫu trong thư mục assets)
  final String validAssetPath =
      avatarPath.trim().isEmpty ? 'assets/default_profile.png' : avatarPath;

  return CircleAvatar(
    radius: radius,
    backgroundImage: AssetImage(validAssetPath),
  );
}
