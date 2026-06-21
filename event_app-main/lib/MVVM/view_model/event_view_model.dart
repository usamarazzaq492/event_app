import 'dart:convert';
import 'dart:io';

import 'package:event_app/MVVM/body_model/event_detail_model.dart';
import 'package:event_app/MVVM/body_model/event_model.dart';
import 'package:event_app/MVVM/body_model/my_event_model.dart';
import 'package:event_app/MVVM/body_model/ticket_tier_model.dart';
import 'package:event_app/Services/event_service.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../View/bottombar/bottom_navigation_bar.dart';
import 'bottom_nav_controller.dart';

class EventController extends GetxController {
  final EventService _eventService = EventService();

  var events = <EventModel>[].obs;
  var upcomingEvents = <EventModel>[].obs;
  var pastEvents = <EventModel>[].obs;
  var myEvents = <MyEventModel>[].obs;
  var timelineEvents =
      <EventModel>[].obs; // Timeline: events from followed users
  var eventDetail = Rxn<EventDetailModel>();

  // 🎫 Ticket tiers for the currently viewed event
  var tiers = <TicketTier>[].obs;
  var tiersLoading = false.obs;

  /// Computed: total booking amount across all selected tiers
  double get bookingTotal => tiers.fold(
      0.0, (sum, t) => sum + (t.price * t.selectedQuantity));

  /// Computed: total ticket count selected
  int get totalSelectedTickets =>
      tiers.fold(0, (sum, t) => sum + t.selectedQuantity);

  /// Tier summary string e.g. "Adult x2, Child x1"
  String get tierSummary => tiers
      .where((t) => t.selectedQuantity > 0)
      .map((t) => '${t.tierName} x${t.selectedQuantity}')
      .join(', ');

  var isLoading = false.obs;
  var isDeleting = false.obs;
  var isTimelineLoading = false.obs;

