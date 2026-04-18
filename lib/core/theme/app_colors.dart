import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Primaries
  static const Color primary = Color(0xFF7C5CFC);      // Vivid purple
  static const Color primaryLight = Color(0xFF9B82FD);
  static const Color primaryDark = Color(0xFF5B3FD6);
  static const Color secondary = Color(0xFF00D4AA);     // Teal accent
  static const Color secondaryLight = Color(0xFF33DCBB);

  // Backgrounds
  static const Color bgDark = Color(0xFF0A0A14);        // Near-black
  static const Color bgSurface = Color(0xFF12121E);     // Card surface
  static const Color bgCard = Color(0xFF1A1A2E);        // Elevated card
  static const Color bgCardHighlight = Color(0xFF1E1E35);

  // Text
  static const Color textPrimary = Color(0xFFF0EEFF);
  static const Color textSecondary = Color(0xFFB0ABCC);
  static const Color textMuted = Color(0xFF6B6589);
  static const Color textInverse = Color(0xFF0A0A14);

  // Semantic
  static const Color success = Color(0xFF3DDC84);
  static const Color warning = Color(0xFFFFB830);
  static const Color error = Color(0xFFFF5271);
  static const Color info = Color(0xFF5BC8FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C5CFC), Color(0xFF5B3FD6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00A8D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0A14), Color(0xFF12121E), Color(0xFF1A1232)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1A35), Color(0xFF12121E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Overlays
  static const Color overlay = Color(0x80000000);
  static final Color borderColor = Colors.white.withOpacity(0.08);
  static final Color glassBorder = Colors.white.withOpacity(0.12);

  // Tab bar
  static const Color tabActive = primary;
  static final Color tabInactive = textMuted;
}
