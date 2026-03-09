import 'package:event_app/app/config/app_url.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  /// Fetch all notifications (invites + follows)
  Future<List<dynamic>> getAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Missing token');
    }

    final uri = Uri.parse('${AppUrl.baseUrl}/notifications');
    debugPrint('🔗 Fetching notifications from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint('✅ Notifications Status: ${response.statusCode}');
    debugPrint('📄 Notifications Body: ${response.body}');

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
