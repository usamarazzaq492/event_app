import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../app/config/app_colors.dart';
import '../MVVM/View/ticketScreen/ticket_screen.dart';

class SquarePaymentPage extends StatefulWidget {
  final String category;
  final int seats;
  final int? id;
  final bool isPromotion;

  const SquarePaymentPage({
    super.key,
    required this.category,
    required this.seats,
    required this.id,
    this.isPromotion = false,
  });

  @override
  State<SquarePaymentPage> createState() => _SquarePaymentPageState();
}

class _SquarePaymentPageState extends State<SquarePaymentPage> {
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
      ..loadRequest(Uri.parse(
          widget.isPromotion
              ? 'https://eventgo-live.com/square-payment/${widget.id}?is_promotion=true&package=${widget.category}'
              : 'https://eventgo-live.com/square-payment/${widget.id}?quantity=${widget.seats}&ticket_type=${widget.category}'));
  }

  Future<void> sendToBackend(String nonce) async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    debugPrint('🔑 Token: $token');

    try {
      final String apiUrl = widget.isPromotion
          ? 'https://eventgo-live.com/api/v1/events/${widget.id}/promote'
          : 'https://eventgo-live.com/api/v1/events/${widget.id}/book';
      
      final Map<String, dynamic> requestBody = widget.isPromotion
          ? {
              'package': widget.category,
              'payment_nonce': nonce,
            }
          : {
              'ticket_type': widget.category,
              'quantity': widget.seats,
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
        if (widget.isPromotion) {
          Navigator.pop(context, true); // Return success to promotion screen
        } else {
          showSuccessDialog();
        }
      } else {
        debugPrint('❌ Payment failed: ${response.body}');
        _showSnackbar("Payment failed. Please try again.");
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      _showSnackbar("Something went wrong. Please try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                decoration: BoxDecoration(
                  color: AppColors.blueColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                "Congratulations!",
                style: TextStyle(
                  color: Colors.white,
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
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketScreen(),
                    ),
                  );
                },
                child: const Text("View E-Ticket",
                    style: TextStyle(color: AppColors.whiteColor)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, false);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white60),
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
        title: const Text('Complete Payment'),
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
