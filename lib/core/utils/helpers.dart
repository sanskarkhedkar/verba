import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract final class Helpers {
  /// Return a greeting based on current hour.
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Format DateTime to user-friendly string.
  static String formatDate(DateTime dt) =>
      DateFormat('MMM d, yyyy').format(dt);

  /// Format duration in minutes to "Xm Ys" string.
  static String formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }

  /// Compute XP needed to reach next level label.
  static String xpLevelLabel(int xp) {
    if (xp < 500) return 'A1';
    if (xp < 2000) return 'A2';
    if (xp < 5000) return 'B1';
    if (xp < 10000) return 'B2';
    return 'C1+';
  }

  static int xpToNextLevel(int xp) {
    if (xp < 500) return 500 - xp;
    if (xp < 2000) return 2000 - xp;
    if (xp < 5000) return 5000 - xp;
    if (xp < 10000) return 10000 - xp;
    return 0;
  }

  static double xpProgress(int xp) {
    if (xp < 500) return xp / 500;
    if (xp < 2000) return (xp - 500) / 1500;
    if (xp < 5000) return (xp - 2000) / 3000;
    if (xp < 10000) return (xp - 5000) / 5000;
    return 1.0;
  }

  /// Clamp a value between min/max.
  static double clamp(double value, double min, double max) =>
      value.clamp(min, max);

  /// Map amplitude (0.0–1.0) to bar height for waveform.
  static double amplitudeToBarHeight(double amplitude, double maxHeight) =>
      clamp(amplitude, 0.05, 1.0) * maxHeight;

  static Color accuracyColor(int accuracy) {
    if (accuracy >= 85) return const Color(0xFF10B981);
    if (accuracy >= 65) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
