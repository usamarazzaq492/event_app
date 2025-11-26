import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../app/config/app_colors.dart';
import '../app/config/app_text_style.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;

  const AppErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 15.w,
              color: Colors.redAccent,
            ),
            SizedBox(height: 3.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyles.homeheadingtext.copyWith(
                fontSize: 16.sp,
                color: AppColors.whiteColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              message,
              style: TextStyles.regularwhite.copyWith(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 16.sp),
                label: Text(
                  retryText ?? 'Try Again',
                  style: TextStyles.buttontext,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppEmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const AppEmptyStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 20.w,
              color: Colors.grey,
            ),
            SizedBox(height: 3.h),
            Text(
              title,
              style: TextStyles.homeheadingtext.copyWith(
                fontSize: 16.sp,
                color: AppColors.whiteColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              message,
              style: TextStyles.regularwhite.copyWith(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.add, size: 16.sp),
                label: Text(
                  actionText ?? 'Get Started',
                  style: TextStyles.buttontext,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppLoadingWidget extends StatelessWidget {
  final String? message;

  const AppLoadingWidget({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
            strokeWidth: 3,
          ),
          if (message != null) ...[
            SizedBox(height: 3.h),
            Text(
              message!,
              style: TextStyles.regularwhite.copyWith(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
