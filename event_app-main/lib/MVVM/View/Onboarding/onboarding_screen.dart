import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_pages.dart';
import 'package:event_app/app/config/app_strings.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardData = [
    {
      "image": AppImages.onboardImg1,
      "title": AppStrings.onboardText1,
    },
    {
      "image": AppImages.onboardImg2,
      "title": AppStrings.onboardText4,
    },
  ];

  /// ✅ Save onboarding seen flag
  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onNextPressed() async {
    if (currentIndex == onboardData.length - 1) {
      await setOnboardingSeen();
      if (mounted) {
        Get.offAllNamed(RouteName.loginScreen); // Using GetX navigation
      }
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Padding(
        padding: EdgeInsets.only(top: 7.h),
        child: Stack(
          children: [
            /// PageView
            Positioned.fill(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: onboardData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  image: onboardData[index]["image"]!,
                  title: onboardData[index]["title"]!,
                ),
              ),
            ),

            /// Dots Indicator
            Positioned(
              bottom: 13.h,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: onboardData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.blueColor,
                    dotColor: Colors.grey,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
              ),
            ),

            /// Next/Get Started Button
            Positioned(
              bottom: 5.h,
              left: 5.w,
              right: 5.w,
              child: ButtonWidget(
                text: currentIndex == onboardData.length - 1
                    ? "Get Started"
                    : "Next",
                onPressed: onNextPressed,
                backgroundColor: AppColors.blueColor,
                borderRadius: 4.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String image, title;

  const OnboardingContent({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Image area covering remaining height above bottom container
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              semanticLabel: title,
            ),
          ),
        ),

        /// Bottom Container
        Container(
          height: 40.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.h),
              topRight: Radius.circular(4.h),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 3.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyles.subheading,
              ),
              SizedBox(height: 2.h),
              Text(
                AppStrings.onboardText2,
                textAlign: TextAlign.center,
                style: TextStyles.regularhometext,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
