import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/EventDetailScreen/event_detail_screen.dart';
import 'package:event_app/MVVM/View/Promotion/select_event_to_promote_screen.dart';
import 'package:event_app/MVVM/body_model/ads_model.dart';
import 'package:event_app/MVVM/view_model/ad_view_model.dart';
import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_pages.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/refresh_on_navigation_mixin.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AllAdsScreen extends StatefulWidget {
  const AllAdsScreen({super.key});

  @override
  State<AllAdsScreen> createState() => _AllAdsScreenState();
}

class _AllAdsScreenState extends State<AllAdsScreen> with RefreshOnNavigation {
  final adVM = Get.put(AdViewModel());
  final authViewModel = Get.put(AuthViewModel());

  @override
  void refreshData() {
    adVM.fetchAds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background Glow Effect
          Positioned(
            top: -10.h,
            right: -10.w,
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blueColor.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeader(),

                // Promoted Events List
                Expanded(child: _buildPromotedEventsList()),

                // Promote Event Button (Fixed at bottom)
                _buildPromoteButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoteButton() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.7),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 6.5.h,
              child: GestureDetector(
                onTap: () {
                  HapticUtils.buttonPress();
                  if (!authViewModel.isLoggedIn.value) {
                    Get.snackbar(
                      'Sign in to promote',
                      'Create an account to promote your events.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.signinoptioncolor,
                      colorText: Colors.white,
                      mainButton: TextButton(
                        onPressed: () => Get.toNamed(RouteName.loginScreen),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectEventToPromoteScreen(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.blueColor,
                        AppColors.blueColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(2.h),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blueColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "Promote Your Event",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon and Title
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.2.h),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1.2.h),
                        border: Border.all(
                          color: AppColors.blueColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.blueColor,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Promoted",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Obx(() => Text(
                                "${adVM.ads.length} active promotion${adVM.ads.length != 1 ? 's' : ''}",
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.white38,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Refresh Button
              GestureDetector(
                onTap: () {
                  HapticUtils.light();
                  adVM.fetchAds();
                },
                child: Container(
                  padding: EdgeInsets.all(1.2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white70,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotedEventsList() {
    return RefreshIndicator(
      onRefresh: adVM.fetchAds,
      color: AppColors.blueColor,
      backgroundColor: AppColors.signinoptioncolor,
      child: Obx(() {
        if (adVM.isLoading.value && adVM.ads.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else if (adVM.error.isNotEmpty) {
          // Show friendly message for auth/network errors instead of raw exception
          final isAuthError =
              adVM.error.value.toLowerCase().contains('unauthenticated') ||
                  adVM.error.value.contains('401') ||
                  adVM.error.value.toLowerCase().contains('unauthorized');
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 20.h),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAuthError ? Icons.info_outline : Icons.cloud_off,
                        size: 48.sp,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isAuthError
                            ? 'Pull to refresh promoted events'
                            : 'Something went wrong. Pull to refresh.',
                        style: TextStyles.regularwhite.copyWith(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      TextButton.icon(
                        onPressed: () => adVM.fetchAds(),
                        icon: const Icon(Icons.refresh,
                            color: Colors.white70, size: 20),
                        label: Text(
                          'Retry',
                          style: TextStyles.regularwhite.copyWith(
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else if (adVM.ads.isEmpty) {
          return _buildEmptyState();
        } else {
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: adVM.ads.length,
            separatorBuilder: (_, __) => SizedBox(height: 2.h),
            itemBuilder: (context, index) =>
                _buildPromotedEventCard(adVM.ads[index]),
          );
        }
      }),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 10.h),
        Center(
          child: Column(
            children: [
              Image.asset(AppImages.emptyImg, height: 25.h),
              SizedBox(height: 2.h),
              Text(
                "No Promoted Events",
                style: TextStyles.homeheadingtext,
              ),
              SizedBox(height: 1.h),
              Text(
                "Be the first to promote your event!",
                textAlign: TextAlign.center,
                style: TextStyles.regularwhite.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotedEventCard(AdsModel ad) {
    final String title = (ad.title ?? '').toString();
    final String description = (ad.description ?? '').toString();
    final String imagePath = (ad.imageUrl ?? '').toString();
    final String imageUrl = imagePath.startsWith('http')
        ? imagePath
        : 'https://eventgo-live.com/$imagePath';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.2.h),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: GestureDetector(
            onTap: () {
              HapticUtils.selection();
              final eventId = ad.eventId ?? ad.donationId;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(
                    eventId: eventId?.toString() ?? '',
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(2.2.h),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image
                    Hero(
                      tag: 'ad_image_${ad.donationId ?? ad.eventId}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(2.2.h),
                          bottomLeft: Radius.circular(2.2.h),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 32.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            child: const Icon(Icons.broken_image_rounded,
                                color: Colors.white24),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(1.5.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title.isNotEmpty
                                        ? '${title[0].toUpperCase()}${title.substring(1)}'
                                        : 'Untitled',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueColor
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(1.h),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 10.sp,
                                        color: AppColors.blueColor,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'PRO',
                                        style: TextStyle(
                                          fontSize: 7.sp,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.blueColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.8.h),
                            Expanded(
                              child: Text(
                                description.isNotEmpty
                                    ? description
                                    : 'No description provided',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10.sp,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (ad.amount != null &&
                                    ad.amount!.isNotEmpty &&
                                    ad.amount != '0')
                                  Text(
                                    '\$${ad.amount}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Container(
                                  padding: EdgeInsets.all(0.6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 10.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
