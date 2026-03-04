import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/Promotion/promote_event_screen.dart';
import 'package:event_app/MVVM/body_model/my_event_model.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/refresh_on_navigation_mixin.dart';
import 'package:event_app/utils/haptic_utils.dart';
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
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -10.h,
            right: -10.w,
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blueColor.withValues(alpha: 0.1),
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
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),
                        Text(
                          'Choose an event to boost its visibility',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Expanded(child: _buildEventsList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              GestureDetector(
                onTap: () {
                  HapticUtils.navigation();
                  Navigator.pop(context);
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
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Promote Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44),
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(2.2.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: GestureDetector(
          onTap: canPromote
              ? () {
                  HapticUtils.selection();
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(2.2.h),
              border: Border.all(
                color: isCurrentlyPromoted
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
                width: isCurrentlyPromoted ? 1.5 : 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  Hero(
                    tag: 'event_image_${event.eventId}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2.2.h),
                        bottomLeft: Radius.circular(2.2.h),
                      ),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 30.w,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.white.withValues(alpha: 0.05),
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.white.withValues(alpha: 0.05),
                              child: const Icon(Icons.broken_image_rounded,
                                  color: Colors.white24),
                            ),
                          ),
                          if (!isUpcoming)
                            Container(
                              color: Colors.black.withValues(alpha: 0.6),
                              child: Center(
                                child: Text(
                                  'PAST',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                          Text(
                            event.eventTitle ?? 'Untitled Event',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.6.h),
                          if (event.startDate != null)
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    size: 10.sp, color: Colors.white38),
                                SizedBox(width: 1.5.w),
                                Text(
                                  _formatDate(event.startDate!),
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 1.5.h),
                          if (isCurrentlyPromoted)
                            _buildStatusBadge(
                              icon: Icons.verified_rounded,
                              label: timeRemaining != null
                                  ? 'Boosted • $timeRemaining'
                                  : 'Boosted',
                              color: Colors.orange,
                            )
                          else if (isUpcoming)
                            _buildStatusBadge(
                              icon: Icons.rocket_launch_rounded,
                              label: 'Tap to Boost',
                              color: AppColors.blueColor,
                            )
                          else
                            _buildStatusBadge(
                              icon: Icons.history_rounded,
                              label: 'Past Event',
                              color: Colors.white24,
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
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(1.h),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: color),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5.sp,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
