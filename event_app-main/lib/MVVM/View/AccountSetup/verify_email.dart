import 'dart:async';
import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyEmail extends StatefulWidget {
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

      // Call register again to resend code (backend should handle this)
      // For now, we'll use a simple approach - the backend register endpoint
      // should resend the code when called with existing email
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
      body: Padding(
        padding: EdgeInsets.only(top: 7.h, left: 5.w, right: 5.w, bottom: 3.h),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  'Email verification',
                  style: TextStyles.profiletext,
                )
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            Text(
              'Code has been send to your email',
              style: TextStyles.regularwhite,
            ),
            SizedBox(
              height: 5.h,
            ),
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
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              controller: otpController,
              onCompleted: (v) {
                print("Completed");
              },
              onChanged: (value) {
                print(value);
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                return true;
              },
              appContext: context,
            ),
            SizedBox(
              height: 5.h,
            ),
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
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ButtonWidget(
                  text: 'Verify',
                  onPressed: () {
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
