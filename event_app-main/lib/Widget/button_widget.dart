import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../app/config/app_text_style.dart';
import '../utils/haptic_utils.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final bool isLoading;

  const ButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed != null
            ? () {
                HapticUtils.buttonPress();
                onPressed!();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius!),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyles.buttontext,
              ),
      ),
    );
  }
}
