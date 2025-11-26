import 'package:event_app/MVVM/View/splash/splash_screen.dart';
import 'package:event_app/MVVM/View/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'app/config/app_routes.dart';
import 'app/config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload fonts to ensure they're available immediately
  await _preloadFonts();

  // Debug: Print theme info
  debugPrint('App starting with dark theme mode');
  debugPrint('Theme brightness: ${AppTheme.darkTheme.brightness}');
  debugPrint('Primary color: ${AppTheme.darkTheme.primaryColor}');

  runApp(const MyApp());
}

/// Preload custom fonts to prevent text visibility issues
Future<void> _preloadFonts() async {
  try {
    // Load Montserrat fonts
    await rootBundle.load('assets/fonts/Montserrat-Regular.ttf');
    await rootBundle.load('assets/fonts/Montserrat-Bold.ttf');

    // Load Inter fonts
    await rootBundle.load('assets/fonts/Inter-Regular.ttf');
    await rootBundle.load('assets/fonts/Inter-Bold.ttf');
  } catch (e) {
    debugPrint('Font loading error: $e');
    // Continue app execution even if font loading fails
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    return seen;
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EventGo',
        themeMode: ThemeMode.dark,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        home: FutureBuilder<bool>(
          future: checkOnboardingSeen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              if (snapshot.data == true) {
                return const SplashScreen();
              } else {
                return const OnboardingScreen();
              }
            }
          },
        ),
        onGenerateRoute: Routes.generateRoute,
      );
    });
  }
}
