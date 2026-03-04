import 'dart:async';
import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  TextEditingController otpController = TextEditingController();
  final authViewModel = Get.put(AuthViewModel());

  Timer? _timer;
  int _countdown = 60; // Start with 60 seconds
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _canResend = false;
    setState(() {});

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    try {
      HapticUtils.light();
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('registered_email') ?? '';

      if (email.isEmpty) {
        Get.snackbar(
          "Error",
          "Email not found. Please register again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Show loading
      Get.snackbar(
        "Sending",
        "Resending verification code...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.blueColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      await authViewModel.resendVerificationCode(email);

      // Restart countdown
      _startCountdown();

      Get.snackbar(
        "Success",
        "Verification code has been resent to your email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to resend code: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          /// Gradient header (App style)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 2.h,
              left: 4.w,
              right: 4.w,
              bottom: 6.h,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.backgroundColor,
                  AppColors.signinoptioncolor,
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.whiteColor,
                        size: 20,
                      ),
                      onPressed: () {
                        HapticUtils.navigation();
                        Get.back();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Hero(
                  tag: 'app-logo',
                  child: Image.asset(
                    AppImages.logo2,
                    height: 10.h,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Account Activation',
                  style: TextStyles.heading.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          /// Verification content
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.signinoptioncolor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: AppColors.signinoptionbordercolor,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 4.h),
                  child: Column(
                    children: [
                      Text(
                        'Email Verification',
                        style: TextStyles.heading.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Code has been sent to your email',
                        textAlign: TextAlign.center,
                        style: TextStyles.regularwhite.copyWith(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      PinCodeTextField(
                        keyboardType: TextInputType.number,
                        length: 4,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        cursorColor: AppColors.blueColor,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 8.h,
                          fieldWidth: 8.h,
                          activeFillColor: AppColors.signinoptioncolor,
                          activeColor: AppColors.signinoptionbordercolor,
                          selectedFillColor: AppColors.signinoptionbordercolor,
                          selectedColor: AppColors.blueColor,
                          inactiveColor: AppColors.signinoptionbordercolor,
                          inactiveFillColor: AppColors.signinoptionbordercolor,
                        ),
                        textStyle: TextStyles.regularwhite,
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        controller: otpController,
                        appContext: context,
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 5.h),
                      // Resend code section
                      _canResend
                          ? GestureDetector(
                              onTap: _resendCode,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: AppColors.blueColor,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Resend Code',
                                    style: TextStyles.regularwhite.copyWith(
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Resend code in ',
                                  style: TextStyles.regularwhite,
                                ),
                                Text(
                                  '$_countdown',
                                  style: TextStyles.regularwhite.copyWith(
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Text(
                                  's',
                                  style: TextStyles.regularwhite,
                                ),
                              ],
                            ),
                      const Spacer(),
                      ButtonWidget(
                        text: 'Verify',
                        onPressed: () {
                          HapticUtils.medium();
                          final code = otpController.text.trim();
                          if (code.length == 4) {
                            authViewModel.verifyEmail(code);
                          } else {
                            Get.snackbar(
                              "Error",
                              "Please enter the complete 4-digit code",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        backgroundColor: AppColors.blueColor,
                        borderRadius: 4.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
