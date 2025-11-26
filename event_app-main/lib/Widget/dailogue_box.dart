import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:sizer/sizer.dart';

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pop(); // close the dialog
        Navigator.of(context).pushReplacementNamed('/home'); // navigate to Home
      });

      return Dialog(
        backgroundColor: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.h),
        ),
        child: Container(
          padding:  EdgeInsets.symmetric(horizontal:5.w, vertical: 3.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shield Icon
             Image.asset(AppImages.dailogueimg),
              const SizedBox(height: 20),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB8A7FF),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your account is ready to use. You will be redirected to the Home page in a few seconds..',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              ),
            ],
          ),
        ),
      );
    },
  );
}
