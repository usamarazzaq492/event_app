import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/EventDetailScreen/event_detail_screen.dart';
import 'package:event_app/MVVM/View/ProfileScreen/public_profile_screen.dart';
import 'package:event_app/MVVM/view_model/notification_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:event_app/utils/navigation_utils.dart';
import 'package:event_app/utils/refresh_on_navigation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with RefreshOnNavigation {
  final NotificationViewModel viewModel = Get.put(NotificationViewModel());

  @override
  void refreshData() {
    viewModel.fetchNotifications();
  }

  String getTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  Color getNotificationColor(String type) {
    switch (type) {
      case 'invite':
        return Colors.blue;
      case 'follow':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background Glow effect (Subtle)
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
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Obx(() {
                    if (viewModel.isLoading.value) {
                      return _buildLoadingState();
                    }

                    if (viewModel.error.isNotEmpty) {
                      return _buildErrorState();
                    }

                    if (viewModel.notifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    final grouped = viewModel.groupNotificationsByTime();

                    return RefreshIndicator(
                      onRefresh: () => viewModel.fetchNotifications(),
                      color: AppColors.blueColor,
                      backgroundColor: AppColors.signinoptioncolor,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                        itemCount: grouped.length,
                        itemBuilder: (context, groupIndex) {
                          final groupKey = grouped.keys.elementAt(groupIndex);
                          final groupNotifications = grouped[groupKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(1.w, 2.h, 0, 1.5.h),
                                child: Text(
                                  groupKey.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white38,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              // Notifications in this group
                              ...groupNotifications.map((notification) {
                                return _buildNotificationCard(notification);
                              }),
                              SizedBox(height: 1.h),
                            ],
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(1.5.h),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(1.5.h),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16.sp),
                  onPressed: () {
                    HapticUtils.navigation();
                    NavigationUtils.pop(context);
                  },
                ),
              ),
            ),
          ),
          Text(
            'NOTIFICATIONS',
            style: TextStyle(
              fontSize: 8.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(1.5.h),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(1.5.h),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 18.sp),
                  onPressed: () {
                    HapticUtils.light();
                    viewModel.fetchNotifications();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    final type = notification['type'] ?? '';
    final actor = notification['actor'] ?? {};
    final actorName = actor['name'] ?? 'Someone';
    final actorImage = actor['profileImage'] ?? '';
    final timeAgo = getTimeAgo(notification['createdAt']);
    final isInvite = type == 'invite';
    final isPending =
        isInvite && (notification['status'] ?? 'pending') == 'pending';
    final event = notification['event'];

    return Container(
      margin: EdgeInsets.only(bottom: 1.2.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(2.h),
          onTap: () {
            HapticUtils.selection();
            if (isInvite && event != null) {
              NavigationUtils.push(
                context,
                EventDetailScreen(eventId: '${event['id']}'),
                routeName: '/event-detail',
              );
            } else if (type == 'follow') {
              NavigationUtils.push(
                context,
                PublicProfileScreen(id: actor['id']),
                routeName: '/public-profile',
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture with overlay
                    GestureDetector(
                      onTap: () {
                        HapticUtils.selection();
                        NavigationUtils.push(
                          context,
                          PublicProfileScreen(id: actor['id']),
                          routeName: '/public-profile',
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: getNotificationColor(type)
                                    .withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: 20.sp,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.05),
                              backgroundImage: actorImage != null &&
                                      actorImage.toString().isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      actorImage.toString().startsWith('http')
                                          ? actorImage.toString()
                                          : 'https://eventgo-live.com/$actorImage',
                                    )
                                  : null,
                              child: actorImage == null ||
                                      actorImage.toString().isEmpty
                                  ? Icon(Icons.person_rounded,
                                      color: Colors.white24, size: 18.sp)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    // Notification Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(
                                  text: '$actorName ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white),
                                ),
                                TextSpan(
                                  text: isInvite
                                      ? 'invited you to an event'
                                      : 'is now following you',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Colors.white.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            timeAgo.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isInvite && event != null && event['image'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(1.h),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://eventgo-live.com/${event['image']}',
                          width: 12.w,
                          height: 12.w,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.white10),
                        ),
                      ),
                  ],
                ),
                if (isPending) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticUtils.light();
                            viewModel.respondToInvite(
                                notification['id'], 'accepted');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1.2.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.blueColor,
                                  Color(0xFF52D2FF)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1.2.h),
                            ),
                            child: Center(
                              child: Text(
                                'Accept',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            HapticUtils.light();
                            viewModel.respondToInvite(
                                notification['id'], 'declined');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1.2.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(1.2.h),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Decline',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.blueColor.withValues(alpha: 0.7)),
            strokeWidth: 3,
          ),
          SizedBox(height: 3.h),
          Text(
            'Syncing your alerts...',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 35.sp,
                color: Colors.red.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              viewModel.error.value,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white38,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            InkWell(
              onTap: () => viewModel.fetchNotifications(),
              borderRadius: BorderRadius.circular(1.5.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blueColor,
                      AppColors.blueColor.withValues(alpha: 0.7)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1.5.h),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.03),
            ),
            child: Icon(
              Icons.notifications_paused_rounded,
              size: 45.sp,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Quiet for now...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'We\'ll notify you when something important happens.',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white24,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
