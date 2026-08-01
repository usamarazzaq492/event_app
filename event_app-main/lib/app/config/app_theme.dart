import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      // Primary colors
      primaryColor: AppColors.blueColor,
      primaryColorDark: AppColors.blueColor,
      primaryColorLight: AppColors.lightColor,

      // Ensure text colors are always visible
      brightness: Brightness.light,

      // Scaffold and background
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        iconTheme: IconThemeData(
          color: AppColors.textColorPrimary,
          size: 24,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorPrimary,
            fontFamily: 'Montserrat',
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blueColor,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.blueColor,
            fontFamily: 'Montserrat',
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textColorPrimary,
          side: const BorderSide(color: AppColors.blueColor),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorPrimary,
            fontFamily: 'Montserrat',
          ),
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textColorPrimary,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.signinoptioncolor,
        hintStyle: const TextStyle(
          color: AppColors.textColorSecondary,
          fontSize: 14,
          fontFamily: 'Montserrat',
        ),
        labelStyle: const TextStyle(
          color: AppColors.textColorPrimary,
          fontSize: 14,
          fontFamily: 'Montserrat',
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          fontFamily: 'Montserrat',
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blueColor, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.signinoptioncolor,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottombarcolor,
        selectedItemColor: AppColors.blueColor,
        unselectedItemColor: AppColors.textColorSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w400,
          fontFamily: 'Montserrat',
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.withValues(alpha: 0.3),
        thickness: 0.5,
        space: 1,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.textColorPrimary,
        size: 24,
      ),

      // Global text color override to ensure visibility
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.blueColor,
        selectionColor: AppColors.blueColor.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.blueColor,
      ),

      // Text theme with fixed sizes (no Sizer dependency)
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        headlineLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        titleMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        titleSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade400,
          fontFamily: 'Montserrat',
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textColorPrimary,
          fontFamily: 'Montserrat',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
          fontFamily: 'Montserrat',
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
          fontFamily: 'Montserrat',
        ),
      ),

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.blueColor,
        secondary: AppColors.lightColor,
        surface: AppColors.signinoptioncolor,
        error: Colors.redAccent,
        onPrimary: AppColors.textColorPrimary,
        onSecondary: AppColors.textColorPrimary,
        onSurface: AppColors.textColorPrimary,
        onError: AppColors.textColorPrimary,
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.blueColor,
        linearTrackColor: Colors.grey.withValues(alpha: 0.3),
        circularTrackColor: Colors.grey.withValues(alpha: 0.3),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.blueColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
