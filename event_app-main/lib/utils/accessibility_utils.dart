import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityUtils {
  /// Add semantic labels for screen readers
  static Widget addSemantics({
    required Widget child,
    String? label,
    String? hint,
    bool? isButton,
    bool? isHeader,
    bool? isImage,
    bool? isTextField,
    bool? isSelected,
    bool? isEnabled,
    String? value,
    String? increasedValue,
    String? decreasedValue,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton ?? false,
      header: isHeader ?? false,
      image: isImage ?? false,
      textField: isTextField ?? false,
      selected: isSelected ?? false,
      enabled: isEnabled ?? true,
      value: value,
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// Create accessible button
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    String? label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: enabled ? onPressed : null,
      child: child,
    );
  }

  /// Create accessible image
  static Widget accessibleImage({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(
      image: true,
      label: label,
      hint: hint,
      child: child,
    );
  }

  /// Create accessible text field
  static Widget accessibleTextField({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool enabled = true,
  }) {
    return Semantics(
      textField: true,
      enabled: enabled,
      label: label,
      hint: hint,
      value: value,
      child: child,
    );
  }

  /// Create accessible list item
  static Widget accessibleListItem({
    required Widget child,
    required String label,
    String? hint,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible header
  static Widget accessibleHeader({
    required Widget child,
    required String label,
    int level = 1,
  }) {
    return Semantics(
      header: true,
      label: label,
      child: child,
    );
  }

  /// Create accessible progress indicator
  static Widget accessibleProgressIndicator({
    required Widget child,
    required String label,
    double? value,
  }) {
    return Semantics(
      label: label,
      value: value != null ? '${(value * 100).round()}%' : null,
      child: child,
    );
  }

  /// Create accessible tab
  static Widget accessibleTab({
    required Widget child,
    required String label,
    required bool selected,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      hint: selected ? 'Selected tab' : 'Tab',
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible card
  static Widget accessibleCard({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: onTap != null,
      label: label,
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible icon
  static Widget accessibleIcon({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: onTap != null,
      label: label,
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }

  /// Announce message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Create accessible bottom navigation
  static Widget accessibleBottomNavigation({
    required Widget child,
    required String label,
    required bool selected,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      hint: selected ? 'Selected $label tab' : '$label tab',
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible floating action button
  static Widget accessibleFloatingActionButton({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onPressed,
  }) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      onTap: onPressed,
      child: child,
    );
  }

  /// Create accessible switch
  static Widget accessibleSwitch({
    required Widget child,
    required String label,
    required bool value,
    String? hint,
    ValueChanged<bool>? onChanged,
  }) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      value: value ? 'On' : 'Off',
      onTap: onChanged != null ? () => onChanged(!value) : null,
      child: child,
    );
  }

  /// Create accessible slider
  static Widget accessibleSlider({
    required Widget child,
    required String label,
    required double value,
    required double min,
    required double max,
    String? hint,
  }) {
    return Semantics(
      slider: true,
      label: label,
      hint: hint,
      value: '${value.round()}',
      increasedValue: '${(value + 1).round()}',
      decreasedValue: '${(value - 1).round()}',
      child: child,
    );
  }
}

