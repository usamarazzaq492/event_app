import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TransitionType {
  slide,
  fade,
  scale,
  rotate,
  slideUp,
  zoomIn,
}

class NavigationUtils {
  // Standard page transition duration
  static const Duration _transitionDuration = Duration(milliseconds: 300);

  // Standard page transition curve
  static const Curve _transitionCurve = Curves.easeInOut;

  // Common transition builders
  static Widget _slideTransition(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: _transitionCurve,
      )),
      child: child,
    );
  }

  static Widget _fadeTransition(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget _scaleTransition(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: _transitionCurve,
      )),
      child: child,
    );
  }

  static Widget _rotateTransition(Animation<double> animation, Widget child) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: _transitionCurve,
      )),
      child: child,
    );
  }

  static Widget _slideUpTransition(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: _transitionCurve,
      )),
      child: child,
    );
  }

  static Widget _zoomInTransition(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: child,
    );
  }

  /// Navigate to a new screen with standard transition
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget page, {
    String? routeName,
    bool fullscreenDialog = false,
    TransitionType transition = TransitionType.slide,
  }) {
    // Unfocus inputs when navigating away
    FocusScope.of(context).unfocus();
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: _transitionDuration,
        reverseTransitionDuration: _transitionDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _getTransition(transition, animation, child);
        },
        settings: routeName != null ? RouteSettings(name: routeName) : null,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Navigate using GetX (recommended for GetX apps)
  static Future<T?> getTo<T extends Object?>(
    Widget page, {
    String? routeName,
    Transition transition = Transition.rightToLeft,
    Duration? duration,
    bool fullscreenDialog = false,
  }) {
    // Unfocus inputs when navigating away
    final context = Get.context;
    if (context != null) {
      FocusScope.of(context).unfocus();
    }
    return Get.to<T>(
          () => page,
          routeName: routeName,
          transition: transition,
          duration: duration ?? _transitionDuration,
          fullscreenDialog: fullscreenDialog,
        ) ??
        Future.value(null);
  }

  /// Navigate and replace using GetX
  static Future<T?> getOff<T extends Object?>(
    Widget page, {
    String? routeName,
    Transition transition = Transition.rightToLeft,
    Duration? duration,
  }) {
    return Get.off<T>(
          () => page,
          routeName: routeName,
          transition: transition,
          duration: duration ?? _transitionDuration,
        ) ??
        Future.value(null);
  }

  /// Navigate and clear all previous screens using GetX
  static Future<T?> getOffAll<T extends Object?>(
    Widget page, {
    String? routeName,
    Transition transition = Transition.rightToLeft,
    Duration? duration,
  }) {
    return Get.offAll<T>(
          () => page,
          routeName: routeName,
          transition: transition,
          duration: duration ?? _transitionDuration,
        ) ??
        Future.value(null);
  }

  /// Get back using GetX
  static void getBack<T extends Object?>([T? result]) {
    Get.back<T>(result: result);
  }

  /// Get transition helper
  static Widget _getTransition(
      TransitionType type, Animation<double> animation, Widget child) {
    switch (type) {
      case TransitionType.slide:
        return _slideTransition(animation, child);
      case TransitionType.fade:
        return _fadeTransition(animation, child);
      case TransitionType.scale:
        return _scaleTransition(animation, child);
      case TransitionType.rotate:
        return _rotateTransition(animation, child);
      case TransitionType.slideUp:
        return _slideUpTransition(animation, child);
      case TransitionType.zoomIn:
        return _zoomInTransition(animation, child);
    }
  }

  /// Navigate to a new screen and replace current screen
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    String? routeName,
    TransitionType transition = TransitionType.slide,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: _transitionDuration,
        reverseTransitionDuration: _transitionDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _getTransition(transition, animation, child);
        },
        settings: routeName != null ? RouteSettings(name: routeName) : null,
      ),
    );
  }

  /// Navigate to a new screen and clear all previous screens
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget page, {
    String? routeName,
    bool Function(Route<dynamic>)? predicate,
    TransitionType transition = TransitionType.slide,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: _transitionDuration,
        reverseTransitionDuration: _transitionDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _getTransition(transition, animation, child);
        },
        settings: routeName != null ? RouteSettings(name: routeName) : null,
      ),
      predicate ?? (Route<dynamic> route) => false,
    );
  }

  /// Navigate back with standard transition
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Navigate back with custom transition
  static void popWithTransition<T extends Object?>(BuildContext context,
      [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Show modal bottom sheet with standard styling
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context,
    Widget child, {
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      builder: (context) => child,
    );
  }

  /// Show dialog with standard styling
  static Future<T?> showCustomDialog<T>(
    BuildContext context,
    Widget child, {
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (context) => child,
    );
  }

  /// Show snackbar with standard styling
  static void showSnackBar(
    String message, {
    String? title,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    EdgeInsets margin = const EdgeInsets.all(16),
    double borderRadius = 8,
    bool isDismissible = true,
    DismissDirection dismissDirection = DismissDirection.horizontal,
  }) {
    Get.snackbar(
      title ?? 'Notification',
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      snackPosition: snackPosition,
      margin: margin,
      borderRadius: borderRadius,
      isDismissible: isDismissible,
      dismissDirection: dismissDirection,
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              if (message != null) ...[
                SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Navigate with fade transition
  static Future<T?> pushWithFade<T extends Object?>(
    BuildContext context,
    Widget page, {
    String? routeName,
  }) {
    return push<T>(context, page,
        routeName: routeName, transition: TransitionType.fade);
  }

  /// Navigate with scale transition
  static Future<T?> pushWithScale<T extends Object?>(
    BuildContext context,
    Widget page, {
    String? routeName,
  }) {
    return push<T>(context, page,
        routeName: routeName, transition: TransitionType.scale);
  }

  /// Navigate with rotate transition
  static Future<T?> pushWithRotate<T extends Object?>(
    BuildContext context,
    Widget page, {
    String? routeName,
  }) {
    return push<T>(context, page,
        routeName: routeName, transition: TransitionType.rotate);
  }

  /// Navigate with slide up transition
  static Future<T?> pushWithSlideUp<T extends Object?>(
    BuildContext context,
    Widget page, {
    String? routeName,
  }) {
    return push<T>(context, page,
        routeName: routeName, transition: TransitionType.slideUp);
  }

  /// Navigate with zoom in transition
  static Future<T?> pushWithZoomIn<T extends Object?>(
    BuildContext context,
    Widget page, {
    String? routeName,
  }) {
    return push<T>(context, page,
        routeName: routeName, transition: TransitionType.zoomIn);
  }
}
