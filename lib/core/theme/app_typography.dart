import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  // Using Bricolage Grotesque via Google Fonts (matches PRD 3 spec exactly)
  static String get fontFamily => GoogleFonts.bricolageGrotesque().fontFamily!;

  static TextStyle get displayXL => _base(40, FontWeight.w800, 1.15);
  static TextStyle get displayL => _base(32, FontWeight.w700, 1.2);
  static TextStyle get heading1 => _base(28, FontWeight.w700, 1.25);
  static TextStyle get heading2 => _base(24, FontWeight.w600, 1.3);
  static TextStyle get heading3 => _base(20, FontWeight.w600, 1.35);
  static TextStyle get bodyL => _base(18, FontWeight.w400, 1.5);
  static TextStyle get bodyM => _base(16, FontWeight.w400, 1.5);
  static TextStyle get bodyS => _base(14, FontWeight.w400, 1.5);
  static TextStyle get caption => _base(12, FontWeight.w400, 1.4);
  static TextStyle get button =>
      _base(16, FontWeight.w600, 1.2).copyWith(letterSpacing: 0.2);

  static TextStyle _base(double size, FontWeight weight, double height) {
    return GoogleFonts.bricolageGrotesque(
      color: AppColors.textPrimary,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }
}
