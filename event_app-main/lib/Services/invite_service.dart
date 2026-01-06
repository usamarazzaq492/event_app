import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InviteService {
  final String baseUrl = "https://eventgo-live.com/api/v1";

  Future<Map<String, dynamic>> inviteUsers({
    required int eventId, // <-- pass eventId here
    required List<int> userIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Missing token');
    }

    final uri = Uri.parse('$baseUrl/invite/$eventId');
    print('🔗 Invite API URL: $uri');
    print('➡️ Sending userIds: $userIds');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"userIds": userIds}),
    );

    print('✅ Status: ${response.statusCode}');
    print('📄 Body: ${response.body}');

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

    final uri = Uri.parse('$baseUrl/invite/get-invites');
    print('🔗 Fetching invites from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('✅ Invites Status: ${response.statusCode}');
    print('📄 Invites Body: ${response.body}');

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

    final uri = Uri.parse('$baseUrl/invite/$inviteId/respond');
    print('🔗 Responding to invite: $uri');

    final httpResponse = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"response": response}),
    );

    print('✅ Respond Status: ${httpResponse.statusCode}');
    print('📄 Respond Body: ${httpResponse.body}');

    if (httpResponse.statusCode == 200) {
      return jsonDecode(httpResponse.body);
    } else {
      throw Exception('Failed to respond to invite: ${httpResponse.body}');
    }
  }
}
