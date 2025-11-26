import 'package:flutter/services.dart';

class HapticUtils {
  /// Light haptic feedback for subtle interactions
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for standard button presses
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for important actions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback for toggles and selections
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Success haptic feedback for successful actions
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Error haptic feedback for errors and failures
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Warning haptic feedback for warnings
  static void warning() {
    HapticFeedback.lightImpact();
  }

  /// Navigation haptic feedback for navigation actions
  static void navigation() {
    HapticFeedback.selectionClick();
  }

  /// Button press haptic feedback
  static void buttonPress() {
    HapticFeedback.lightImpact();
  }

  /// Toggle haptic feedback
  static void toggle() {
    HapticFeedback.selectionClick();
  }

  /// Swipe haptic feedback
  static void swipe() {
    HapticFeedback.lightImpact();
  }

  /// Long press haptic feedback
  static void longPress() {
    HapticFeedback.mediumImpact();
  }

  /// Double tap haptic feedback
  static void doubleTap() {
    HapticFeedback.lightImpact();
  }

  /// Custom haptic feedback with specific intensity
  static void custom(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}