  final RxString error = ''.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initEvents();
  }

  Future<void> _initEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hasToken = token != null && token.isNotEmpty;

    fetchUpcomingEventsForHome();
    fetchAllEvents();
    if (hasToken) {
      getMyEvents();
      fetchTimelineEvents();
    }
  }

  /// 🔷 Fetch all events and separate into upcoming & past
  Future<void> fetchAllEvents() async {
    try {
      isLoading.value = true;
      final result = await _eventService.fetchEvents();
      final now = DateTime.now();
      final upcoming = <EventModel>[];
      final past = <EventModel>[];

      final today = DateTime(now.year, now.month, now.day);
      for (var event in result) {
        final startDate = DateTime.tryParse(event.startDate ?? '');
        if (startDate != null) {
          if (!startDate.isBefore(today)) {
            upcoming.add(event);
          } else {
            past.add(event);
          }
        }
      }

      upcoming.sort((a, b) {
        final aDate = DateTime.tryParse(a.startDate ?? '');
        final bDate = DateTime.tryParse(b.startDate ?? '');
        if (aDate == null || bDate == null) return 0;
        return aDate.compareTo(bDate);
      });

      upcomingEvents.assignAll(upcoming);
      pastEvents.assignAll(past);
      events.assignAll(result);
      errorMessage.value = ''; // Clear on success
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔷 Fetch only upcoming events for HomeScreen
  Future<void> fetchUpcomingEventsForHome() async {
    try {
      isLoading.value = true;
      final result = await _eventService.fetchEvents();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final upcoming = result.where((event) {
        final startDate = DateTime.tryParse(event.startDate ?? '');
        return startDate != null && !startDate.isBefore(today);
      }).toList();
      upcomingEvents.assignAll(upcoming);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔷 Fetch Timeline Events - Events from users you follow
  Future<void> fetchTimelineEvents() async {
    try {
      isTimelineLoading.value = true;
      final result = await _eventService.fetchTimelineEvents();
      timelineEvents.assignAll(result);
    } catch (e) {
      timelineEvents.clear();
      // Don't set errorMessage - timeline is supplemental; main events list (Search tab) should not show timeline errors
    } finally {
      isTimelineLoading.value = false;
    }
  }

  /// 🎫 Fetch ticket tiers for an event
  Future<void> fetchEventTiers(int eventId) async {
    try {
      tiersLoading.value = true;
      tiers.clear();
      final result = await _eventService.fetchEventTiers(eventId);
      tiers.assignAll(result);
    } catch (e) {
      tiers.clear();
      debugPrint('fetchEventTiers error: $e');
    } finally {
      tiersLoading.value = false;
    }
  }

  /// 🎫 Create a new tier (organizer only)
  Future<bool> createTier({
    required int eventId,
    required String tierName,
    required double price,
    int? quantityCap,
    String? description,
  }) async {
    try {
      final response = await _eventService.storeTier(
        eventId: eventId,
        tierName: tierName,
        price: price,
        quantityCap: quantityCap,
        description: description,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        await fetchEventTiers(eventId);
        return true;
      }
      final msg = data['error'] ?? data['message'] ?? 'Failed to create tier';
      Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  /// 🎫 Update an existing tier (organizer only)
  Future<bool> editTier({
    required int eventId,
    required int tierId,
    required String tierName,
    required double price,
    int? quantityCap,
    String? description,
  }) async {
    try {
      final response = await _eventService.updateTier(
        eventId: eventId,
        tierId: tierId,
        tierName: tierName,
        price: price,
        quantityCap: quantityCap,
        description: description,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await fetchEventTiers(eventId);
        return true;
      }
      final msg = data['error'] ?? data['message'] ?? 'Failed to update tier';
      Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  /// 🎫 Deactivate (soft-delete) a tier (organizer only)
  Future<bool> removeTier({required int eventId, required int tierId}) async {
    try {
      final response = await _eventService.deleteTier(eventId: eventId, tierId: tierId);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await fetchEventTiers(eventId);
        return true;
      }
      final msg = data['error'] ?? data['message'] ?? 'Failed to remove tier';
      Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  /// 🎫 Fetch event detail by ID
  Future<void> fetchEventDetailById(String eventId,
      {Function(EventDetailModel)? onLoaded}) async {
    try {
      isLoading.value = true;
      final detail = await _eventService.fetchEventDetail(eventId);

      // 🔷 Trim seconds from time if present
      if (detail.startTime != null && detail.startTime!.contains(":")) {
        detail.startTime = detail.startTime!.substring(0, 5);
      }
      if (detail.endTime != null && detail.endTime!.contains(":")) {
        detail.endTime = detail.endTime!.substring(0, 5);
      }

      // 🔷 Save to observable
      eventDetail.value = detail;

      // 🔷 Call onLoaded callback to populate UI
      onLoaded?.call(detail);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔷 Fetch events created by current user
  Future<void> getMyEvents() async {
    isLoading.value = true;
    error.value = '';

    try {
      final events = await _eventService.fetchMyEvents();
      myEvents.assignAll(events);
    } catch (e) {
      error.value = 'Failed to fetch your events: $e';
      debugPrint('getMyEvents Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔷 Create a new event
  Future<void> createEvent({
    required String eventTitle,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required String eventDescription,
    required String eventCategory,
    required String eventAddress,
    required String eventCity,
    required String eventState,
    String? eventLatitude,
    String? eventLongitude,
    required File eventImage,
    String? liveStreamUrl,
    String? eventPrice,
  }) async {
    try {
      isLoading.value = true;
      final response = await _eventService.createEvent(
        eventTitle: eventTitle,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        eventdes: eventDescription,
        eventcategory: eventCategory,
        eventaddress: eventAddress,
        eventcity: eventCity,
        eventstate: eventState,
        latitude: eventLatitude,
        longitude: eventLongitude,
        eventimage: eventImage.path,
        liveStreamUrl: liveStreamUrl,
        eventPrice: eventPrice,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final message = data['message'] ?? 'Event Created Successfully!';
        Get.snackbar('Success', message,
            backgroundColor: AppColors.blueColor, colorText: Colors.white);

        // Refresh lists so new event appears
        await fetchAllEvents();
        await getMyEvents();

        // Navigate to My Events tab
        Get.offAll(() => const BottomNavBar());
        Future.microtask(() {
          BottomNavController? navController;
          if (Get.isRegistered<BottomNavController>(
              tag: 'BottomNavController')) {
            navController =
                Get.find<BottomNavController>(tag: 'BottomNavController');
          } else if (Get.isRegistered<BottomNavController>()) {
            navController = Get.find<BottomNavController>();
          }
          navController?.changeTab(1);
        });
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to create event",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔷 Update an existing event
  Future<void> updateEvent({
    required String id,
    required String eventTitle,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required String description,
    required String category,
    required String address,
    required String city,
    required String state,
    String? latitude,
    String? longitude,
    required File? image,
    String? liveStreamUrl,
    String? eventPrice,
  }) async {
    try {
      isLoading.value = true;
      final response = await _eventService.updateEvent(
        eventId: id,
        eventTitle: eventTitle,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        eventdes: description,
        eventcategory: category,
        eventaddress: address,
        eventcity: city,
        eventstate: state,
        latitude: latitude,
        longitude: longitude,
        image: image,
        liveStreamUrl: liveStreamUrl,
        eventPrice: eventPrice,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Success", data["message"] ?? "Event updated.",
            backgroundColor: Colors.green, colorText: Colors.white);
        // Refresh the event list after successful update
        await fetchAllEvents();
      } else {
        final errorMessage = data["error"] ??
            data["message"] ??
            "Update failed. Status: ${response.statusCode}";
        Get.snackbar("Error", errorMessage,
            backgroundColor: Colors.red, colorText: Colors.white);
        debugPrint(
            "Update Event Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update event: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint("Update Event Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔷 Get single event by ID (reusing fetchEventDetail)
  Future<EventDetailModel?> getEventById(String eventId) async {
    try {
      isLoading.value = true;
      final fetchedEvent = await _eventService.fetchEventDetail(eventId);
      return fetchedEvent;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch event: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔷 Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      final response = await _eventService.deleteEvent(eventId);

      if (response.statusCode == 200) {
        Get.back(); // Close loader
        Get.snackbar(
          "Success",
          "Event deleted successfully",
          backgroundColor: AppColors.blueColor,
          colorText: AppColors.whiteColor,
        );
        await getMyEvents();
      } else {
        Get.back(); // Close loader
        Get.snackbar(
          "Error",
          "Failed to delete event: ${response.body}",
          backgroundColor: Colors.red,
          colorText: AppColors.whiteColor,
        );
      }
    } catch (e) {
      Get.back(); // Close loader
      Get.snackbar(
        "Exception",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: AppColors.whiteColor,
      );
    }
  }
}
