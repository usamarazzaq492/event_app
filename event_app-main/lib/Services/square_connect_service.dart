import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SquareConnectService {
  static const String baseUrl = 'https://eventgo-live.com';

  /// Check if Square account is connected
  static Future<Map<String, dynamic>> checkConnectionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'connected': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/square/status'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'connected': data['connected'] ?? false,
          'merchant_name': data['merchant_name'],
          'merchant_email': data['merchant_email'],
          'connected_at': data['connected_at'],
        };
      } else {
        return {'connected': false, 'error': 'Failed to check status'};
      }
    } catch (e) {
      return {'connected': false, 'error': e.toString()};
    }
  }

  /// Get OAuth URL for Square connection
  static Future<Map<String, dynamic>> getOAuthUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('Square Connect: No authentication token found');
        return {
          'success': false,
          'error': 'No authentication token found',
          'error_type': 'auth',
        };
      }

      print('Square Connect: Making request to $baseUrl/api/v1/square/connect');
      print('Square Connect: Using token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/square/connect'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - server took too long to respond');
        },
      );

      print('Square Connect API Response Status: ${response.statusCode}');
      print('Square Connect API Response Headers: ${response.headers}');
      print('Square Connect API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['oauth_url'] != null) {
            return {
              'success': true,
              'oauth_url': data['oauth_url'],
            };
          } else {
            print('Square Connect: oauth_url not found in response');
            print('Response data: $data');
            return {
              'success': false,
              'error': 'OAuth URL not found in server response',
              'error_type': 'invalid_response',
              'response_data': data,
            };
          }
        } catch (e) {
          print('Square Connect: JSON decode error: $e');
          print('Raw response: ${response.body}');
          return {
            'success': false,
            'error': 'Invalid JSON response from server: $e',
            'error_type': 'json_decode',
            'raw_response': response.body,
          };
        }
      } else {
        print('Square Connect: API returned error status ${response.statusCode}');
        String errorMessage = 'Server returned error ${response.statusCode}';
        Map<String, dynamic>? errorData;
        
        try {
          errorData = jsonDecode(response.body) as Map<String, dynamic>?;
          if (errorData != null) {
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
          print('Error details: $errorData');
        } catch (e) {
          print('Could not parse error response: $e');
          errorMessage = 'Server error ${response.statusCode}: ${response.body}';
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'error_type': 'http_error',
          'status_code': response.statusCode,
          'error_data': errorData,
        };
      }
    } on http.ClientException catch (e) {
      print('Square Connect: Network error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.message}',
        'error_type': 'network',
        'exception': e.toString(),
      };
    } on Exception catch (e) {
      print('Square Connect: Exception getting OAuth URL: $e');
      return {
        'success': false,
        'error': 'Error: ${e.toString()}',
        'error_type': 'exception',
        'exception': e.toString(),
      };
    } catch (e) {
      print('Square Connect: Unexpected error: $e');
      return {
        'success': false,
        'error': 'Unexpected error: $e',
        'error_type': 'unknown',
        'exception': e.toString(),
      };
    }
  }

  /// Disconnect Square account
  static Future<bool> disconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/square/disconnect'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error disconnecting Square: $e');
      return false;
    }
  }
}
