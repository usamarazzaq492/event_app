import 'dart:async';
import 'dart:convert';
import 'package:event_app/MVVM/View/bookEvent/book_event_screen.dart';
import 'package:event_app/Services/payment_qr_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';

class DeepLinkHandler {
  static AppLinks? _appLinks;
  static StreamSubscription? _linkSubscription;
  static final PaymentQrService _qrService = PaymentQrService();

  /// Initialize deep link handling
  static Future<void> init() async {
    _appLinks = AppLinks();
    
    // Handle initial link if app was opened via deep link
    try {
      final initialLink = await _appLinks!.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink.toString());
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Listen for deep links while app is running
    _linkSubscription = _appLinks!.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri.toString());
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  /// Dispose deep link handler
  static void dispose() {
    _linkSubscription?.cancel();
    _appLinks = null;
  }

  /// Handle deep link
  static Future<void> _handleDeepLink(String link) async {
    try {
      String deepLinkUrl = link;
      
      // Check if the link is JSON (in case QR code contains JSON)
      try {
        final jsonData = json.decode(link);
        if (jsonData is Map && jsonData.containsKey('app')) {
          deepLinkUrl = jsonData['app'] as String;
        } else if (jsonData is Map && jsonData.containsKey('web')) {
          // Fallback to web URL if app link not available
          deepLinkUrl = jsonData['web'] as String;
        }
      } catch (e) {
        // Not JSON, use link as-is
        deepLinkUrl = link;
      }
      
      final uri = Uri.parse(deepLinkUrl);
      
      // Handle payment QR code deep links
      if (uri.scheme == 'eventgo' && uri.host == 'pay') {
        final eventId = int.tryParse(uri.queryParameters['eventId'] ?? '0');
        final ticketType = uri.queryParameters['ticketType'] ?? 'general';
        final token = uri.queryParameters['token'] ?? '';

        if (eventId == null || eventId == 0 || token.isEmpty) {
          Get.snackbar(
            'Error',
            'Invalid QR code format',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Validate QR code with backend
        final response = await _qrService.validatePaymentQr(
          token: token,
          eventId: eventId,
          ticketType: ticketType,
        );

        final responseData = response.body;
        
        // Parse response
        Map<String, dynamic> data;
        try {
          data = json.decode(responseData);
        } catch (e) {
          data = {};
        }

        if (response.statusCode == 200 && data['success'] == true) {
          final eventData = data['data'];
          
          // Navigate to booking screen
          Get.to(
            () => BookEventScreen(
              id: eventId,
              preFilledTicketType: ticketType,
              preFilledPrice: eventData['price']?.toDouble() ?? 0.0,
            ),
          );
        } else {
          Get.snackbar(
            'Error',
            data['message'] ?? 'Invalid QR code',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
      Get.snackbar(
        'Error',
        'Failed to process QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

