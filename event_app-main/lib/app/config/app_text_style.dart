import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'app_colors.dart';

class TextStyles {
  static TextStyle get heading => TextStyle(
        fontSize: 16.sp,
        color: AppColors.whiteColor,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );

  static TextStyle get subheading => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.blueColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );

  static TextStyle get regulartext => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.blueColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get regularwhite => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get regularhint => TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w200,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get regularhometext => TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get regularlocatext => TextStyle(
        fontSize: 7.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.whiteColor,
        overflow: TextOverflow.ellipsis,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get regularhometext1 => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get tabtext => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.tabtextcolor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get regularhometext2 => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get regularhometextblue => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.blueColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get regularhomedatetext => TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.blueColor,
        overflow: TextOverflow.ellipsis,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );

  static TextStyle get buttontext => TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get profiletext => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get searchtext => TextStyle(
        fontSize: 8.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.searchtextcolor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get homeheadingtext => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get tickettext => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get homedatetext => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.blueColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
  static TextStyle get ticketwhitetext => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.whiteColor,
        fontFamily: 'Montserrat',
        fontFamilyFallback: const ['Inter', 'Roboto', 'Arial'],
      );
}
