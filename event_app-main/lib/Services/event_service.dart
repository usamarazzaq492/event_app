import 'dart:convert';
import 'dart:io';
import 'package:event_app/MVVM/body_model/event_detail_model.dart';
import 'package:event_app/MVVM/body_model/event_model.dart';
import 'package:event_app/MVVM/body_model/my_event_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';

class EventService {
  static const String baseUrl = "https://eventgo-live.com/api/v1/events";

  /// 🔷 Create Event
  Future<http.Response> createEvent({
    required String eventTitle,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required String eventPrice,
    required String vipPrice,
    required String eventdes,
    required String eventcategory,
    required String eventaddress,
    required String eventcity,
    required String latitude,
    required String longitude,
    required String eventimage, // File path
    String? liveStreamUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/add');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // Fields
    request.fields['eventTitle'] = eventTitle;
    request.fields['startDate'] = startDate;
    request.fields['endDate'] = endDate;
    request.fields['startTime'] = startTime;
    request.fields['endTime'] = endTime;
    request.fields['eventPrice'] = eventPrice;
    request.fields['vipPrice'] = vipPrice;
    request.fields['description'] = eventdes;
    request.fields['category'] = eventcategory;
    request.fields['address'] = eventaddress;
    request.fields['city'] = eventcity;
    request.fields['latitude'] = latitude;
    request.fields['longitude'] = longitude;
    if (liveStreamUrl != null && liveStreamUrl.isNotEmpty) {
      request.fields['live_stream_url'] = liveStreamUrl;
    }

    // Image file
    if (eventimage.isNotEmpty && File(eventimage).existsSync()) {
      request.files.add(await http.MultipartFile.fromPath(
        'eventImage',
        eventimage,
        filename: basename(eventimage),
      ));
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  /// 🔷 Fetch All Events
  Future<List<EventModel>> fetchEvents() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true && body['data'] != null) {
        final List data = body['data'];
        return data.map((e) => EventModel.fromJson(e)).toList();
      } else {
        throw Exception(body['message'] ?? "API Error");
      }
    } else {
      throw Exception('Failed to load events. Status: ${response.statusCode}');
    }
  }

