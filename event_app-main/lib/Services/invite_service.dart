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
}
