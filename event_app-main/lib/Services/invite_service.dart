import 'package:event_app/app/config/app_url.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InviteService {
  Future<Map<String, dynamic>> inviteUsers({
    required int eventId, // <-- pass eventId here
    required List<int> userIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Missing token');
    }

    final uri = Uri.parse('${AppUrl.baseUrl}/invite/$eventId');
    debugPrint('🔗 Invite API URL: $uri');
    debugPrint('➡️ Sending userIds: $userIds');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"userIds": userIds}),
    );

    debugPrint('✅ Status: ${response.statusCode}');
    debugPrint('📄 Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invite failed: ${response.body}');
    }
  }

  /// Fetch received invites (notifications)
  Future<List<dynamic>> getReceivedInvites() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Missing token');
    }

    final uri = Uri.parse('${AppUrl.baseUrl}/invite/get-invites');
    debugPrint('🔗 Fetching invites from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint('✅ Invites Status: ${response.statusCode}');
    debugPrint('📄 Invites Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null) {
        return List<dynamic>.from(data['data']);
      }
      return [];
    } else {
      throw Exception('Failed to fetch invites: ${response.body}');
    }
  }

  /// Respond to an invite (accept or decline)
  Future<Map<String, dynamic>> respondToInvite({
    required int inviteId,
    required String response, // 'accepted' or 'declined'
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Missing token');
    }

    final uri = Uri.parse('${AppUrl.baseUrl}/invite/$inviteId/respond');
    debugPrint('🔗 Responding to invite: $uri');

    final httpResponse = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"response": response}),
    );

    debugPrint('✅ Respond Status: ${httpResponse.statusCode}');
    debugPrint('📄 Respond Body: ${httpResponse.body}');

    if (httpResponse.statusCode == 200) {
      return jsonDecode(httpResponse.body);
    } else {
      throw Exception('Failed to respond to invite: ${httpResponse.body}');
    }
  }
}
