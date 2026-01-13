import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../exploreevent/event_update_screen.dart';

class EventTab extends StatelessWidget {
  EventTab({Key? key}) : super(key: key);

  final EventController controller = Get.put(EventController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (controller.error.isNotEmpty) {
        return Center(child: Text(controller.error.value));
      } else if (controller.myEvents.isEmpty) {
        return const Center(child: Text("No Events."));
      }

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        itemCount: controller.myEvents.length,
        itemBuilder: (context, index) {
          final event = controller.myEvents[index];
          return _buildEventCard(event);
        },
      );
    });
  }

  Widget _buildEventCard(event) {
    final imageUrl = event.eventImage != null && event.eventImage!.isNotEmpty
        ? 'https://eventgo-live.com${event.eventImage}'
        : '';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Event Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(2.h)),
            child: Image.network(
              imageUrl,
              height: 20.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  AppImages.art,
                  height: 20.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          /// Event Details
          Padding(
            padding: EdgeInsets.all(2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                Text(
                  event.eventTitle ?? '',
                  style: TextStyles.homeheadingtext,
                ),

                SizedBox(height: 0.8.h),

                /// Date & Time
                Text(
                  '${_formatDate(event.startDate)} • ${_formatTime(event.startTime)}',
                  style: TextStyles.homedatetext,
                ),

                SizedBox(height: 0.8.h),

                /// Category and Price
                Row(
                  children: [
                    Icon(Icons.category,
                        color: AppColors.blueColor, size: 12.sp),
                    SizedBox(width: 2.w),
                    Text(
                      event.category ?? '',
                      style: TextStyles.regularwhite.copyWith(
                        color: Colors.grey[300],
                      ),
                    ),
                    Spacer(),
                    Text(
                      event.eventPrice != null ? '\$${event.eventPrice}' : '',
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 14.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.5.h),

                /// Actions Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => EventUpdateScreen(
                              eventId: event.eventId.toString()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueColor,
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.h),
                          ),
                        ),
                        icon:
                            Icon(Icons.edit, color: Colors.white, size: 14.sp),
                        label: Text(
                          "Edit",
                          style: TextStyles.buttontext,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _confirmDelete(event.eventId.toString()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.h),
                          ),
                        ),
                        icon: Icon(Icons.delete_outline,
                            color: Colors.white, size: 14.sp),
                        label: Text(
                          "Delete",
                          style: TextStyles.buttontext,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String eventId) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Column(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 40.sp),
            SizedBox(height: 1.h),
            Text(
              "Delete Event",
              style: TextStyles.heading.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Are you sure you want to delete this event?",
              style: TextStyles.regularwhite,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h), // ✅ space between text and buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.deleteEvent(eventId);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.delete, color: Colors.white),
                    label: Text(
                      "Delete",
                      style: TextStyles.buttontext,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.blueColor),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.close, color: AppColors.blueColor),
                    label: Text(
                      "Cancel",
                      style: TextStyles.buttontext.copyWith(
                        color: AppColors.blueColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h), // ✅ this adds space BELOW BUTTONS
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM, yyyy').format(date);
    } catch (e) {
      return dateStr; // fallback if parse fails
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(timeStr);
      return DateFormat.jm().format(parsedTime);
    } catch (_) {
      try {
        // Try parsing if time has no seconds
        final parsedTime = DateFormat("HH:mm").parse(timeStr);
        return DateFormat.jm().format(parsedTime);
      } catch (e) {
        return timeStr; // fallback
      }
    }
  }
}
