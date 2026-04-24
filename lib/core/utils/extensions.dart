import 'package:flutter/material.dart';

extension StringX on String {
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  bool get isValidEmail {
    final emailReg = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailReg.hasMatch(trim());
  }

  bool get isValidName => trim().length >= 2;

  String truncate(int maxLength, {String ellipsis = '…'}) =>
      length > maxLength ? '${substring(0, maxLength)}$ellipsis' : this;

  String get languageCode {
    const map = {
      'German': 'de',
      'Spanish': 'es',
      'French': 'fr',
      'Italian': 'it',
      'Japanese': 'ja',
      'Korean': 'ko',
      'Portuguese': 'pt',
      'Mandarin': 'zh',
      'Arabic': 'ar',
      'Hindi': 'hi',
      'Turkish': 'tr',
      'Dutch': 'nl',
      'Polish': 'pl',
      'Russian': 'ru',
      'Swedish': 'sv',
      'English': 'en',
    };
    return map[this] ?? 'en';
  }
}

extension IntX on int {
  String get xpFormatted => '${this}XP';

  String get durationFormatted {
    if (this < 60) return '${this}s';
    final m = this ~/ 60;
    final s = this % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }
}

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get friendlyDate {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return '$day/$month/$year';
  }
}

extension ColorX on Color {
  Color withOpacityValue(double opacity) =>
      withValues(alpha: opacity);
}

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isSmallScreen => screenWidth < 380;
}
