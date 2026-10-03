class HexValidator {
  HexValidator._();

  static final RegExp _hexRegex = RegExp(r'^#([A-Fa-f0-9]{6})$');

  static bool isValid(String hex) => _hexRegex.hasMatch(hex);

  /// Ensures the string starts with # and is 7 chars.
  static String normalise(String hex) {
    final trimmed = hex.trim();
    if (trimmed.startsWith('#')) return trimmed.toUpperCase();
    return '#${trimmed.toUpperCase()}';
  }

  /// Returns null if invalid, otherwise the normalised hex string.
  static String? validate(String hex) {
    final n = normalise(hex);
    return isValid(n) ? n : null;
  }
}