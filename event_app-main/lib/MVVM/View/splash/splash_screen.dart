import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../app/config/app_asset.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthViewModel _authViewModel = Get.put(AuthViewModel());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /// ✅ Pre-cache splash and welcome images for smooth UI
      await precacheImage(const AssetImage(AppImages.logo2), context);
      await precacheImage(const AssetImage(AppImages.welcomeImg), context);

      /// ✅ Delay splash screen for branding then check login
      await Future.delayed(const Duration(seconds: 2));
      _authViewModel.checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 1),
          tween: Tween(begin: 0.8, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            final opacity = ((value - 0.8) * 5).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: value,
                child: child,
              ),
            );
          },
          child: Image.asset(AppImages.logo2, height: 15.h),
        ),
      ),
    );
  }
}