  /// 🔷 Search Events by Location and Category
  Future<List<EventModel>> searchEvents({
    String? city,
    String? category,
    double? latitude,
    double? longitude,
    double? maxDistance,
  }) async {
    try {
      // First fetch all events
      List<EventModel> allEvents = await fetchEvents();
      List<EventModel> filteredEvents = [];

      for (EventModel event in allEvents) {
        bool shouldInclude = true;

        // Filter by category
        if (category != null && category.isNotEmpty && category != 'All') {
          if (event.category?.toLowerCase() != category.toLowerCase()) {
            shouldInclude = false;
          }
        }

        // Filter by city
        if (city != null && city.isNotEmpty && city != 'All Cities') {
          if (event.city?.toLowerCase() != city.toLowerCase()) {
            shouldInclude = false;
          }
        }

        // Filter by distance (if coordinates are provided)
        if (latitude != null && longitude != null && maxDistance != null) {
          if (event.latitude != null && event.longitude != null) {
            double distance = LocationService.calculateDistance(
              latitude,
              longitude,
              double.parse(event.latitude!),
              double.parse(event.longitude!),
            );
            if (distance > maxDistance) {
              shouldInclude = false;
            }
          }
        }

        if (shouldInclude) {
          filteredEvents.add(event);
        }
      }

      // Sort: Promoted events FIRST, then by date
      filteredEvents.sort((a, b) {
        // First priority: Promoted events come first
        final aIsPromoted = a.isPromotionActive;
        final bIsPromoted = b.isPromotionActive;

        if (aIsPromoted && !bIsPromoted) return -1; // a comes first
        if (!aIsPromoted && bIsPromoted) return 1; // b comes first

        // If both promoted or both not promoted, sort by date
        try {
          final aDate = DateTime.parse(a.startDate ?? '');
          final bDate = DateTime.parse(b.startDate ?? '');
          return aDate.compareTo(bDate);
        } catch (_) {
          return 0;
        }
      });

      return filteredEvents;
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  /// 🔷 Get Nearby Events
  Future<List<EventModel>> getNearbyEvents({
    required double latitude,
    required double longitude,
    double maxDistance = 50.0, // Default 50km radius
    String? category,
  }) async {
    try {
      List<EventModel> allEvents = await fetchEvents();
      List<EventModel> nearbyEvents = [];

      for (EventModel event in allEvents) {
        if (event.latitude != null && event.longitude != null) {
          double distance = LocationService.calculateDistance(
            latitude,
            longitude,
            double.parse(event.latitude!),
            double.parse(event.longitude!),
          );

          if (distance <= maxDistance) {
            // Filter by category if specified
            if (category != null && category.isNotEmpty && category != 'All') {
              if (event.category?.toLowerCase() == category.toLowerCase()) {
                nearbyEvents.add(event);
              }
            } else {
              nearbyEvents.add(event);
            }
          }
        }
      }

      // Sort by distance
      nearbyEvents.sort((a, b) {
        double distanceA = LocationService.calculateDistance(
          latitude,
          longitude,
          double.parse(a.latitude!),
          double.parse(a.longitude!),
        );
        double distanceB = LocationService.calculateDistance(
          latitude,
          longitude,
          double.parse(b.latitude!),
          double.parse(b.longitude!),
        );
        return distanceA.compareTo(distanceB);
      });

      return nearbyEvents;
    } catch (e) {
      throw Exception('Failed to get nearby events: $e');
    }
  }

  /// 🔷 Get Available Cities
  Future<List<String>> getAvailableCities() async {
    try {
      List<EventModel> allEvents = await fetchEvents();
      Set<String> cities = {};

      for (EventModel event in allEvents) {
        if (event.city != null && event.city!.isNotEmpty) {
          cities.add(event.city!);
        }
      }

      return cities.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get cities: $e');
    }
  }

  /// 🔷 Get Available Categories
  Future<List<String>> getAvailableCategories() async {
    try {
      List<EventModel> allEvents = await fetchEvents();
      Set<String> categories = {};

      for (EventModel event in allEvents) {
        if (event.category != null && event.category!.isNotEmpty) {
          categories.add(event.category!);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  /// 🔷 Fetch Event Detail by ID
  Future<EventDetailModel> fetchEventDetail(String id) async {
    final uri = Uri.parse('$baseUrl/$id');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return EventDetailModel.fromJson(data);
    } else {
      throw Exception('Failed to load event details');
    }
  }

  /// 🔷 Fetch My Events
  Future<List<MyEventModel>> fetchMyEvents() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/my'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('fetchMyEvents response: ${response.body}');

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body is List) {
        // ✅ Parse each event item into MyEventModel
        return body.map((e) => MyEventModel.fromJson(e)).toList();
      } else {
        throw Exception("Unexpected API structure: $body");
      }
    } else {
      throw Exception(
          'Failed to load your events. Status: ${response.statusCode}');
    }
  }

  /// 🔷 Fetch Timeline Events - Events from users you follow
  Future<List<EventModel>> fetchTimelineEvents() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/timeline'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true && body['data'] != null) {
        final List data = body['data'];
        return data.map((e) => EventModel.fromJson(e)).toList();
      } else {
        return []; // Return empty list if no events or not following anyone
      }
    } else {
      throw Exception('Failed to load timeline events. Status: ${response.statusCode}');
    }
  }

  /// 🔷 Delete Event
  Future<http.Response> deleteEvent(String id) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    return response;
  }

  /// 🔷 Update Event
  Future<http.Response> updateEvent({
    required String eventId,
    required String eventTitle,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required String eventPrice,
    required String vipPrice,
    required String eventdes,
    required String eventcategory,
    required String eventaddress,
    required String eventcity,
    String? latitude,
    String? longitude,
    File? eventImage,
    String? liveStreamUrl,
  }) async {
    final uri = Uri.parse("$baseUrl/$eventId");
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Fields
    request.fields['eventTitle'] = eventTitle;
    request.fields['startDate'] = startDate;
    request.fields['endDate'] = endDate;
    request.fields['startTime'] = startTime;
    request.fields['endTime'] = endTime;
    request.fields['eventPrice'] = eventPrice;
    request.fields['vipPrice'] = vipPrice;
    request.fields['description'] = eventdes;
    request.fields['category'] = eventcategory;
    request.fields['address'] = eventaddress;
    request.fields['city'] = eventcity;
    if (latitude != null) request.fields['latitude'] = latitude;
    if (longitude != null) request.fields['longitude'] = longitude;
    if (liveStreamUrl != null && liveStreamUrl.isNotEmpty) {
      request.fields['live_stream_url'] = liveStreamUrl;
    }

    // Image file - only add if file exists and is valid
    if (eventImage != null && await eventImage.exists()) {
      try {
        request.files.add(await http.MultipartFile.fromPath(
          'eventImage',
          eventImage.path,
          filename: basename(eventImage.path),
        ));
      } catch (e) {
        print("Error adding image file: $e");
        throw Exception("Failed to process image file: $e");
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("Update Event Response: ${response.statusCode} - ${response.body}");
      return response;
    } catch (e) {
      print("Error sending update request: $e");
      rethrow;
    }
  }
}
