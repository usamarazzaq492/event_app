import 'package:event_app/MVVM/View/bottombar/bottom_navigation_bar.dart';
import 'package:event_app/Services/invite_service.dart';
import 'package:get/get.dart';

class InviteViewModel extends GetxController {
  final InviteService _inviteService = InviteService();

  var isLoading = false.obs;
  var responseMessage = ''.obs;
  var selectedUserIds = <int>[].obs;

  late int eventId; // ✅ Use late since it will be set before use

  void setEventId(int id) {
    eventId = id;
    print("✅ Event ID set to $eventId");
  }

  void toggleInvite(int userId) {
    if (selectedUserIds.contains(userId)) {
      Get.snackbar("Already Invited", "You already invited this user.");
    } else {
      selectedUserIds.add(userId);
      print("✅ Selected User IDs: $selectedUserIds");
    }
  }

  Future<void> sendInvites() async {
    if (selectedUserIds.isEmpty) {
      Get.snackbar("No Users", "Please select at least one user to invite.");
      return;
    }

    try {
      isLoading.value = true;
      print("🔄 Sending invites to: $selectedUserIds for eventId: $eventId");

      final result = await _inviteService.inviteUsers(
        eventId: eventId,
        userIds: selectedUserIds,
      );

      responseMessage.value = result['message'] ?? "Invitations sent successfully.";
      print("✅ Invite API response: ${result}");

      Get.snackbar("Success", responseMessage.value);
      Get.offAll(() => BottomNavBar());
    } catch (e) {
      responseMessage.value = "Failed to send invitations.";
      print("❌ Error sending invites: $e");
      Get.snackbar("Error", responseMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
