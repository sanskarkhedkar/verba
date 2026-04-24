import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primaryStart = Color(0xFF4F46E5);
  static const primaryEnd = Color(0xFF7C3AED);
  static const bgPrimary = Color(0xFF0A0A0F);
  static const bgSurface = Color(0xFF13131A);
  static const bgElevated = Color(0xFF1C1C28);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA8A8C0);
  static const textTertiary = Color(0xFF5C5C7A);
  static const textAccent = Color(0xFF818CF8);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const glass = Color(0x0FFFFFFF);
  static const glassBorder = Color(0x1FFFFFFF);

  static const primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
