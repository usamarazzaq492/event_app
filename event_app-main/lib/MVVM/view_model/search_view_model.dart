import 'package:event_app/MVVM/body_model/event_model.dart';
import 'package:event_app/Services/event_service.dart';
import 'package:event_app/Services/location_service.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class SearchViewModel extends GetxController {
  final EventService _eventService = EventService();

  // Observable variables
  var searchResults = <EventModel>[].obs;
  var nearbyEvents = <EventModel>[].obs;
  var availableCategories = <String>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var currentLocation = Rxn<Position>();
  var selectedCity = 'All Cities'.obs;
  var selectedCategory = 'All'.obs;
  var searchRadius = 50.0.obs; // Default 50km
  var isLocationEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Load initial data
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadAvailableCategories(),
        getCurrentLocation(),
      ]);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get current location
  Future<void> getCurrentLocation() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        currentLocation.value = position;
        isLocationEnabled.value = true;
        await getNearbyEvents();
      }
    } catch (e) {
      isLocationEnabled.value = false;
      print('Location error: $e');
    }
  }

  /// Load available categories
  Future<void> loadAvailableCategories() async {
    try {
      // Always use the specific categories you provided
      List<String> categories = [
        'Dating',
        'Sell Items',
        'Religion',
        'Sports',
        'Parties',
        'Food',
        'Music',
        'Youth events',
        'Social Circle',
        'Business',
        'Education',
        'Travel'
      ];

      availableCategories.assignAll(['All', ...categories]);
    } catch (e) {
      // Fallback to predefined categories
      List<String> fallbackCategories = [
        'Dating',
        'Sell Items',
        'Religion',
        'Sports',
        'Parties',
        'Food',
        'Music',
        'Youth events',
        'Social Circle',
        'Business',
        'Education',
        'Travel'
      ];
      availableCategories.assignAll(['All', ...fallbackCategories]);
    }
  }

  /// Search events with filters
  Future<void> searchEvents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<EventModel> results = await _eventService.searchEvents(
        city: selectedCity.value == 'All Cities' ? null : selectedCity.value,
        category:
            selectedCategory.value == 'All' ? null : selectedCategory.value,
        latitude: currentLocation.value?.latitude,
        longitude: currentLocation.value?.longitude,
        maxDistance: searchRadius.value,
      );

      searchResults.assignAll(results);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get nearby events
  Future<void> getNearbyEvents() async {
    if (currentLocation.value == null) return;

    try {
      isLoading.value = true;
      List<EventModel> nearby = await _eventService.getNearbyEvents(
        latitude: currentLocation.value!.latitude,
        longitude: currentLocation.value!.longitude,
        maxDistance: searchRadius.value,
        category:
            selectedCategory.value == 'All' ? null : selectedCategory.value,
      );

      nearbyEvents.assignAll(nearby);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Update selected city
  void updateSelectedCity(String city) {
    selectedCity.value = city;
    searchEvents();
  }

  /// Update selected category
  void updateSelectedCategory(String category) {
    selectedCategory.value = category;
    searchEvents();
    if (isLocationEnabled.value) {
      getNearbyEvents();
    }
  }

  /// Update search radius
  void updateSearchRadius(double radius) {
    searchRadius.value = radius;
    searchEvents();
    if (isLocationEnabled.value) {
      getNearbyEvents();
    }
  }

  /// Get distance for an event
  String getEventDistance(EventModel event) {
    if (currentLocation.value == null ||
        event.latitude == null ||
        event.longitude == null) {
      return '';
    }

    double distance = LocationService.calculateDistance(
      currentLocation.value!.latitude,
      currentLocation.value!.longitude,
      double.parse(event.latitude!),
      double.parse(event.longitude!),
    );

    return LocationService.formatDistance(distance);
  }

  /// Clear search results
  void clearSearch() {
    searchResults.clear();
    nearbyEvents.clear();
    selectedCity.value = 'All Cities';
    selectedCategory.value = 'All';
    searchRadius.value = 50.0;
  }
}
