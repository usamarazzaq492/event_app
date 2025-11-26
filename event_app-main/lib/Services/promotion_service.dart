import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PromotionService {
  final String baseUrl = "https://eventgo-live.com/api/v1";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get available promotion packages
  Future<Map<String, dynamic>> getPackages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotion/packages'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load packages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading packages: $e');
    }
  }

  /// Purchase promotion for an event
  Future<Map<String, dynamic>> purchasePromotion({
    required int eventId,
    required String package, // 'basic' or 'premium'
    required String paymentNonce,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/promote'),
        headers: headers,
        body: json.encode({
          'package': package,
          'payment_nonce': paymentNonce,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to promote event');
      }
    } catch (e) {
      throw Exception('Error promoting event: $e');
    }
  }

  /// Get promotion status for an event
  Future<Map<String, dynamic>> getPromotionStatus(int eventId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/promotion-status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get promotion status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting promotion status: $e');
    }
  }
}

