import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TypographyScale {
  // Base font sizes for different screen sizes
  static double get _baseFontSize {
    if (1.h < 6) return 12; // Small screens
    if (1.h < 8) return 14; // Medium screens
    return 16; // Large screens
  }

  // Scale factor based on screen size
  static double get _scaleFactor {
    final screenHeight = 100.h;
    if (screenHeight < 600) return 0.8; // Small screens
    if (screenHeight < 800) return 0.9; // Medium screens
    if (screenHeight < 1000) return 1.0; // Large screens
    return 1.1; // Extra large screens
  }

  // Responsive font size calculation
  static double responsiveFontSize(double baseSize) {
    return (baseSize * _scaleFactor * _baseFontSize / 16).clamp(8.0, 32.0);
  }

  // Typography styles with better hierarchy
  static TextStyle get displayLarge => TextStyle(
        fontSize: responsiveFontSize(32),
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: responsiveFontSize(28),
        fontWeight: FontWeight.w800,
        letterSpacing: -0.25,
        height: 1.25,
      );

  static TextStyle get displaySmall => TextStyle(
        fontSize: responsiveFontSize(24),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get headlineLarge => TextStyle(
        fontSize: responsiveFontSize(22),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: responsiveFontSize(20),
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontSize: responsiveFontSize(18),
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get titleLarge => TextStyle(
        fontSize: responsiveFontSize(16),
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.45,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: responsiveFontSize(12),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: responsiveFontSize(16),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: responsiveFontSize(12),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
      );

  static TextStyle get labelLarge => TextStyle(
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: responsiveFontSize(12),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: responsiveFontSize(10),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  // Custom styles for specific use cases
  static TextStyle get button => TextStyle(
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.2,
      );

  static TextStyle get caption => TextStyle(
        fontSize: responsiveFontSize(11),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get overline => TextStyle(
        fontSize: responsiveFontSize(10),
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        height: 1.2,
      );

  // Event-specific typography
  static TextStyle get eventTitle => TextStyle(
        fontSize: responsiveFontSize(18),
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        height: 1.3,
      );

  static TextStyle get eventSubtitle => TextStyle(
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get eventCaption => TextStyle(
        fontSize: responsiveFontSize(12),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.4,
      );

  // Profile-specific typography
  static TextStyle get profileName => TextStyle(
        fontSize: responsiveFontSize(20),
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.2,
      );

  static TextStyle get profileTitle => TextStyle(
        fontSize: responsiveFontSize(16),
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get profileBio => TextStyle(
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
      );

  // Navigation typography
  static TextStyle get navLabel => TextStyle(
        fontSize: responsiveFontSize(11),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.2,
      );

  // Card typography
  static TextStyle get cardTitle => TextStyle(
        fontSize: responsiveFontSize(16),
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get cardSubtitle => TextStyle(
        fontSize: responsiveFontSize(13),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get cardCaption => TextStyle(
        fontSize: responsiveFontSize(11),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.4,
      );

  // Form typography
  static TextStyle get formLabel => TextStyle(
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get formHint => TextStyle(
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      );

  static TextStyle get formError => TextStyle(
        fontSize: responsiveFontSize(12),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.4,
      );

  // Status typography
  static TextStyle get statusSuccess => TextStyle(
        fontSize: responsiveFontSize(13),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.4,
      );

  static TextStyle get statusWarning => TextStyle(
        fontSize: responsiveFontSize(13),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.4,
      );

  static TextStyle get statusError => TextStyle(
        fontSize: responsiveFontSize(13),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.4,
      );

  // Price typography
  static TextStyle get priceLarge => TextStyle(
        fontSize: responsiveFontSize(24),
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get priceMedium => TextStyle(
        fontSize: responsiveFontSize(18),
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.3,
      );

  static TextStyle get priceSmall => TextStyle(
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );
}
