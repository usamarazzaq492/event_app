import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/Promotion/promote_event_screen.dart';
import 'package:event_app/MVVM/body_model/my_event_model.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/refresh_on_navigation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class SelectEventToPromoteScreen extends StatefulWidget {
  const SelectEventToPromoteScreen({super.key});

  @override
  State<SelectEventToPromoteScreen> createState() =>
      _SelectEventToPromoteScreenState();
}

class _SelectEventToPromoteScreenState extends State<SelectEventToPromoteScreen>
    with RefreshOnNavigation {
  final EventController eventController = Get.put(EventController());
  Timer? _timer;

  @override
  void refreshData() {
    eventController.getMyEvents();
  }

  @override
  void initState() {
    super.initState();
    // Update timer every minute for exact countdown
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to update countdown timers
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Event to Promote',
          style: TextStyles.heading,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose an event to boost its visibility',
                style: TextStyles.regularwhite.copyWith(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(child: _buildEventsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return RefreshIndicator(
      onRefresh: eventController.getMyEvents,
      color: AppColors.blueColor,
      backgroundColor: AppColors.signinoptioncolor,
      child: Obx(() {
        if (eventController.isLoading.value &&
            eventController.myEvents.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else if (eventController.myEvents.isEmpty) {
          return _buildEmptyState();
        } else {
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: eventController.myEvents.length,
            separatorBuilder: (_, __) => SizedBox(height: 2.h),
            itemBuilder: (context, index) =>
                _buildEventCard(eventController.myEvents[index]),
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
                "No Events Found",
                style: TextStyles.homeheadingtext,
              ),
              SizedBox(height: 1.h),
              Text(
                "Create an event first to promote it!",
                textAlign: TextAlign.center,
                style: TextStyles.regularwhite.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(MyEventModel event) {
    final String imagePath = (event.eventImage ?? '').toString();
    final String imageUrl = imagePath.startsWith('http')
        ? imagePath
        : 'https://eventgo-live.com/$imagePath';

    // Check if event is upcoming
    final bool isUpcoming = _isEventUpcoming(event.startDate);
    // Check if event is currently promoted
    final bool isCurrentlyPromoted = event.isPromotionActive;
    // Get exact time remaining
    final String? timeRemaining =
        _getExactTimeRemaining(event.promotionEndDate);
    // Event can be promoted if it's upcoming AND not currently promoted
    final bool canPromote = isUpcoming && !isCurrentlyPromoted;

    return InkWell(
      onTap: canPromote
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PromoteEventScreen(
                    eventId: event.eventId!,
                    eventTitle: event.eventTitle ?? 'Event',
                  ),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(2.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h),
          border: Border.all(
            color: isCurrentlyPromoted
                ? Colors.orange.withValues(alpha: 0.5)
                : isUpcoming
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.3),
            width: isCurrentlyPromoted ? 2 : 1,
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
              child: Stack(
                children: [
                  CachedNetworkImage(
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
                      child:
                          const Icon(Icons.broken_image, color: Colors.white70),
                    ),
                  ),
                  if (!isUpcoming)
                    Container(
                      width: 28.w,
                      height: 14.h,
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Center(
                        child: Text(
                          'Past Event',
                          style: TextStyles.regularwhite.copyWith(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventTitle ?? 'Untitled Event',
                      style: TextStyles.homeheadingtext,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.8.h),
                    if (event.startDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12.sp,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _formatDate(event.startDate!),
                            style: TextStyles.regularwhite.copyWith(
                              color: Colors.white70,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    if (event.city != null && event.city!.isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12.sp,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              event.city!,
                              style: TextStyles.regularwhite.copyWith(
                                color: Colors.white70,
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 1.h),
                    if (isCurrentlyPromoted)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(1.h),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14.sp,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 1.5.w),
                            Text(
                              timeRemaining != null
                                  ? 'Promoted • $timeRemaining left'
                                  : 'Promoted',
                              style: TextStyles.regularwhite.copyWith(
                                fontSize: 11.sp,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isUpcoming)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(1.h),
                          border: Border.all(
                            color: AppColors.blueColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.rocket_launch,
                              size: 14.sp,
                              color: AppColors.blueColor,
                            ),
                            SizedBox(width: 1.5.w),
                            Text(
                              'Tap to Promote',
                              style: TextStyles.regularwhite.copyWith(
                                fontSize: 11.sp,
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(1.h),
                        ),
                        child: Text(
                          'Past Event',
                          style: TextStyles.regularwhite.copyWith(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
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

  bool _isEventUpcoming(String? startDate) {
    if (startDate == null || startDate.isEmpty) return false;
    try {
      final eventDate = DateTime.parse(startDate);
      final now = DateTime.now();
      return eventDate.isAfter(now) || eventDate.isAtSameMomentAs(now);
    } catch (e) {
      return false;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String? _getExactTimeRemaining(String? promotionEndDate) {
    if (promotionEndDate == null || promotionEndDate.isEmpty) return null;
    try {
      // Parse the date - if it has timezone info, use it; otherwise assume UTC
      DateTime endDate;
      if (promotionEndDate.endsWith('Z') ||
          promotionEndDate.contains('+') ||
          (promotionEndDate.length > 10 &&
                  promotionEndDate[promotionEndDate.length - 6] == '+' ||
              promotionEndDate[promotionEndDate.length - 6] == '-')) {
        // Has timezone info (ISO 8601 format), parse directly
        endDate = DateTime.parse(promotionEndDate).toUtc();
      } else {
        // No timezone info (MySQL datetime format), assume UTC
        // MySQL returns dates like "2024-01-15 10:30:00" without timezone
        endDate =
            DateTime.parse('${promotionEndDate.replaceAll(' ', 'T')}Z').toUtc();
      }

      // Compare in UTC to avoid timezone issues
      final now = DateTime.now().toUtc();

      if (now.isAfter(endDate)) return null;

      final difference = endDate.difference(now);

      final days = difference.inDays;
      final hours = difference.inHours.remainder(24);
      final minutes = difference.inMinutes.remainder(60);

      if (days > 0) {
        if (hours > 0) {
          return '${days}d ${hours}h';
        } else {
          return '${days}d';
        }
      } else if (hours > 0) {
        if (minutes > 0) {
          return '${hours}h ${minutes}m';
        } else {
          return '${hours}h';
        }
      } else if (minutes > 0) {
        return '${minutes}m';
      } else {
        return 'Expiring soon';
      }
    } catch (e) {
      return null;
    }
  }
}
