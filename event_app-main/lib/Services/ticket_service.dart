import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TicketService {
  static const String baseUrl = "https://eventgo-live.com/api/v1";

  static Future<List<Map<String, dynamic>>> fetchTickets() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/events/bookings/history'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map<String, dynamic>) {
        final data = decoded['data'] ?? decoded['tickets'] ?? decoded['items'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          return const [];
        }
      } else {
        return const [];
      }
    } else {
      throw Exception(
          'Failed to fetch tickets: ${response.statusCode} ${response.body}');
    }
  }
}
