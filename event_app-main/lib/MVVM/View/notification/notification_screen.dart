import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/EventDetailScreen/event_detail_screen.dart';
import 'package:event_app/MVVM/View/ProfileScreen/public_profile_screen.dart';
import 'package:event_app/MVVM/view_model/notification_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:event_app/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationViewModel viewModel = Get.put(NotificationViewModel());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchNotifications();
    });
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

  IconData getNotificationIcon(String type) {
    switch (type) {
      case 'invite':
        return Icons.event;
      case 'follow':
        return Icons.person_add;
      default:
        return Icons.notifications;
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

  String getNotificationText(dynamic notification) {
    final actorName = notification['actor']?['name'] ?? 'Someone';
    final type = notification['type'] ?? '';

    switch (type) {
      case 'invite':
        final status = notification['status'] ?? 'pending';
        if (status == 'accepted') {
          return '$actorName invited you to an event • Accepted';
        } else if (status == 'declined') {
          return '$actorName invited you to an event • Declined';
        }
        return '$actorName invited you to an event';
      case 'follow':
        return '$actorName started following you';
      default:
        return 'New notification';
    }
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
          onPressed: () {
            HapticUtils.navigation();
            NavigationUtils.pop(context);
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyles.heading.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              HapticUtils.light();
              viewModel.fetchNotifications();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
            ),
          );
        }

        if (viewModel.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 50.sp,
                  color: Colors.red.shade400,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Error Loading Notifications',
                  style: TextStyles.homeheadingtext.copyWith(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  viewModel.error.value,
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () => viewModel.fetchNotifications(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 60.sp,
                  color: Colors.white30,
                ),
                SizedBox(height: 3.h),
                Text(
                  'No Notifications',
                  style: TextStyles.homeheadingtext.copyWith(
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'When you get notifications, they\'ll show up here',
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 10.sp,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final grouped = viewModel.groupNotificationsByTime();

        return RefreshIndicator(
          onRefresh: () => viewModel.fetchNotifications(),
          color: AppColors.blueColor,
          backgroundColor: AppColors.signinoptioncolor,
          child: ListView.builder(
            padding: EdgeInsets.zero,
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
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    child: Text(
                      groupKey,
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  // Notifications in this group
                  ...groupNotifications.asMap().entries.map((entry) {
                    final index = entry.key;
                    final notification = entry.value;
                    return Column(
                      children: [
                        _buildNotificationItem(notification),
                        // Divider between notifications (Instagram style)
                        if (index < groupNotifications.length - 1)
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.white.withValues(alpha: 0.1),
                            indent: 20.w, // Start after profile picture
                          ),
                      ],
                    );
                  }).toList(),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(dynamic notification) {
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
      color: AppColors.backgroundColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture with notification icon overlay (Instagram style)
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
                      CircleAvatar(
                        radius: 28.sp,
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage: actorImage != null &&
                                actorImage.toString().isNotEmpty
                            ? CachedNetworkImageProvider(
                                actorImage.toString().startsWith('http')
                                    ? actorImage.toString()
                                    : 'https://eventgo-live.com/$actorImage',
                              )
                            : null,
                        child:
                            actorImage == null || actorImage.toString().isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: Colors.white70,
                                    size: 24.sp,
                                  )
                                : null,
                      ),
                      // Notification type icon badge (bottom right, Instagram style)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 20.sp,
                          height: 20.sp,
                          decoration: BoxDecoration(
                            color: getNotificationColor(type),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.backgroundColor,
                              width: 2.5,
                            ),
                          ),
                          child: Icon(
                            getNotificationIcon(type),
                            color: Colors.white,
                            size: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 3.w),
                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification Text (Instagram style - bold name, regular text)
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: actorName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: isInvite
                                  ? ' invited you to an event'
                                  : ' started following you',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      // Event Title (for invites) - subtle
                      if (isInvite && event != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 0.2.h),
                          child: Text(
                            event['title'] ?? 'Event',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      // Time ago (Instagram style - small, gray)
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11.sp,
                        ),
                      ),
                      // Action Buttons (for pending invites) - Instagram style
                      if (isPending) ...[
                        SizedBox(height: 1.2.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  HapticUtils.buttonPress();
                                  viewModel.respondToInvite(
                                    notification['id'],
                                    'accepted',
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: const BorderSide(
                                      color: Colors.green, width: 1.5),
                                  padding:
                                      EdgeInsets.symmetric(vertical: 0.8.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(1.5.h),
                                  ),
                                  minimumSize: Size(0, 4.h),
                                ),
                                child: Text(
                                  'Accept',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  HapticUtils.buttonPress();
                                  viewModel.respondToInvite(
                                    notification['id'],
                                    'declined',
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(
                                      color: Colors.red, width: 1.5),
                                  padding:
                                      EdgeInsets.symmetric(vertical: 0.8.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(1.5.h),
                                  ),
                                  minimumSize: Size(0, 4.h),
                                ),
                                child: Text(
                                  'Decline',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
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
                // Event Image (for invites) or Follow Button (Instagram style)
                SizedBox(width: 2.w),
                if (isInvite && event != null && event['image'] != null)
                  GestureDetector(
                    onTap: () {
                      HapticUtils.selection();
                      NavigationUtils.push(
                        context,
                        EventDetailScreen(eventId: '${event['id']}'),
                        routeName: '/event-detail',
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.8.h),
                      child: CachedNetworkImage(
                        imageUrl: 'https://eventgo-live.com/${event['image']}',
                        width: 14.w,
                        height: 14.w,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 14.w,
                          height: 14.w,
                          color: Colors.grey.shade800,
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 14.w,
                          height: 14.w,
                          color: Colors.grey.shade800,
                          child: Icon(
                            Icons.event,
                            color: Colors.white30,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (type == 'follow')
                  TextButton(
                    onPressed: () {
                      HapticUtils.buttonPress();
                      NavigationUtils.push(
                        context,
                        PublicProfileScreen(id: actor['id']),
                        routeName: '/public-profile',
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.blueColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.8.h),
                      minimumSize: Size(0, 4.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.5.h),
                        side: BorderSide(
                          color: AppColors.blueColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'View',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
