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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AllAdsScreen extends StatefulWidget {
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
      body: SafeArea(
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
    );
  }

  Widget _buildPromoteButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (!authViewModel.isLoggedIn.value) {
                Get.snackbar(
                  'Sign in to promote',
                  'Create an account to promote your events.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.signinoptioncolor,
                  colorText: Colors.white,
                  mainButton: TextButton(
                    onPressed: () => Get.toNamed(RouteName.loginScreen),
                    child: Text(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.h),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  "Promote Your Event",
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
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
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(1.5.h),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: AppColors.blueColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Promoted Events",
                        style: TextStyles.heading.copyWith(
                          fontSize: 18.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.3.h),
                      Obx(() => Text(
                            "${adVM.ads.length} active promotion${adVM.ads.length != 1 ? 's' : ''}",
                            style: TextStyles.regularwhite.copyWith(
                              fontSize: 11.sp,
                              color: Colors.white60,
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.signinoptioncolor,
              borderRadius: BorderRadius.circular(1.5.h),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => adVM.fetchAds(),
              tooltip: 'Refresh',
              iconSize: 20.sp,
            ),
          ),
        ],
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
          final isAuthError = adVM.error.value.toLowerCase().contains('unauthenticated') ||
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
                        icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
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

    return InkWell(
      onTap: () {
        // Navigate to event detail (use eventId if available, otherwise donationId)
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
      borderRadius: BorderRadius.circular(2.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2.h),
                bottomLeft: Radius.circular(2.h),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 28.w,
                height: 14.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade800,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.broken_image, color: Colors.white70),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
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
                            style: TextStyles.homeheadingtext,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  AppColors.blueColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.rocket_launch,
                                size: 12.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Promoted',
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 9.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      description.isNotEmpty
                          ? (description.length > 100
                              ? '${description.substring(0, 100)}…'
                              : description)
                          : 'No description provided',
                      style: TextStyles.regularwhite.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.8.h),
                    if (ad.amount != null &&
                        ad.amount!.isNotEmpty &&
                        ad.amount != '0')
                      Text(
                        '\$${ad.amount}',
                        style: TextStyles.regularwhite.copyWith(
                          fontSize: 14.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
