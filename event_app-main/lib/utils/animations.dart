import 'package:flutter/material.dart';

class AppAnimations {
  // Standard animation durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Standard animation curves
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeInOutCubic;

  /// Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = standardCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide in from bottom animation
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = slideCurve,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value * MediaQuery.of(context).size.height,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide in from right animation
  static Widget slideInFromRight({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = slideCurve,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: const Offset(1, 0), end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value * MediaQuery.of(context).size.width,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = bounceCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Staggered animation for lists
  static Widget staggeredItem({
    required Widget child,
    required int index,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration duration = mediumDuration,
    Curve curve = standardCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration + (staggerDelay * index),
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Bounce animation for buttons
  static Widget bounceIn({
    required Widget child,
    Duration duration = shortDuration,
    Curve curve = bounceCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Shake animation for errors
  static Widget shake({
    required Widget child,
    Duration duration = shortDuration,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final shakeOffset = (value * 10 * (1 - value)).clamp(0.0, 10.0);
        return Transform.translate(
          offset: Offset(shakeOffset * (value < 0.5 ? 1 : -1), 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Pulse animation for loading states
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Slide up animation for bottom sheets
  static Widget slideUp({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = slideCurve,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value * MediaQuery.of(context).size.height,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Rotation animation
  static Widget rotateIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = standardCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: (1 - value) * 0.5,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Fade in with scale animation
  static Widget fadeInScale({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = standardCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Slide in from left animation
  static Widget slideInFromLeft({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = slideCurve,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: const Offset(-1, 0), end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value * MediaQuery.of(context).size.width,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animated container with smooth transitions
  static Widget animatedContainer({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = standardCurve,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// Animated opacity
  static Widget animatedOpacity({
    required Widget child,
    required bool visible,
    Duration duration = shortDuration,
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      child: child,
    );
  }

  /// Animated size
  static Widget animatedSize({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = standardCurve,
  }) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}
