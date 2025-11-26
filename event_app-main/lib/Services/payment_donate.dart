// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:http/http.dart' as http;
//
// class SquarePaymentWebView extends StatefulWidget {
//   const SquarePaymentWebView({super.key});
//
//   @override
//   State<SquarePaymentWebView> createState() => _SquarePaymentWebViewState();
// }
//
// class _SquarePaymentWebViewState extends State<SquarePaymentWebView> {
//   late final WebViewController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onNavigationRequest: (request) {
//             final url = request.url;
//
//             // Detect if URL contains the payment_nonce
//             if (url.contains("payment_nonce=")) {
//               final uri = Uri.parse(url);
//               final nonce = uri.queryParameters["payment_nonce"];
//
//               if (nonce != null && nonce.isNotEmpty) {
//                 _callBookingApi(nonce); // Pass the nonce to Laravel
//               }
//
//               return NavigationDecision.prevent; // Stop navigation
//             }
//
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(""
//           ""));
//   }
//
//   Future<void> _callBookingApi(String nonce) async {
//     final url = Uri.parse("https://eventgo-live.com/api/v1/events/3/book");
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer ',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "ticket_type": "gold",
//           "quantity": 2,
//           "payment_nonce": nonce,
//           "save_card": true,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true) {
//           // ✅ Show success message
//           showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               title: Text("Payment Success"),
//               content: Text("Ticket booked successfully! 🎉"),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text("OK"),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           _showError("API failed: ${data['message']}");
//         }
//       } else {
//         _showError("Server error: ${response.statusCode}");
//       }
//     } catch (e) {
//       _showError("Error: $e");
//     }
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Square Payment")),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonatePaymentPage extends StatefulWidget {
  final int donate;

  const DonatePaymentPage({super.key, required this.donate});

  @override
  State<DonatePaymentPage> createState() => _DonatePaymentPageState();
}

class _DonatePaymentPageState extends State<DonatePaymentPage> {
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
          final nonce = message.message;
          print('Received Square Token (nonce): $nonce');
          await sendToBackend(nonce);
        },
      )
      ..setNavigationDelegate(NavigationDelegate())
      ..loadRequest(
          Uri.parse('https://eventgo-live.com/square-donate/${widget.donate}'));
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    print('amount ${widget.donate}');
    return Scaffold(
      appBar: AppBar(title: Text('Complete Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> sendToBackend(String nonce) async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(
            'https://eventgo-live.com/api/v1/ads/${widget.donate}/donate'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "payment_nonce": nonce,
          "amount": widget.donate,
          "save_card": true
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        _showSnackbar("Payment successful!");
      } else {
        print('Payment failed: ${response.body}');
        _showSnackbar("Payment failed!");
      }
    } catch (e) {
      print('Exception: $e');
      _showSnackbar("Something went wrong!");
    } finally {
      setState(() => isLoading = false);
    }
  }
}
