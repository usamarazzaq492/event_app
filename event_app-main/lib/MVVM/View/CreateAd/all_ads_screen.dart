import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/CreateAd/ads_detail_screen.dart';
import 'package:event_app/MVVM/View/CreateAd/create_ad.dart';
import 'package:event_app/MVVM/view_model/ad_view_model.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AllAdsScreen extends StatefulWidget {
  @override
  State<AllAdsScreen> createState() => _AllAdsScreenState();
}

class _AllAdsScreenState extends State<AllAdsScreen> {
  final adVM = Get.put(AdViewModel());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adVM.fetchAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      floatingActionButton: FloatingActionButton(
        heroTag: "ads_fab",
        backgroundColor: AppColors.blueColor,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => CreateAd()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 2.h),
              Expanded(child: _buildAdsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "All Ads",
              style: TextStyles.heading,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => adVM.fetchAds(),
              tooltip: 'Refresh',
            )
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.02),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdsList() {
    return RefreshIndicator(
      onRefresh: adVM.fetchAds,
      color: AppColors.blueColor,
      backgroundColor: AppColors.signinoptioncolor,
      child: Obx(() {
        if (adVM.isLoading.value && adVM.ads.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (adVM.error.isNotEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 20.h),
              Center(
                child: Text(adVM.error.value,
                    style: const TextStyle(color: Colors.red)),
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
            itemBuilder: (context, index) => _buildAdCard(adVM.ads[index]),
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
                "No Ads Available",
                style: TextStyles.homeheadingtext,
              ),
              SizedBox(height: 1.h),
              Text(
                "Tap the + button below to create your first ad!",
                textAlign: TextAlign.center,
                style: TextStyles.regularwhite.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdCard(ad) {
    final String title = (ad.title ?? '').toString();
    final String description = (ad.description ?? '').toString();
    final String imagePath = (ad.imageUrl ?? '').toString();
    final String imageUrl = imagePath.startsWith('http')
        ? imagePath
        : 'https://eventgo-live.com/$imagePath';

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ADsDetailScreen(adId: ad.donationId)));
      },
      borderRadius: BorderRadius.circular(2.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
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
                      child: CircularProgressIndicator(strokeWidth: 2)),
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
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.blueColor
                                    .withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.campaign,
                                  size: 12.sp, color: Colors.white),
                              SizedBox(width: 1.w),
                              Text('Ad', style: TextStyles.regularwhite),
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
                      style: TextStyles.regularwhite
                          .copyWith(color: Colors.white70),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
