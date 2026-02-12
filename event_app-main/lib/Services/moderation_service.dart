import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ModerationService {
  static const String baseUrl = "https://eventgo-live.com/api/v1";

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> reportEvent(int eventId, {String? reason}) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to report.');
    }
    final url = Uri.parse('$baseUrl/report/event/$eventId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason ?? ''}),
    );
    final decoded = jsonDecode(response.body);
    decoded['statusCode'] = response.statusCode;
    return decoded;
  }

  static Future<Map<String, dynamic>> reportUser(int userId, {String? reason}) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to report.');
    }
    final url = Uri.parse('$baseUrl/report/user/$userId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason ?? ''}),
    );
    final decoded = jsonDecode(response.body);
    decoded['statusCode'] = response.statusCode;
    return decoded;
  }

  static Future<Map<String, dynamic>> blockUser(int userId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to block users.');
    }
    final url = Uri.parse('$baseUrl/user/$userId/block');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    final decoded = jsonDecode(response.body);
    decoded['statusCode'] = response.statusCode;
    return decoded;
  }

  static Future<Map<String, dynamic>> unblockUser(int userId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to unblock users.');
    }
    final url = Uri.parse('$baseUrl/user/$userId/unblock');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    final decoded = jsonDecode(response.body);
    decoded['statusCode'] = response.statusCode;
    return decoded;
  }

  static Future<List<int>> getBlockedUserIds() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return [];
    }
    final url = Uri.parse('$baseUrl/moderation/blocked-ids');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) return [];
    final decoded = jsonDecode(response.body);
    final list = decoded['blocked_ids'] as List<dynamic>? ?? [];
    return list.map((e) => (e as num).toInt()).toList();
  }
}
