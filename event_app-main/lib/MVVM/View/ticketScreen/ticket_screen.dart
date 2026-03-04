import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/view_model/ticket_view_model.dart';
import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../utils/haptic_utils.dart';
import '../../../Services/ticket_pdf_service.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TicketViewModel ticketVM = Get.put(TicketViewModel());
  final AuthViewModel authViewModel = Get.put(AuthViewModel());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authViewModel.isLoggedIn.value) {
        ticketVM.getTickets();
      }
    });
  }

  Widget _buildGuestPrompt() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Icon(
                Icons.confirmation_number_rounded,
                size: 50.sp,
                color: AppColors.blueColor.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Join the EventGo Community",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.5.h),
            Text(
              "Sign in to view your tickets and upcoming experiences.",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticUtils.light();
                  Get.toNamed(RouteName.loginScreen);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.5.h),
                  ),
                  elevation: 0,
                ).copyWith(
                  shadowColor: WidgetStateProperty.all(
                      AppColors.blueColor.withValues(alpha: 0.4)),
                  elevation: WidgetStateProperty.all(8),
                ),
                child: Text(
                  "Sign In to Continue",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!authViewModel.isLoggedIn.value) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Column(
            children: [
              _buildPremiumHeader("My Tickets"),
              Expanded(child: _buildGuestPrompt()),
            ],
          ),
        );
      }
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Column(
            children: [
              _buildPremiumHeader("My Tickets"),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTicketList('general'),
                    _buildTicketList('vip'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTicketList(String type) {
    return Obx(() {
      if (ticketVM.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blueColor),
        );
      }

      final filtered = ticketVM.tickets
          .where((ticket) => ticket['ticketType'] == type)
          .toList();

      if (filtered.isEmpty) {
        return Center(
          child: Text(
            "No $type tickets",
            style: const TextStyle(color: Colors.white38),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final t = filtered[index];
          final imageUrl = "https://eventgo-live.com${t['eventImage'] ?? ''}";
          final eventTitle = t['eventTitle'] ?? 'No Title';
          final capitalizedTitle = eventTitle.isNotEmpty
              ? eventTitle[0].toUpperCase() + eventTitle.substring(1)
              : eventTitle;
          final ticketType = t['ticketType'] ?? 'Unknown';
          final startDate = t['startDate'] ?? '';
          final startTime = t['startTime'] ?? '';
          final ticketNumber = t['ticketNumber'] ?? 'N/A';
          final qrCodeData = t['qrCodeData'] ?? '';

          String formattedDate = startDate.isNotEmpty
              ? DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(startDate))
              : 'N/A';
          String formattedStartTime = startTime.isNotEmpty
              ? DateFormat.jm().format(DateFormat("HH:mm:ss").parse(startTime))
              : 'N/A';

          return Container(
            margin: EdgeInsets.only(bottom: 2.5.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(2.5.h),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(1.5.h),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 15.w,
                          height: 8.h,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            child: Icon(Icons.confirmation_number_rounded,
                                color: Colors.white24, size: 20.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capitalizedTitle.trim(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              "$formattedDate • $formattedStartTime",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 9.sp),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w, vertical: 0.6.h),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(1.h),
                        ),
                        child: Text(
                          ticketType.toUpperCase(),
                          style: TextStyle(
                              color: AppColors.blueColor,
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                if (qrCodeData.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 2.h),
                    padding:
                        EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(2.h),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.5.h),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: qrCodeData is String
                                ? qrCodeData
                                : jsonEncode(qrCodeData),
                            version: QrVersions.auto,
                            size: 40.w,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "SCAN TO ENTER",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ADMIT ONE",
                              style: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1)),
                          Text(ticketNumber,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          HapticUtils.light();
                          try {
                            await generateTicketPdf(t);
                            HapticUtils.success();
                            Get.snackbar(
                                "Success", "Ticket saved to Downloads");
                          } catch (e) {
                            HapticUtils.error();
                          }
                        },
                        icon: Icon(Icons.file_download_outlined,
                            size: 14.sp, color: AppColors.blueColor),
                        label: Text(
                          "SAVE PDF",
                          style: TextStyle(
                              color: AppColors.blueColor,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              AppColors.blueColor.withValues(alpha: 0.1),
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1.h)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildPremiumHeader(String title) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              6.w, MediaQuery.of(context).padding.top + 2.h, 6.w, 1.5.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.8),
            border: Border(
                bottom:
                    BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(1.5.h),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        onTap: (index) => HapticUtils.selection(),
        indicator: BoxDecoration(
          color: AppColors.blueColor,
          borderRadius: BorderRadius.circular(1.2.h),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        tabs: const [
          Tab(text: 'General Admission'),
          Tab(text: 'VIP'),
        ],
      ),
    );
  }
}
