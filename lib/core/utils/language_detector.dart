/// Detects whether a piece of text is written in the script expected for a
/// given source language. Uses Unicode block ranges, so it can only
/// distinguish across scripts (e.g. Devanagari vs. Latin, Cyrillic vs.
/// Arabic) — Latin-based languages such as English, French, German, etc.
/// all share the Latin script and are treated interchangeably.
abstract final class LanguageDetector {
  static const Map<String, String> _languageScript = {
    'English': 'Latin',
    'German': 'Latin',
    'Spanish': 'Latin',
    'French': 'Latin',
    'Italian': 'Latin',
    'Portuguese': 'Latin',
    'Dutch': 'Latin',
    'Polish': 'Latin',
    'Swedish': 'Latin',
    'Turkish': 'Latin',
    'Hindi': 'Devanagari',
    'Japanese': 'Japanese',
    'Korean': 'Hangul',
    'Mandarin': 'Han',
    'Arabic': 'Arabic',
    'Russian': 'Cyrillic',
  };

  static String? _scriptOf(int cu) {
    if ((cu >= 0x0041 && cu <= 0x005A) ||
        (cu >= 0x0061 && cu <= 0x007A) ||
        (cu >= 0x00C0 && cu <= 0x024F) ||
        (cu >= 0x1E00 && cu <= 0x1EFF)) {
      return 'Latin';
    }
    if (cu >= 0x0900 && cu <= 0x097F) return 'Devanagari';
    if (cu >= 0x0400 && cu <= 0x04FF) return 'Cyrillic';
    if ((cu >= 0x0600 && cu <= 0x06FF) ||
        (cu >= 0x0750 && cu <= 0x077F) ||
        (cu >= 0xFB50 && cu <= 0xFDFF) ||
        (cu >= 0xFE70 && cu <= 0xFEFF)) {
      return 'Arabic';
    }
    if ((cu >= 0xAC00 && cu <= 0xD7AF) ||
        (cu >= 0x1100 && cu <= 0x11FF) ||
        (cu >= 0x3130 && cu <= 0x318F)) {
      return 'Hangul';
    }
    if ((cu >= 0x3040 && cu <= 0x309F) || (cu >= 0x30A0 && cu <= 0x30FF)) {
      return 'Japanese';
    }
    if ((cu >= 0x4E00 && cu <= 0x9FFF) || (cu >= 0x3400 && cu <= 0x4DBF)) {
      return 'Han';
    }
    return null;
  }

  /// Returns true when the dominant script of [text] is consistent with
  /// [language]. Returns true for empty/punctuation-only text and for
  /// languages outside the known set.
  static bool matchesLanguage(String text, String language) {
    final expected = _languageScript[language];
    if (expected == null) return true;

    final counts = <String, int>{};
    var total = 0;
    for (final cu in text.runes) {
      final script = _scriptOf(cu);
      if (script == null) continue;
      counts[script] = (counts[script] ?? 0) + 1;
      total++;
    }
    if (total == 0) return true;

    const threshold = 0.6;
    switch (expected) {
      case 'Han':
        final han = counts['Han'] ?? 0;
        final jp = counts['Japanese'] ?? 0;
        if (jp > 0) return false;
        return han / total >= threshold;
      case 'Japanese':
        final jp = counts['Japanese'] ?? 0;
        final han = counts['Han'] ?? 0;
        return (jp + han) / total >= threshold;
      default:
        final match = counts[expected] ?? 0;
        return match / total >= threshold;
    }
  }
}
