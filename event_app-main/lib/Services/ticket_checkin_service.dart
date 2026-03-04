import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TicketCheckInService {
  static const String baseUrl = 'https://eventgo-live.com';

  /// Check in a ticket (marks it as used)
  static Future<Map<String, dynamic>> checkInTicket(String qrData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/tickets/checkin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'qr_data': qrData,
        }),
      );

      debugPrint('Ticket Check-in Response: ${response.statusCode}');
      debugPrint('Ticket Check-in Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'data': data['data'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to check in ticket',
          'checked_in_at': errorData['checked_in_at'],
          'warning': errorData['warning'],
        };
      }
    } catch (e) {
      debugPrint('Ticket Check-in Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Verify a ticket without checking it in (for preview)
  static Future<Map<String, dynamic>> verifyTicket(String qrData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/tickets/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'qr_data': qrData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? '',
          'data': data['data'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to verify ticket',
        };
      }
    } catch (e) {
      debugPrint('Ticket Verify Error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
