import 'dart:convert';
import 'package:event_app/MVVM/body_model/ticket_tier_model.dart';
import 'package:event_app/app/config/app_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../app/config/app_colors.dart';
import '../MVVM/View/bottombar/bottom_navigation_bar.dart';

class PayPalPaymentPage extends StatefulWidget {
  final String category;
  final int seats;
  final int? id;
  final bool isPromotion;
  // New multi-tier params
  final List<TicketTier>? selectedTiers;
  final double? totalAmount;

  const PayPalPaymentPage({
    super.key,
    required this.category,
    required this.seats,
    required this.id,
    this.isPromotion = false,
    this.selectedTiers,
    this.totalAmount,
  });

  @override
  State<PayPalPaymentPage> createState() => _PayPalPaymentPageState();
}

class _PayPalPaymentPageState extends State<PayPalPaymentPage> {
  late final WebViewController _controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterWebView',
        onMessageReceived: (message) async {
          final nonce = message.message;
          debugPrint('🔑 Received Square nonce: $nonce');
          await sendToBackend(nonce);
        },
      )
      ..loadRequest(Uri.parse(widget.isPromotion
          ? '${AppUrl.webBaseUrl}/paypal-payment/${widget.id}?is_promotion=true&package=${Uri.encodeComponent(widget.category)}'
          : '${AppUrl.webBaseUrl}/paypal-payment/${widget.id}?quantity=${widget.seats}&ticket_type=${Uri.encodeComponent(widget.category)}&subtotal=${widget.totalAmount}'));
  }

  Future<void> sendToBackend(String nonce) async {
    if (isLoading) return; // Prevent multiple requests for the same purchase
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    debugPrint('🔑 Token: $token');

    try {
      final String apiUrl = widget.isPromotion
          ? '${AppUrl.baseUrl}/events/${widget.id}/promote'
          : '${AppUrl.baseUrl}/events/${widget.id}/book';

      final Map<String, dynamic> requestBody = widget.isPromotion
          ? {
              'package': widget.category,
              'payment_nonce': nonce,
            }
          : {
              // Legacy fields to prevent validation errors on older backends (if they accept custom strings)
              'ticket_type': widget.category,
              'quantity': widget.seats,

              // Multi-tier payload: send tiers[] array if available
              if (widget.selectedTiers != null &&
                  widget.selectedTiers!.isNotEmpty)
                'tiers': widget.selectedTiers!
                    .map((t) => t.toBookingPayload())
                    .toList()
              else ...{
                // Legacy fallback: single tier derived from category + seats
                'tiers': [
                  {'tier_id': 0, 'quantity': widget.seats}
                ],
              },
              'payment_nonce': nonce,
              'save_card': true,
            };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Payment success: ${response.body}');
        if (!mounted) return;
        if (widget.isPromotion) {
          Navigator.pop(context, true); // Return success to promotion screen
        } else {
          showSuccessDialog();
        }
      } else {
        debugPrint('❌ Payment failed: ${response.body}');
        String errorMsg = "Payment failed. Please try again.";
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          if (body.containsKey('details')) {
            errorMsg = "Validation: " + body['details'].toString();
          } else if (body.containsKey('error')) {
            errorMsg = body['error'].toString();
          } else if (body.containsKey('message')) {
            errorMsg = body['message'].toString();
          }
        } catch (_) {}
        _showErrorDialog(errorMsg, response.body);
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      _showErrorDialog("Something went wrong. Please try again.", e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String details) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.signinoptioncolor,
        title: Text(title,
            style: const TextStyle(
                color: AppColors.textColorPrimary, fontSize: 16)),
        content: SingleChildScrollView(
          child: Text(details,
              style: const TextStyle(
                  color: AppColors.textColorSecondary, fontSize: 12)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('OK', style: TextStyle(color: AppColors.blueColor)),
          ),
        ],
      ),
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.signinoptioncolor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  color: AppColors.blueColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                "Congratulations!",
                style: TextStyle(
                  color: AppColors.textColorPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.isPromotion
                    ? "Your event promotion has been activated successfully!"
                    : "You have successfully placed an order for the event. Enjoy!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textColorSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 25),
              if (!widget.isPromotion)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BottomNavBar(initialIndex: 3),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text("View E-Ticket",
                      style: TextStyle(color: Colors.white)),
                ),
              if (!widget.isPromotion) const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (!widget.isPromotion) {
                    Navigator.pop(context, false);
                  }
                },
                child: Text(
                  widget.isPromotion ? "Done" : "Cancel",
                  style: const TextStyle(color: AppColors.textColorSecondary),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textColorPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.isPromotion ? 'Promote Event' : 'Complete Payment',
            style: const TextStyle(color: AppColors.textColorPrimary)),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
                child: CircularProgressIndicator(color: AppColors.blueColor)),
        ],
      ),
    );
  }
}
