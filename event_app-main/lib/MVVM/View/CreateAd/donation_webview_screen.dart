import 'dart:convert';
import 'package:event_app/MVVM/View/bottombar/bottom_navigation_bar.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DonationWebView extends StatefulWidget {
  final int? donationid;
  final String donation;

  const DonationWebView(
      {super.key, required this.donationid, required this.donation});

  @override
  State<DonationWebView> createState() => _DonationWebViewState();
}

class _DonationWebViewState extends State<DonationWebView> {
  late final WebViewController _controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterWebView',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final Map<String, dynamic> data = jsonDecode(message.message);
            final nonce = data['token'];
            print('Received Square Token (nonce): $nonce');
            await sendToBackend(nonce);
          } catch (e) {
            print('Error parsing Square token: $e');
            _showSnackbar("Invalid payment response received.");
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate())
      ..loadRequest(Uri.parse(
          'https://eventgo-live.com/square-donate/${widget.donationid}'));
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete Donation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> sendToBackend(String nonce) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('User token: $token');

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            'https://eventgo-live.com/api/v1/ads/${widget.donationid}/donate'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "payment_nonce": nonce,
          "amount": widget.donation,
          "save_card": true,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar("Payment successful!");
        showSuccessDialog(context);
      } else {
        print('Payment failed: ${response.body}');
        _showSnackbar("Payment failed!");
      }
    } catch (e) {
      print('Exception during payment: $e');
      _showSnackbar("Something went wrong!");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSuccessDialog(BuildContext context) {
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
                  gradient: LinearGradient(
                    colors: [AppColors.blueColor, AppColors.backgroundColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
              const Text(
                "You have successfully placed a donation.\nThank you for your generosity!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Get.offAll(() => BottomNavBar(initialIndex: 2));
                  },
                  child: const Text(
                    "Got it",
                    style: TextStyle(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
