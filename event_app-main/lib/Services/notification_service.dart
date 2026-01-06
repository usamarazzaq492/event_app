import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String baseUrl = "https://eventgo-live.com/api/v1";

  /// Fetch all notifications (invites + follows)
  Future<List<dynamic>> getAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Missing token');
    }

    final uri = Uri.parse('$baseUrl/notifications');
    print('🔗 Fetching notifications from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('✅ Notifications Status: ${response.statusCode}');
    print('📄 Notifications Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return List<dynamic>.from(data['data']);
      }
      return [];
    } else {
      throw Exception('Failed to fetch notifications: ${response.body}');
    }
  }
}
