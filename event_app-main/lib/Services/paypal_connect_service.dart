import 'dart:convert';
import 'package:event_app/app/config/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PayPalConnectService {
  final String _baseUrl = '${AppUrl.baseUrl}/paypal';

  // Check if organizer has connected PayPal
  Future<Map<String, dynamic>> checkStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$_baseUrl/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'connected': false};
    } catch (e) {
      return {'connected': false, 'error': e.toString()};
    }
  }

  // Get the PayPal OAuth URL to open in browser/webview
  Future<String?> getConnectUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$_baseUrl/connect'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['oauth_url'];
      }
      print('PayPal Connect Error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('PayPal Connect Exception: $e');
      return null;
    }
  }

  // Disconnect PayPal account
  Future<bool> disconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$_baseUrl/disconnect'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
