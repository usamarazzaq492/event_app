import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/CreateAd/donation.dart';
import 'package:event_app/MVVM/view_model/ad_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../app/config/app_text_style.dart';
import '../../../utils/haptic_utils.dart';

class ADsDetailScreen extends StatefulWidget {
  final int? adId;

  const ADsDetailScreen({super.key, required this.adId});

  @override
  State<ADsDetailScreen> createState() => _ADsDetailScreenState();
}

class _ADsDetailScreenState extends State<ADsDetailScreen> {
  final AdViewModel viewModel = Get.put(AdViewModel());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.getAdDetail(widget.adId);
    });
    // viewModel.getAdDetail(widget.adId); // 🟢 Call only once here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (viewModel.error.isNotEmpty) {
          return Center(
              child: Text(viewModel.error.value,
                  style: const TextStyle(color: Colors.red)));
        }

        final ad = viewModel.adDetail.value.ad;
        if (ad == null) {
          return const Center(
              child: Text('No data found.',
                  style: TextStyle(color: Colors.white)));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: 'https://eventgo-live.com${ad.imageUrl}',
                    height: 28.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 28.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5)
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 4.h,
                  left: 4.w,
                  child: GestureDetector(
                    onTap: () {
                      HapticUtils.navigation();
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.54),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(1.h),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and target amount chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ad.title != null && ad.title!.isNotEmpty
                                ? '${ad.title![0].toUpperCase()}${ad.title!.substring(1)}'
                                : 'Untitled',
                            style: TextStyles.heading.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '\$${ad.amount ?? '0'} Target',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    Divider(color: Colors.white24),

                    SizedBox(height: 1.h),
                    Text(
                      'About This Ad',
                      style: TextStyles.regularhometext1.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          ad.description ?? 'No description provided.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.sp,
                            fontFamily: 'Montserrat',
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Summary Donate Bar
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(1.5.h),
                      decoration: BoxDecoration(
                        color: AppColors.signinoptioncolor,
                        borderRadius: BorderRadius.circular(1.h),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.redAccent),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Your donation will help achieve this ad\'s target goal.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 10.5.sp),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Donate button
                    ButtonWidget(
                      text: 'Donate Now',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DonationScreen(
                              donId: ad.donationId,
                              imageUrl: ad.imageUrl, // 🔷 pass image here
                            ),
                          ),
                        );
                      },
                      borderRadius: 2.h,
                      textColor: Colors.white,
                      backgroundColor: AppColors.blueColor,
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
