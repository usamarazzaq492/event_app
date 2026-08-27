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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_app/Widget/ticket_painter.dart';

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
                color: AppColors.textColorPrimary.withValues(alpha: 0.03),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.textColorPrimary.withValues(alpha: 0.05)),
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
                color: AppColors.textColorPrimary,
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
                color: AppColors.textColorPrimary.withValues(alpha: 0.38),
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
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Column(
          children: [
            _buildPremiumHeader("My Tickets"),
            Expanded(
              child: _buildTicketList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTicketList() {
    return Obx(() {
      if (ticketVM.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blueColor),
        );
      }

      final filtered = ticketVM.tickets;

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long,
                  size: 50.sp,
                  color: AppColors.textColorPrimary.withValues(alpha: 0.1)),
              SizedBox(height: 2.h),
              Text(
                "No tickets found",
                style: TextStyle(
                    color: AppColors.textColorPrimary.withValues(alpha: 0.38),
                    fontSize: 14.sp),
              ),
            ],
          )
              .animate()
              .fade(duration: 500.ms)
              .scale(begin: const Offset(0.9, 0.9)),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
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
            margin: EdgeInsets.only(bottom: 3.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.5.h),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textColorPrimary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.5.h),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Top Event Info
                      Container(
                        padding: EdgeInsets.all(2.h),
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(1.5.h),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 18.w,
                                height: 18.w,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.textColorPrimary
                                      .withValues(alpha: 0.05),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.textColorPrimary
                                      .withValues(alpha: 0.05),
                                  child: Icon(Icons.event,
                                      color: AppColors.textColorPrimary
                                          .withValues(alpha: 0.24),
                                      size: 20.sp),
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          capitalizedTitle.trim(),
                                          style: TextStyle(
                                            color: AppColors.textColorPrimary,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 10.sp,
                                          color: AppColors.blueColor),
                                      SizedBox(width: 1.5.w),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                            color: AppColors.textColorPrimary
                                                .withValues(alpha: 0.6),
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded,
                                          size: 10.sp,
                                          color: AppColors.blueColor),
                                      SizedBox(width: 1.5.w),
                                      Text(
                                        formattedStartTime,
                                        style: TextStyle(
                                            color: AppColors.textColorPrimary
                                                .withValues(alpha: 0.6),
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Dashed Divider & Cutouts
                      SizedBox(
                        height: 2.h,
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.h),
                                child: CustomPaint(
                                  painter: TicketDashedLinePainter(),
                                  child: Container(
                                      height: 1, width: double.infinity),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -1.h,
                              top: 0,
                              child: Container(
                                width: 2.h,
                                height: 2.h,
                                decoration: const BoxDecoration(
                                  color: AppColors.backgroundColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -1.h,
                              top: 0,
                              child: Container(
                                width: 2.h,
                                height: 2.h,
                                decoration: const BoxDecoration(
                                  color: AppColors.backgroundColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // QR Code Section
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: 2.h, horizontal: 2.h),
                        child: Column(
                          children: [
                            if (qrCodeData.isNotEmpty) ...[
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(1.5.h),
                                  border: Border.all(
                                      color: AppColors.textColorPrimary
                                          .withValues(alpha: 0.05)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.blueColor
                                          .withValues(alpha: 0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: qrCodeData is String
                                      ? qrCodeData
                                      : jsonEncode(qrCodeData),
                                  version: QrVersions.auto,
                                  size: 45.w,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              SizedBox(height: 1.5.h),
                              Text(
                                "SCAN AT ENTRY",
                                style: TextStyle(
                                    color: AppColors.blueColor,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3),
                              ),
                              SizedBox(height: 2.h),
                            ],

                            // Bottom Footer
                            Container(
                              padding: EdgeInsets.all(1.5.h),
                              decoration: BoxDecoration(
                                color: AppColors.textColorPrimary
                                    .withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(1.5.h),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("TICKET TYPE",
                                            style: TextStyle(
                                                color: AppColors
                                                    .textColorPrimary
                                                    .withValues(alpha: 0.4),
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1)),
                                        SizedBox(height: 0.5.h),
                                        Text(ticketType.toUpperCase(),
                                            style: TextStyle(
                                                color:
                                                    AppColors.textColorPrimary,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      width: 1,
                                      height: 4.h,
                                      color: AppColors.textColorPrimary
                                          .withValues(alpha: 0.1)),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 3.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("ORDER NO.",
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textColorPrimary
                                                      .withValues(alpha: 0.4),
                                                  fontSize: 8.sp,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1)),
                                          SizedBox(height: 0.5.h),
                                          Text(ticketNumber,
                                              style: TextStyle(
                                                  color: AppColors
                                                      .textColorPrimary,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      HapticUtils.light();
                                      try {
                                        await generateTicketPdf(t);
                                        HapticUtils.success();
                                        Get.snackbar("Success",
                                            "Ticket saved to Downloads",
                                            backgroundColor:
                                                AppColors.textColorPrimary,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.BOTTOM,
                                            margin: EdgeInsets.all(2.h));
                                      } catch (e) {
                                        HapticUtils.error();
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.blueColor,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3.w, vertical: 1.h),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(1.h)),
                                    ),
                                    child: Icon(Icons.file_download_outlined,
                                        size: 16.sp, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fade(duration: 400.ms, delay: (index * 100).ms)
              .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
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
                bottom: BorderSide(
                    color: AppColors.textColorPrimary.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textColorPrimary,
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
}
