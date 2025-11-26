import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SignInCard extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final String image;
  final Color? textColor;
  final double? borderRadius;
  final bool isLoading;

  const SignInCard({
    Key? key,
    required this.text,
    required this.image,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h),
          border: Border.all(
              color: AppColors.signinoptionbordercolor, width: 0.4.w)),
      child:
          // isLoading
          //     ? const SizedBox(
          //   width: 20,
          //   height: 20,
          //   child: CircularProgressIndicator(
          //     color: Colors.white,
          //     strokeWidth: 2,
          //   ),
          // ):
          Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 4.h,
          ),
          SizedBox(
            width: 3.w,
          ),
          Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
