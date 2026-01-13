import 'dart:convert';
import 'dart:io';

import 'package:event_app/MVVM/body_model/event_detail_model.dart';
import 'package:event_app/MVVM/body_model/event_model.dart';
import 'package:event_app/MVVM/body_model/my_event_model.dart';
import 'package:event_app/Services/event_service.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../View/bottombar/bottom_navigation_bar.dart';
import 'bottom_nav_controller.dart';

class EventController extends GetxController {
  final EventService _eventService = EventService();

  var events = <EventModel>[].obs;
  var upcomingEvents = <EventModel>[].obs;
  var pastEvents = <EventModel>[].obs;
  var myEvents = <MyEventModel>[].obs;
  var timelineEvents = <EventModel>[].obs; // Timeline: events from followed users
  var eventDetail = Rxn<EventDetailModel>();

  var isLoading = false.obs;
  var isDeleting = false.obs;
  var isTimelineLoading = false.obs;

  final RxString error = ''.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingEventsForHome();
    fetchAllEvents();
    getMyEvents();
    fetchTimelineEvents();
  }

  /// 🔷 Fetch all events and separate into upcoming & past
  Future<void> fetchAllEvents() async {
    try {
      isLoading.value = true;
      final result = await _eventService.fetchEvents();
      final now = DateTime.now();
      final upcoming = <EventModel>[];
      final past = <EventModel>[];

      for (var event in result) {
        final startDate = DateTime.tryParse(event.startDate ?? '');
        if (startDate != null) {
          if (startDate.isAfter(now)) {
            upcoming.add(event);
          } else {
            past.add(event);
          }
        }
      }

      upcomingEvents.assignAll(upcoming);
      pastEvents.assignAll(past);
      events.assignAll(result);
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
      final upcoming = result.where((event) {
        final startDate = DateTime.tryParse(event.startDate ?? '');
        return startDate != null && startDate.isAfter(now);
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
      errorMessage.value = e.toString();
      timelineEvents.clear(); // Clear on error
    } finally {
      isTimelineLoading.value = false;
    }
  }

  /// 🔷 Fetch event detail by ID
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
      print('getMyEvents Error: $e');
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
    required String eventPrice,
    required String vipPrice,
    required String eventDescription,
    required String eventCategory,
    required String eventAddress,
    required String eventCity,
    required String eventLatitude,
    required String eventLongitude,
    required File eventImage,
    String? liveStreamUrl,
  }) async {
    try {
      isLoading.value = true;
      final response = await _eventService.createEvent(
        eventTitle: eventTitle,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        eventPrice: eventPrice,
        vipPrice: vipPrice,
        eventdes: eventDescription,
        eventcategory: eventCategory,
        eventaddress: eventAddress,
        eventcity: eventCity,
        latitude: eventLatitude,
        longitude: eventLongitude,
        eventimage: eventImage.path,
        liveStreamUrl: liveStreamUrl,
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
        Get.offAll(() => BottomNavBar());
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
    required String eventPrice,
    required String vipPrice,
    required String description,
    required String category,
    required String address,
    required String city,
    String? latitude,
    String? longitude,
    required File? image,
    String? liveStreamUrl,
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
        eventPrice: eventPrice,
        vipPrice: vipPrice,
        eventdes: description,
        eventcategory: category,
        eventaddress: address,
        eventcity: city,
        latitude: latitude,
        longitude: longitude,
        eventImage: image,
        liveStreamUrl: liveStreamUrl,
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
        print("Update Event Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update event: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Update Event Exception: $e");
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
