import 'package:flutter/services.dart';

/// Centralized utility for haptic feedback to ensure consistency and easy toggling.
class AppHaptics {
  static bool _enabled = true;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Light impact for micro-interactions like button presses or small selections.
  static Future<void> lightTap() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium impact for more significant actions like confirmation or toggle.
  static Future<void> mediumTap() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Selection click for scrolling through lists or changing discrete values.
  static Future<void> selection() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Success feedback for completed tasks (e.g., generation finished).
  static Future<void> success() async {
    if (!_enabled) return;
    // Success is often represented by a double light tap or a specific pattern.
    // Flutter's lightImpact is subtle enough for rapid succession.
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Error feedback for failed actions.
  static Future<void> error() async {
    if (!_enabled) return;
    await HapticFeedback.vibrate();
  }
}
