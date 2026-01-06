import 'package:event_app/Services/notification_service.dart';
import 'package:event_app/Services/invite_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationViewModel extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final InviteService _inviteService = InviteService();

  var notifications = <dynamic>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  /// Fetch all notifications
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      error.value = '';
      final notifs = await _notificationService.getAllNotifications();
      notifications.assignAll(notifs);
      print("✅ Fetched ${notifs.length} notifications");
    } catch (e) {
      error.value = e.toString();
      print("❌ Error fetching notifications: $e");
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Respond to an invite
  Future<void> respondToInvite(int inviteId, String response) async {
    try {
      await _inviteService.respondToInvite(
        inviteId: inviteId,
        response: response,
      );
      
      // Refresh notifications
      await fetchNotifications();
      
      Get.snackbar(
        "Success",
        "Invite ${response == 'accepted' ? 'accepted' : 'declined'} successfully",
        backgroundColor: response == 'accepted' ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print("❌ Error responding to invite: $e");
      Get.snackbar(
        "Error",
        "Failed to respond to invite: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Group notifications by time
  Map<String, List<dynamic>> groupNotificationsByTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final grouped = <String, List<dynamic>>{
      'Today': [],
      'This Week': [],
      'Earlier': [],
    };

    for (var notification in notifications) {
      final createdAt = DateTime.tryParse(notification['createdAt'] ?? '');
      if (createdAt == null) continue;

      final notificationDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      
      if (notificationDate == today) {
        grouped['Today']!.add(notification);
      } else if (notificationDate.isAfter(weekAgo)) {
        grouped['This Week']!.add(notification);
      } else {
        grouped['Earlier']!.add(notification);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }
}
