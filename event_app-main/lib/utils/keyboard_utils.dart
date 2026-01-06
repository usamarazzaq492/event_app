import 'package:flutter/material.dart';

/// Utility class for handling keyboard and focus management
class KeyboardUtils {
  /// Unfocus all input fields
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Unfocus all input fields and hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
    // Also dismiss keyboard if it's showing
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

/// Widget that unfocuses inputs when tapped outside
class UnfocusOnTap extends StatelessWidget {
  final Widget child;

  const UnfocusOnTap({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus any focused input when tapping outside
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

/// Mixin to handle unfocusing on navigation
mixin UnfocusOnNavigation<T extends StatefulWidget> on State<T> {
  @override
  void dispose() {
    // Unfocus when widget is disposed (navigating away)
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    // Unfocus when widget is deactivated (navigating away)
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
    super.deactivate();
  }
}
