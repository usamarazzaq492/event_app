import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentQrService {
  static const String baseUrl = "https://eventgo-live.com/api/v1";

  /// Generate payment QR code for an event (organizer only)
  Future<http.Response> generatePaymentQr({
    required int eventId,
    required String ticketType,
    String? expiresAt,
    int? maxUses,
  }) async {
    final uri = Uri.parse('$baseUrl/events/$eventId/payment-qr/generate');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final body = {
      'ticket_type': ticketType,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (maxUses != null) 'max_uses': maxUses,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    return response;
  }

  /// Validate a scanned payment QR code (public endpoint)
  Future<http.Response> validatePaymentQr({
    required String token,
    required int eventId,
    required String ticketType,
  }) async {
    final uri = Uri.parse('$baseUrl/payment-qr/validate');

    final body = {
      'token': token,
      'event_id': eventId,
      'ticket_type': ticketType,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(body),
    );

    return response;
  }

  /// Get all QR codes for an event (organizer only)
  Future<http.Response> getEventQrCodes(int eventId) async {
    final uri = Uri.parse('$baseUrl/events/$eventId/payment-qr/list');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  /// Deactivate a QR code (organizer only)
  Future<http.Response> deactivateQrCode(int qrId) async {
    final uri = Uri.parse('$baseUrl/payment-qr/$qrId/deactivate');
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }
}

