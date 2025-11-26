import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../MVVM/View/onboarding/onboarding_screen.dart';
import '../MVVM/View/bottombar/bottom_navigation_bar.dart';

class SplashUtils {
  /// Check if user has completed onboarding
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_seen') ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token') != null;
  }

  /// Get user's preferred home screen
  static Future<int> getPreferredHomeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('preferred_home_index') ?? 0;
  }

  /// Set user's preferred home screen
  static Future<void> setPreferredHomeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('preferred_home_index', index);
  }

  /// Navigate to appropriate screen after splash
  static Future<void> navigateAfterSplash(BuildContext context) async {
    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final isOnboardingCompleted = await SplashUtils.isOnboardingCompleted();
    final isLoggedIn = await SplashUtils.isUserLoggedIn();
    final preferredIndex = await SplashUtils.getPreferredHomeIndex();

    if (!isOnboardingCompleted) {
      // First time user - show onboarding
      Get.offAll(() => const OnboardingScreen());
    } else if (isLoggedIn) {
      // Logged in user - go to main app
      Get.offAll(() => BottomNavBar(initialIndex: preferredIndex));
    } else {
      // Returning user but not logged in - go to login
      Get.offAll(() => BottomNavBar(initialIndex: 0));
    }
  }

  /// Reset app data (for testing or logout)
  static Future<void> resetAppData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Get splash screen duration based on app state
  static Duration getSplashDuration() {
    // You can customize this based on your needs
    return const Duration(milliseconds: 3000);
  }

  /// Check if app is in debug mode
  static bool isDebugMode() {
    bool isDebug = false;
    assert(isDebug = true);
    return isDebug;
  }

  /// Get app version for splash screen
  static String getAppVersion() {
    return '1.0.0'; // You can get this from package_info_plus
  }

  /// Get build number for splash screen
  static String getBuildNumber() {
    return '1'; // You can get this from package_info_plus
  }
}
