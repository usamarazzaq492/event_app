import 'package:event_app/MVVM/View/bottombar/bottom_navigation_bar.dart';
import 'package:event_app/Services/invite_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InviteViewModel extends GetxController {
  final InviteService _inviteService = InviteService();

  var isLoading = false.obs;
  var responseMessage = ''.obs;
  var selectedUserIds = <int>[].obs;

  late int eventId; // ✅ Use late since it will be set before use

  void setEventId(int id) {
    eventId = id;
    debugPrint("✅ Event ID set to $eventId");
  }

  void toggleInvite(int userId) {
    if (selectedUserIds.contains(userId)) {
      Get.snackbar("Already Invited", "You already invited this user.");
    } else {
      selectedUserIds.add(userId);
      debugPrint("✅ Selected User IDs: $selectedUserIds");
    }
  }

  Future<void> sendInvites() async {
    if (selectedUserIds.isEmpty) {
      Get.snackbar("No Users", "Please select at least one user to invite.");
      return;
    }

    try {
      isLoading.value = true;
      debugPrint(
          "🔄 Sending invites to: $selectedUserIds for eventId: $eventId");

      final result = await _inviteService.inviteUsers(
        eventId: eventId,
        userIds: selectedUserIds,
      );

      responseMessage.value =
          result['message'] ?? "Invitations sent successfully.";
      debugPrint("✅ Invite API response: $result");

      Get.snackbar("Success", responseMessage.value);
      Get.offAll(() => const BottomNavBar());
    } catch (e) {
      responseMessage.value = "Failed to send invitations.";
      debugPrint("❌ Error sending invites: $e");
      Get.snackbar("Error", responseMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Notification-related observables
  var receivedInvites = <dynamic>[].obs;
  var isLoadingInvites = false.obs;
  var inviteError = ''.obs;

  /// Fetch received invites (notifications)
  Future<void> fetchReceivedInvites() async {
    try {
      isLoadingInvites.value = true;
      inviteError.value = '';
      final invites = await _inviteService.getReceivedInvites();
      receivedInvites.assignAll(invites);
      debugPrint("✅ Fetched ${invites.length} invites");
    } catch (e) {
      inviteError.value = e.toString();
      debugPrint("❌ Error fetching invites: $e");
      receivedInvites.clear();
    } finally {
      isLoadingInvites.value = false;
    }
  }

  /// Respond to an invite
  Future<void> respondToInvite(int inviteId, String response) async {
    try {
      isLoading.value = true;
      await _inviteService.respondToInvite(
        inviteId: inviteId,
        response: response,
      );

      // Refresh invites list
      await fetchReceivedInvites();

      Get.snackbar(
        "Success",
        "Invite ${response == 'accepted' ? 'accepted' : 'declined'} successfully",
        backgroundColor: response == 'accepted' ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("❌ Error responding to invite: $e");
      Get.snackbar("Error", "Failed to respond to invite");
    } finally {
      isLoading.value = false;
    }
  }
}
