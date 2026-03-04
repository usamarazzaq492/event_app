import 'package:flutter/material.dart';
import '../../../app/config/app_asset.dart';
import '../../../app/config/app_pages.dart';
import 'package:event_app/utils/haptic_utils.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to OnboardingScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      HapticUtils.light();
      Navigator.pushReplacementNamed(context, RouteName.onboardScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  AppImages.welcomeImg,
                ),
                fit: BoxFit.fill)),
      ),
    );
  }
}
