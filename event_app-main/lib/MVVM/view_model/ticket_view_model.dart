import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../Services/ticket_service.dart';

class TicketViewModel extends GetxController {
  var isLoading = false.obs;
  var tickets = [].obs;

  Future<void> getTickets() async {
    try {
      isLoading.value = true;
      tickets.value = await TicketService.fetchTickets();
    } catch (e) {
      debugPrint("❌ TicketViewModel Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
