import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xffF0F0F0); // Light primary
  static const Color whiteColor = Color(0xffffffff);
  static const Color blueColor = Color(0xff584CF4);
  static const Color lightColor = Color(0xff8989f6);
  static const Color dotColor = Color(0xffD0D0D0); // Lighter dot
  static const Color backgroundColor = Color(0xFFF8F9FA); // Off-white scaffold background
  static const Color signinoptioncolor = Color(0xFFFFFFFF); // Pure white card background
  static const Color signinoptionbordercolor = Color(0xffE0E0E0); // Light border
  static const Color searchtextcolor = Color(0xffA0A0A0);
  static const Color bottombarcolor = Color(0xffFFFFFF); // White bottom bar
  static const Color tabtextcolor = Color(0xff808080); // Adjusted tab text

  // New text semantic colors for future proofing
  static const Color textColorPrimary = Color(0xFF1E1E1E);
  static const Color textColorSecondary = Color(0xFF757575);
  static const Gradient primaryGradient = LinearGradient(
    colors: [blueColor, lightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
